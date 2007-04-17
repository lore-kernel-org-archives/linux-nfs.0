From: "Henk Schouten" <hschouten@fugro-jason.com>
Subject: File locking
Date: Tue, 17 Apr 2007 14:01:01 +0200
Message-ID: <F42290EAAE100A4A99A3A9BE2059504F026463A9@MAIL.fugro-jason.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C780E8.119F1E9F"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdmNK-00014u-QL
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 05:01:36 -0700
Received: from smtp.eu1.fugro.com ([212.189.46.151])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdmNL-0007a9-N9
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 05:01:37 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

------_=_NextPart_001_01C780E8.119F1E9F
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_002_01C780E8.119F1E9F"


------_=_NextPart_002_01C780E8.119F1E9F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I run into a file locking problem that seems to be NFS related.
I created a test program that exhibits the problem (see attachment).
The program adds a number to a sorted list on a file and check if the =
file is
still sorted after each iteration. You need to have an empty file =
upfront.
As long as you run on one machine you can happily add as many processes =
as
you want. As soon as you start the process on a different machine, you =
get
the "File corrupted" error.
=20
Happens on SUN  and Linux . Explicitly unlocking the file does not help. =

Doe anyone have an idea why this fails?=20
=20
Thanks,
Henk Schouten

------_=_NextPart_002_01C780E8.119F1E9F
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2963" name=3DGENERATOR></HEAD>
<BODY>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial size=3D2><SPAN =
class=3D848535611-17042007>I=20
run into a file locking problem that seems to be NFS=20
related.</SPAN></FONT></DIV>
<DIV></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D614550808-17042007>I =
created a test=20
program that exhibits the problem (see attachment).</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D614550808-17042007>The =
program adds a=20
number to a sorted list on a file and check if the file is still sorted =
after=20
each iteration. You need to have an empty file =
upfront.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D614550808-17042007>As =
long as you run=20
on one machine you can happily add as many processes as you want. As =
soon as you=20
start the process on a different machine, you get the "File corrupted"=20
error.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D614550808-17042007></SPAN></FONT>&nbsp;</DIV>
<DIV><SPAN class=3D614550808-17042007><FONT face=3DArial><FONT =
size=3D2><SPAN=20
class=3D848535611-17042007>H</SPAN>appens on SUN<SPAN=20
class=3D848535611-17042007>&nbsp; and Linux&nbsp;</SPAN>. Explicitly =
unlocking the=20
file does not help.<SPAN=20
class=3D848535611-17042007>&nbsp;</SPAN></FONT></FONT></SPAN></DIV>
<DIV><SPAN class=3D614550808-17042007><FONT face=3DArial><FONT =
size=3D2><SPAN=20
class=3D848535611-17042007>Doe anyone have an idea why this=20
fails?&nbsp;</SPAN></FONT></FONT></SPAN></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D614550808-17042007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D614550808-17042007><SPAN=20
class=3D848535611-17042007>Thanks,</SPAN></SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D614550808-17042007><SPAN=20
class=3D848535611-17042007>Henk =
Schouten</SPAN></SPAN></FONT></DIV></BODY></HTML>

------_=_NextPart_002_01C780E8.119F1E9F--

------_=_NextPart_001_01C780E8.119F1E9F
Content-Type: application/octet-stream;
	name="main.cpp"
Content-Transfer-Encoding: base64
Content-Description: main.cpp
Content-Disposition: attachment;
	filename="main.cpp"

I2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3N0YXQuaD4KI2luY2x1ZGUgPHVu
aXN0ZC5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8
c3RkaW8uaD4KCiNkZWZpbmUJTlVNSVRFUlMJMTAwMDAwCgp2b2lkCnVwZGF0ZSgpCnsKCWludAkJ
CWZkLCBpLCBpY3VyLCBuOwoJc3RydWN0IHN0YXQJYnVmOwoJaW50CQkJKm51bXM7CglzdHJ1Y3Qg
ZmxvY2sgbGNrOwoKCS8vIE51bWJlciB0byBhZGQKCWludAl0b2FkZCA9IHJhbmQoKTsKCgkvLyBP
cGVuIGFuZCByZWFkIGZpbGUKCWZkID0gb3BlbigiZmlsZSIsIE9fUkRXUiB8IE9fRVhDTCk7Cglp
ZiAoZmQgPCAwKQoJewoJCWZwcmludGYoc3RkZXJyLCAiQ2Fubm90IG9wZW4gZmlsZVxuIik7CgkJ
ZXhpdCgwKTsKCX0KCglsY2subF90eXBlID0gRl9XUkxDSzsKCWxjay5sX3doZW5jZSA9IDA7Cgls
Y2subF9zdGFydCA9IDA7CglsY2subF9sZW4gPSAwOwoJbGNrLmxfcGlkID0gZ2V0cGlkKCk7Cglu
ID0gZmNudGwoZmQsIEZfU0VUTEtXLCAmbGNrKTsKCWlmIChuIDwgMCkKCXsKCQlmcHJpbnRmKHN0
ZGVyciwgIkNhbm5vdCBzZXQgbG9jayBvbiBmaWxlXG4iKTsKCQlleGl0KDApOwoJfQoKCW4gPSBm
c3RhdChmZCwgJmJ1Zik7CglpZiAobiA8IDApCgl7CgkJZnByaW50ZihzdGRlcnIsICJDYW5ub3Qg
ZnN0YXQgZmlsZVxuIik7CgkJZXhpdCgwKTsKCX0KCWVsc2UKCQluID0gYnVmLnN0X3NpemUgLyBz
aXplb2YoaW50KTsKCgludW1zID0gbmV3IGludFtuICsgMV07CglpID0gcmVhZChmZCwgbnVtcywg
biAqIHNpemVvZihpbnQpKTsKCWlmIChpICE9IG4gKiBzaXplb2YoaW50KSkKCXsKCQlmcHJpbnRm
KHN0ZGVyciwgIkNhbm5vdCByZWFkIGZpbGVcbiIpOwoJCWV4aXQoMCk7Cgl9CgoJLy8gQ2hlY2sg
ZmlsZQoJZm9yIChpID0gMTsgaSA8IG47IGkrKykKCXsKCQlpZiAobnVtc1tpXSA8PSBudW1zW2kt
MV0pCgkJewoJCQlmcHJpbnRmKHN0ZGVyciwgIkZpbGUgY29ycnVwdGVkXG4iKTsKCQkJZXhpdCgw
KTsKCQl9Cgl9CgoJLy8gSW5zZXJ0IG5ldyBudW1iZXIgaW50byBudW1zCglmb3IgKGljdXIgPSAw
OyBpY3VyIDwgbjsgaWN1cisrKQoJewoJCWlmIChudW1zW2ljdXJdID49IHRvYWRkKQoJCQlicmVh
azsKCX0KCWlmIChpY3VyID49IG4pCgl7CgkJbnVtc1tuXSA9IHRvYWRkOwoJCW4rKzsKCX0KCWVs
c2UgaWYgKG51bXNbaWN1cl0gIT0gdG9hZGQpCgl7CgkJZm9yIChpID0gbjsgaSA+IGljdXI7IGkt
LSkKCQkJbnVtc1tpXSA9IG51bXNbaS0xXTsKCQludW1zW2ljdXJdID0gdG9hZGQ7CgkJbisrOwoJ
fQoKCS8vIFdyaXRlIGJhY2sgcmVzdWx0cwoJaWYgKGxzZWVrKGZkLCAwLCAwKSA8IDApCgl7CgkJ
ZnByaW50ZihzdGRlcnIsICJDYW5ub3QgbHNlZWsgZmlsZVxuIik7CgkJZXhpdCgwKTsKCX0KCWlm
ICh3cml0ZShmZCwgbnVtcywgbiAqIHNpemVvZihpbnQpKSAhPSBuICogc2l6ZW9mKGludCkpCgl7
CgkJZnByaW50ZihzdGRlcnIsICJDYW5ub3Qgd3JpdGUgZmlsZVxuIik7CgkJZXhpdCgwKTsKCX0K
CWRlbGV0ZSBbXSBudW1zOwoKCS8vbGNrLmxfdHlwZSA9IEZfVU5MQ0s7CgkvL24gPSBmY250bChm
ZCwgRl9TRVRMSywgJmxjayk7CgljbG9zZShmZCk7Cn0KCmludAptYWluKCkKewoJc3JhbmQoZ2V0
cGlkKCkpOwoJZm9yIChpbnQgaSA9IDA7IGkgPCBOVU1JVEVSUzsgaSsrKQoJewoJCXVwZGF0ZSgp
OwoJCXByaW50ZigiU28gZmFyIHNvIGdvb2QgJWRcbiIsIGkpOwoJfQoJcmV0dXJuIDA7Cn0K

------_=_NextPart_001_01C780E8.119F1E9F
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
------_=_NextPart_001_01C780E8.119F1E9F
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------_=_NextPart_001_01C780E8.119F1E9F--
