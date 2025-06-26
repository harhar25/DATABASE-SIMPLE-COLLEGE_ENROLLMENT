import flet as ft
import mysql.connector
from flet import Text, Column, Container, Row, ElevatedButton, Card, AppBar

# Update your own DB config
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "college_enrollment_system"
}

def get_enrollment_data():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT COUNT(*) AS total_active FROM tbl_ENROLLMENT WHERE status = 'active'
    """)
    active = cursor.fetchone()['total_active']

    cursor.execute("""
        SELECT COUNT(*) AS total_dropped FROM tbl_enrollment_archive
    """)
    dropped = cursor.fetchone()['total_dropped']

    cursor.execute("""
        SELECT s.subject_name, ss.schedule_time, ss.total AS enrolled, ss.max AS capacity
        FROM tbl_SUBJECT_SCHEDULE ss
        JOIN tbl_SUBJECT s ON ss.subject_id = s.subject_id
    """)
    schedules = cursor.fetchall()

    cursor.close()
    conn.close()
    return active, dropped, schedules

def main(page: ft.Page):
    page.title = "Enrollment Dashboard"
    page.scroll = ft.ScrollMode.AUTO

    def refresh_data(e=None):
        active, dropped, schedules = get_enrollment_data()
        page.controls.clear()

        page.appbar = AppBar(title=Text("Enrollment Monitoring", size=20))

        stats = Row([
            Card(content=Container(content=Text(f"🟢 Active: {active}", size=16), padding=10)),
            Card(content=Container(content=Text(f"🔴 Dropped: {dropped}", size=16), padding=10)),
        ], alignment="spaceEvenly")

        schedule_cards = []
        for sched in schedules:
            schedule_cards.append(
                Card(content=Container(
                    content=Column([
                        Text(f"📘 Subject: {sched['subject_name']}", size=14),
                        Text(f"🕐 Schedule: {sched['schedule_time']}", size=12),
                        Text(f"👥 Enrolled: {sched['enrolled']} / {sched['capacity']}", size=12),
                    ]), padding=10))
            )

        page.controls.extend([
            stats,
            Text("\n📚 Subject Schedules", size=18, weight="bold"),
            Column(schedule_cards),
            ElevatedButton("🔄 Refresh", on_click=refresh_data)
        ])

        page.update()

    refresh_data()

ft.app(target=main)
