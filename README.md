# Project Tracker Tempest

> Template เว็บติดตามโครงการและงานรายสัปดาห์ — Clone ไปติดตั้ง Supabase **ของตัวเอง** ได้ทันที โดยเริ่มจากข้อมูลว่าง

หน้าตาแบบเดียวกับ Project Tracker ต้นแบบ แต่ **ไม่มีข้อมูล CoopConnect, 68 ข้อ, URL/Key Supabase ของผู้สร้าง หรือการเชื่อมต่อฐานข้อมูลเดิมติดมา** 

## ความสามารถ

- สร้างได้หลายโครงการ โดยกรอกชื่อและจำนวนสัปดาห์ (1–104)
- สร้างสัปดาห์ว่างให้ตามจำนวนที่กำหนด พร้อมแก้หัวข้อ/เป้าหมาย/งานที่ทำร่วมกัน/ผลส่งมอบ
- เพิ่มข้อหรือรายการงานเอง เลขข้อ บทบาท รายละเอียด รายการย่อย และย้ายสัปดาห์
- ติดตามสถานะและโน้ต ความคืบหน้าแยกสัปดาห์/โครงการ ค้นหาและกรอง
- แนบ JPG / PNG / WebP พร้อมคำอธิบาย ขนาดไม่เกิน 5 MB ต่อไฟล์ ผ่าน Private Supabase Storage
- ระบบ Supabase Auth, Editor allowlist และ RLS; ผู้ชมทั่วไปดูโครงการ/งานได้
- Static Website รองรับ GitHub Pages ไม่มีเซิร์ฟเวอร์แอปพลิเคชันแยก

## เริ่มต้น

1. กด **Use this template** บน GitHub (หรือ Clone Repository นี้)
2. [อ่านคู่มือติดตั้งภาษาไทยทั้งหมด](./SETUP.md) และ [หน้า Setup บนเว็บ](./setup.html)
3. สร้าง Supabase Project ใหม่แล้วรัน [`supabase/SETUP.sql`](./supabase/SETUP.sql) ครั้งเดียว
4. แก้ [`config.js`](./config.js) ใส่ **Project URL + Publishable Key** ของคุณ
5. สมัครบัญชีและให้เจ้าของ Supabase อนุมัติ Editor ใน SQL Editor ตามคู่มือ
6. เปิด `index.html` ผ่าน Live Server เพื่อสร้างโครงการ
7. เมื่อพร้อม **คุณเป็นคน Merge/Deploy GitHub Pages เอง**

### การทดสอบ

```bash
node tests/smoke.cjs
```

นี่คือ static smoke test ไม่ใช้ฐานข้อมูลจริง การใช้งานครั้งแรกควรทดสอบสมัคร/ล็อกอิน Editor, เพิ่มโครงการและอัปโหลดรูปกับ Supabase Project ของคุณเอง

## ไฟล์

| ไฟล์ | หน้าที่ |
|---|---|
| `index.html` | Project Tracker UI |
| `styles.css`, `template.css` | ธีม Responsive |
| `app.js` | เชื่อม Supabase, จัดการโครงการ/งาน/หลักฐาน |
| `config.js` | URL + Publishable Key **ของผู้ติดตั้ง** (ค่า placeholder ตอนเริ่มต้น) |
| `supabase/SETUP.sql` | โครงสร้าง DB, RLS, Private Storage, Realtime |
| `SETUP.md`, `setup.html` | คู่มือ First-time Setup |
| `tests/smoke.cjs` | ตรวจ syntax/โครงสร้างและป้องกันคีย์เดิมติดมา |

## ความปลอดภัย

โครงการ สัปดาห์ ข้อ และโน้ต **ทุกคนอ่านได้** ภาพหลักฐานเป็น Private Bucket แต่ **ผู้ใช้ที่ล็อกอินได้สามารถเปิดภาพได้** (ไม่จำกัดรายโครงการ) ส่วนการแก้ไขเป็นสิทธิ์ของ Editor ที่เจ้าของ Supabase อนุมัติผ่าน SQL เท่านั้น

อย่าใส่ข้อมูลลับในบันทึกหรือรายละเอียดงาน และ **อย่า Commit secret/service_role key** ลง GitHub. อ่าน [รายละเอียดสิทธิ์และการติดตั้ง](./SETUP.md)

## ขอบเขตโครงการนี้

Repository นี้เป็น Template แจกจ่าย: การใช้งานกับฐานข้อมูลจริง การอนุมัติ Editor และการ Deploy ของผู้ติดตั้ง **ต้องทำโดยเจ้าของ Project ของตนเอง** ไม่มีการสร้าง Supabase Project แทนใครโดยอัตโนมัติ
