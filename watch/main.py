import sys
import requests
from datetime import datetime, timedelta
from PyQt6.QtWidgets import QApplication, QWidget, QMenu
from PyQt6.QtGui import QPainter, QColor, QPen, QFont, QPolygon, QRegion, QAction, QPixmap
from PyQt6.QtCore import Qt, QTimer, QPoint, QRect, pyqtSignal, QObject

# API URL for fetching time
TIME_API_URL = "https://worldtimeapi.org/api/timezone/Europe/Dublin"

class WatchFace(QWidget):

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Qt Watch")
        self.setGeometry(100, 100, 400, 400)

        # Set flags from the start
        flags = Qt.WindowType.FramelessWindowHint
        self.setWindowFlags(flags)

        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)

        self.watchface_pixmap = QPixmap("watchface.png")
        self.drag_position = None
        self.current_time = None
        self.fetch_time()

        # Timer to update the watch every second
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_time)
        self.timer.start(1000)

        # Timer to re-sync with API every 10 minutes
        self.sync_timer = QTimer(self)
        self.sync_timer.timeout.connect(self.fetch_time)
        self.sync_timer.start(10 * 60 * 1000)

    def fetch_time(self):
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
            }
            # Set a timeout for the request (e.g., 5 seconds)
            response = requests.get(TIME_API_URL, headers=headers, timeout=5)
            response.raise_for_status()
            data = response.json()
            time_str = data['datetime']
            self.current_time = datetime.fromisoformat(time_str)
            print(f"Time fetched successfully: {self.current_time}")
        except requests.exceptions.Timeout:
            print("Error fetching time: The request timed out.")
            if self.current_time is None:
                self.current_time = datetime.now()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching time: {e}")
            if self.current_time is None:
                self.current_time = datetime.now()
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            if self.current_time is None:
                self.current_time = datetime.now()

    def update_time(self):
        if self.current_time:
            self.current_time += timedelta(seconds=1)
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        side = min(self.width(), self.height())
        painter.setViewport(0, 0, side, side)
        painter.setWindow(-200, -200, 400, 400)

        if not self.watchface_pixmap.isNull():
            painter.drawPixmap(-200, -200, 400, 400, self.watchface_pixmap)
            
        # Thin black border
        pen = QPen(QColor(0, 0, 0))
        pen.setWidth(4)
        painter.setPen(pen)
        painter.setBrush(Qt.BrushStyle.NoBrush)
        painter.drawEllipse(-198, -198, 396, 396)

        if not self.current_time:
            return

        # Heavier Gothic Style Hands inspired by Big Ben
        hour_hand = QPolygon([
            QPoint(0, -100), QPoint(-10, -95), QPoint(-15, -60), QPoint(-10, -55),
            QPoint(-15, 10), QPoint(15, 10), QPoint(10, -55), QPoint(15, -60),
            QPoint(10, -95), QPoint(0, -100)
        ])
        minute_hand = QPolygon([
            QPoint(0, -150), QPoint(-8, -145), QPoint(-12, -90), QPoint(-6, -85),
            QPoint(-12, 15), QPoint(12, 15), QPoint(6, -85), QPoint(12, -90),
            QPoint(8, -145), QPoint(0, -150)
        ])
        second_hand = QPolygon([QPoint(2, 20), QPoint(-2, 20), QPoint(-1, -180), QPoint(1, -180)])

        # Darker Blue color for hands (fully opaque)
        hand_color = QColor(25, 45, 90, 255)

        # Draw Hour Hand
        painter.setBrush(hand_color)
        painter.setPen(Qt.PenStyle.NoPen)
        painter.save()
        hour_angle = (self.current_time.hour % 12 + self.current_time.minute / 60) * 30
        painter.rotate(hour_angle)
        painter.drawConvexPolygon(hour_hand)
        painter.restore()

        # Draw Minute Hand
        painter.setBrush(hand_color)
        painter.save()
        minute_angle = self.current_time.minute * 6
        painter.rotate(minute_angle)
        painter.drawConvexPolygon(minute_hand)
        painter.restore()

        # Draw Second Hand (fully opaque)
        second_color = QColor(45, 85, 150, 255)
        painter.setBrush(second_color)
        painter.save()
        second_angle = self.current_time.second * 6
        painter.rotate(second_angle)
        painter.drawConvexPolygon(second_hand)
        painter.restore()
        
    

        # Center circle
        painter.setBrush(QColor(50, 50, 50))
        painter.drawEllipse(-8, -8, 16, 16)

        font = QFont()
        font.setPointSize(16)
        font.setBold(True)
        painter.setFont(font)
        painter.setPen(QColor(25, 45, 90, 255))
        date_str = self.current_time.strftime("%a %d").upper()
        painter.drawText(QRect(-100, 50, 200, 50), Qt.AlignmentFlag.AlignCenter, date_str)
        
        font = QFont()
        font.setPointSize(8)
        painter.setFont(font)
        painter.setPen(QColor(100, 100, 100))
        copyright_text = "Copyright (C)2025 kappel79"
        painter.drawText(QRect(-100, 170, 200, 20), Qt.AlignmentFlag.AlignCenter, copyright_text)

    def resizeEvent(self, event):
        side = min(self.width(), self.height())
        mask = QRect(int((self.width() - side) / 2), int((self.height() - side) / 2), side, side)
        region = QRegion(mask, QRegion.RegionType.Ellipse)
        self.setMask(region)
        super().resizeEvent(event)

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            if self.windowHandle() and self.windowHandle().startSystemMove():
                event.accept()
            else:
                self.drag_position = event.globalPosition().toPoint() - self.frameGeometry().topLeft()
                event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.MouseButton.LeftButton:
            if self.drag_position:
                self.move(event.globalPosition().toPoint() - self.drag_position)
                event.accept()

    def mouseReleaseEvent(self, event):
        self.drag_position = None
        event.accept()

    def contextMenuEvent(self, event):
        menu = QMenu(self)

        close_action = QAction("Close", self)
        close_action.triggered.connect(self.close)
        menu.addAction(close_action)

        menu.exec(event.globalPos())

def main():
    app = QApplication(sys.argv)
    watch = WatchFace()
    watch.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()