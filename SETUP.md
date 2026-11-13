# คู่มือติดตั้ง Project Tracker Tempest ด้วย Supabase ของคุณเอง

Template นี้เริ่มจาก **0 โครงการ, 0 สัปดาห์, 0 ข้อ** และไม่เชื่อม Supabase ของผู้พัฒนา
ใช้กับ GitHub Pages หรือ Static Hosting ได้ (HTML/CSS/JavaScript ไม่ต้องมี Backend Server แยก)

## 1) Clone หรือ Use this template

```bash
git clone https://github.com/Bunyakhon/project-tracker-tempest.git
cd project-tracker-tempest
```

ถ้าสร้าง Repository ของตัวเองด้วย **Use this template** ให้ Clone จาก Repository ใหม่ของคุณแทน ไม่ต้องใช้ข้อมูลหรือประวัติ Commit จากเจ้าของเดิม

## 2) สร้าง Supabase Project ของคุณ

1. ไปที่ [Supabase Dashboard](https://supabase.com/dashboard) → **New project** → ตั้งชื่อ/รหัสผ่านฐานข้อมูล/Region
2. เปิดเมนู **SQL Editor** ใน Project ใหม่นี้
3. คัดลอกเนื้อหาทั้งหมดของ [`supabase/SETUP.sql`](./supabase/SETUP.sql) และกด **Run** เพียงครั้งเดียว
4. SQL จะสร้าง 5 ตาราง ได้แก่ `tracker_editors`, `tracker_custom_projects`, `tracker_custom_weeks`, `tracker_custom_tasks`, `tracker_custom_evidence` และ Private Storage Bucket `fitm-evidence`
5. เริ่มต้นจะไม่มีโครงการตัวอย่าง และยังไม่มี Editor

**สำคัญ:** อย่ารัน SQL นี้ใน Supabase Project ที่มีข้อมูลจริง/ตารางชื่อเดียวกันโดยไม่ตรวจสอบก่อน เพราะออกแบบสำหรับ **Project ใหม่** โดยเฉพาะ และมีคำสั่งสร้าง RLS Policy ชื่อคงที่

## 3) กำหนดค่าที่ไฟล์ `config.js`

ใน Supabase Dashboard ไปที่ **Project Settings → API Keys / Data API** (ชื่อเมนูอาจเปลี่ยนได้ตามเวอร์ชัน) แล้วคัดลอก:
- **Project URL** เช่น `https://YOUR-PROJECT-REF.supabase.co`
- **Publishable Key** (`sb_publishable_...`)

เปิด `config.js` และแทนค่า:
```js
window.TRACKER_CONFIG = Object.freeze({
  SUPABASE_URL: "https://YOUR-PROJECT-REF.supabase.co",
  SUPABASE_PUBLISHABLE_KEY: "sb_publishable_YOUR_OWN_PUBLIC_KEY"
});
```

**Publishable Key เป็นคีย์สำหรับ Browser และ Commit ลง Public Repository ได้เมื่อเปิด RLS ตามที่ให้ไว้แล้ว** แต่ห้ามใส่ `service_role`, `sb_secret_...`, Database Password, Access Token หรือรหัสผ่านผู้ใช้ใน Repository โดยเด็ดขาด

> เมื่อแก้ `config.js` แล้ว Deploy บน GitHub Pages ผู้ชมทุกคนจะเชื่อม **Supabase ของผู้ติดตั้ง** โดยไม่ต้องตั้งค่าใหม่ต่อเครื่อง

## 4) ตั้งค่า Supabase Authentication และสร้าง Editor คนแรก

1. ที่ Supabase → **Authentication → URL Configuration** ใส่ **Site URL** ของเว็บ เช่น `https://YOURNAME.github.io/YOURREPO/` และเพิ่ม **Redirect URLs** ให้รวม URL หน้าเว็บหลักนั้น
2. Authentication → **Providers → Email** ให้ Email Signups ทำงาน หากต้องการใช้ปุ่มสมัครบัญชีบนเว็บ (หรือจะสร้างผู้ใช้จาก Dashboard แทนก็ได้)
3. เปิดหน้าเว็บ กรอกอีเมล/รหัสผ่านอย่างน้อย 8 ตัว แล้วกด **สมัครบัญชี** และยืนยันอีเมลเมื่อระบบร้องขอ
4. กลับไปที่ Supabase → **SQL Editor** แล้วรัน SQL นี้ โดยเปลี่ยนอีเมลให้เป็นบัญชีเจ้าของระบบ:

```sql
insert into public.tracker_editors (user_id)
select id from auth.users
where lower(email) = lower('YOUR_EMAIL@example.com')
on conflict (user_id) do nothing;
```

5. ตรวจสอบว่าคำสั่งเพิ่มบัญชีสำเร็จ (ผู้ใช้ต้องมีใน `auth.users` ก่อน) แล้วกลับเว็บ **ออกจากระบบและเข้าสู่ระบบอีกครั้ง** ควรเห็นคำว่า **Editor**
6. ห้ามเปิดให้ลูกค้าเพิ่มตนเองลง `tracker_editors` ผ่าน RLS; การอนุมัติ Editor ทำได้เฉพาะผ่าน SQL Editor โดยผู้ดูแล Supabase

สำหรับผู้ใช้คนอื่น: สมัครบัญชีแล้วจะเป็น Viewer จนกว่าเจ้าของ Supabase จะเพิ่มอีเมลนั้นเข้า `tracker_editors` ด้วย SQL วิธีเดียวกัน

## 5) ทดสอบในเครื่อง

ใช้ VS Code + Live Server เปิด `index.html` หรือใช้เซิร์ฟเวอร์แบบ Static (ไม่แนะนำเปิดตรงเป็น `file://` เพราะมีการเรียก API และใช้ Crypto API)

```bash
# หากติดตั้ง Python ไว้ ใช้แทน Live Server ได้
python -m http.server 5500
```

จากนั้นเปิด `http://localhost:5500/`, ล็อกอิน Editor → **สร้างโปรเจกต์ใหม่** → กรอกชื่อโครงการ, จำนวนสัปดาห์ 1–104 → กรอกรายละเอียดสัปดาห์ และเพิ่มข้อ/งาน

ลองอัปโหลด PNG/JPG/WebP ขนาดไม่เกิน **5 MB ต่อรูป**, เปิดดูรูปผ่าน Signed URL และลองเปลี่ยนสถานะ/บันทึกโน้ต

ถ้าจะทดสอบการสมัคร/กู้รหัสผ่านบน localhost ให้เพิ่ม `http://localhost:5500/` ใน Redirect URLs ของ Supabase ด้วย

## 6) Deploy ด้วย GitHub Pages (เจ้าของ Repository เป็นคนทำ)

1. Push โค้ดไป Repository ของตัวเอง (รวม `config.js` ที่เป็น Publishable Key ของตัวเอง)
2. ไปที่ **Settings → Pages** แล้วเลือก **Deploy from a branch → main → /(root)** หากใช้ Static Pages แบบสาขา
3. เปิด URL `https://YOURNAME.github.io/YOURREPO/`
4. ตั้ง **Site URL / Redirect URLs** ใน Supabase Auth ให้ตรง URL นี้
5. เปิดด้วย Incognito เพื่อตรวจว่าโครงการ/งานอ่านได้สาธารณะ และต้องล็อกอินก่อนดูหลักฐานภาพ

ถ้าต้องการให้คนอื่นกด **Use this template** ได้ ให้เปิด Repository Settings แล้วติ๊ก **Template repository** (GitHub ต้องให้สิทธิ์เจ้าของ Repository)

## ข้อมูลส่วนตัวและสิทธิ์

| ข้อมูล | ผู้ชมทั่วไป | ผู้ใช้ล็อกอิน Viewer | Editor |
|---|---|---|---|
| โครงการ / สัปดาห์ / ข้อ / สถานะ / โน้ต | อ่าน | อ่าน | อ่าน/แก้ |
| ภาพหลักฐานใน Private Bucket | ไม่ได้ | ดูผ่าน Signed URL | ดู/อัปโหลด/ลบ |
| จัดการโครงการและงาน | ไม่ได้ | ไม่ได้ | ได้ |

**ระบบนี้เป็น Public Tracker**: อย่าใส่ข้อมูลส่วนบุคคล รหัสผ่าน หรือข้อมูลลับในชื่อโปรเจกต์/รายละเอียด/โน้ต เพราะใครก็อ่านได้ผ่าน Data API ที่เปิด RLS ให้ SELECT
ผู้มีบัญชี Auth สามารถดูหลักฐานภาพได้ จึงไม่เหมาะกับหลักฐานลับ หากต้องการสิทธิ์ระดับแยกโครงการ ต้องออกแบบ Membership/RLS เพิ่มก่อนใช้งานแบบหลายองค์กร

Editor ทุกคนสามารถแก้โครงการทุกโครงการของ Supabase Project นั้นได้
การลบสัปดาห์/ข้อที่มีรูปหลักฐานจะถูกป้องกัน ต้องลบรูปหลักฐานก่อน

## ปัญหาที่พบบ่อย

- **ยังไม่ได้ตั้งค่า Supabase**: แก้ `config.js` แล้ว Hard Refresh (Ctrl+Shift+R)
- **โหลดฐานข้อมูลไม่ได้**: ตรวจ Project URL, Publishable Key และรัน `supabase/SETUP.sql` ใน Project **เดียวกัน**
- **Viewer แม้สมัครแล้ว**: ยังไม่ได้รัน SQL เพิ่มอีเมลลง `tracker_editors` หรือยังไม่ได้ออก/เข้าสู่ระบบใหม่
- **อัปโหลดรูปไม่ได้**: ต้องเป็น Editor, JPEG/PNG/WebP ไม่เกิน 5 MB และต้องมีข้อก่อน (อัปโหลดโดยเก็บในโฟลเดอร์ UUID ของข้อ)
- **ลิงก์ตั้งรหัสผ่านกลับเว็บผิดหน้า**: ตรวจ Supabase Auth Site URL / Redirect URLs
- **เปิดดูหลักฐานไม่ได้**: ลงชื่อเข้าใช้ก่อน ภาพเก็บใน Private Bucket และใช้ Signed URL ที่มีอายุจำกัด
- **โครงการใหม่สร้างไม่ครบสัปดาห์**: ใช้ปุ่ม “เติมสัปดาห์ว่างตามจำนวนที่กำหนด” ซึ่งช่วยซ่อมเมื่อเครือข่ายขัดข้องกลางการสร้าง

## การทดสอบโค้ด

```bash
node tests/smoke.cjs
```

การทดสอบนี้ตรวจความครบของไฟล์ ค่าตัวอย่าง และ syntax โดย **ไม่ติดต่อ Supabase** การทดสอบเขียนฐานข้อมูลจริงควรทำบน Supabase Project ใหม่ของผู้ติดตั้งเท่านั้น
