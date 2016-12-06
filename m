Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gws05.hcl.com ([203.105.185.23]:30232 "EHLO GWS05.hcl.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751556AbcLFQMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 11:12:20 -0500
From: Brian Cowan <brian.cowan@hcl.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: FW: File lock performance over NFSv4 degrades dramatically when lock
 contention is present.
Date: Tue, 6 Dec 2016 15:58:52 +0000
Message-ID: <HK2PR0401MB1570ACF852B10ADA56DB0059FE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
References: <HK2PR0401MB157008D9798FDBF609C616EEFE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
In-Reply-To: <HK2PR0401MB157008D9798FDBF609C616EEFE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
Content-Type: multipart/mixed;
        boundary="_002_HK2PR0401MB1570ACF852B10ADA56DB0059FE820HK2PR0401MB1570_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_HK2PR0401MB1570ACF852B10ADA56DB0059FE820HK2PR0401MB1570_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello all, =


On moving an application that uses file locking from NFSv3 to NFSV4, we fou=
nd that file lock/unlock times can vary wildly when lock contention is pres=
ent. Our application has multiple files that have to be locked in the remot=
e filesystem. When multiple instances (as few as 2) of the application comp=
onents are running and sharing these files we are seeing lock delays in sec=
onds as opposed to milli/microseconds. =


We can reproduce this in multiple Linux versions (At least SuSE 11, SuSE 12=
, Ubuntu 14.04, Red Hat 7.x), and multiple NFS servers (Linux, Solaris, Net=
App) and the issue only occurs on NFSv4 mounts. Mounting the exact same fil=
esystem via NFSv3 eliminates the issue. We're reasonably certain that this =
is not a client configuration issue as additional customers are coming out =
of the woodwork reporting the problem. We're also reasonably certain that t=
his is not a server issue since it's happening across multiple server platf=
orms. =


To reproduce this outside of our application, a coworker wrote a simple loc=
k test program (attached). When one instance of this program is run on an a=
ffected host, the lock times are < 1000us. If you then start a second insta=
nce of the application, the lock wait times have reached as long as 3 MINUT=
ES. Unlocking doesn't take anywhere near as long, where the maximum observe=
d unlock time being about 23 ms. =


Process we used to prove this:
1) Compiled the attached source.
2) Mounted a remote filesystem via NFSv4 (example: /mnt/nfsv4)
3) Created a temp file with 777 permissions. (/mnt/nfsv4/foo)
4) Ran one instance of the tool, redirecting the output to /tmp:
./lock1 /mnt/nfsv4/foo >> /tmp/zz1 &
5) Checked lock times after 20 seconds: =

sort -rn -k3 < /tmp/zz1 | more
6) Started a second instance of the tool
./lock1 /mnt/nfsv4/foo >> /tmp/zz2 &
7) Check the lock times again, using both files:
sort -rn -k3 < /tmp/zz1 | more
sort -rn -k3 < /tmp/zz2 | more

What we saw was lock calls moving from the < 1000 us range to (as my cowork=
er put it) "integral numbers of seconds." Not every lock stalls for integra=
l numbers of seconds, but enough of them do to stall our application. Even =
the small percentage of > 1 second lock/unlock calls causes problems as we =
do a lot of file locking. =


Any/all diagnostic assistance would be greatly appreciated.


::DISCLAIMER::
---------------------------------------------------------------------------=
-------------------------------------------------------------------------

The contents of this e-mail and any attachment(s) are confidential and inte=
nded for the named recipient(s) only.
E-mail transmission is not guaranteed to be secure or error-free as informa=
tion could be intercepted, corrupted,
lost, destroyed, arrive late or incomplete, or may contain viruses in trans=
mission. The e mail and its contents
(with or without referred errors) shall therefore not attach any liability =
on the originator or HCL or its affiliates.
Views or opinions, if any, presented in this email are solely those of the =
author and may not necessarily reflect the
views or opinions of HCL or its affiliates. Any form of reproduction, disse=
mination, copying, disclosure, modification,
distribution and / or publication of this message without the prior written=
 consent of authorized representative of
HCL is strictly prohibited. If you have received this email in error please=
 delete it and notify the sender immediately.
Before opening any email and/or attachments, please check them for viruses =
and other defects.

---------------------------------------------------------------------------=
-------------------------------------------------------------------------

--_002_HK2PR0401MB1570ACF852B10ADA56DB0059FE820HK2PR0401MB1570_
Content-Type: text/plain; name="lock1.c"
Content-Description: lock1.c
Content-Disposition: attachment; filename="lock1.c"; size=1880;
	creation-date="Tue, 06 Dec 2016 13:52:13 GMT";
	modification-date="Tue, 06 Dec 2016 13:52:13 GMT"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8dW5pc3RkLmg+
CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5cy90aW1lLmg+CgojZGVmaW5lIE1B
WEJVRiA0MDk2CgptYWluKGFyZ2MsIGFyZ3YpCmludCBhcmdjOwpjaGFyICphcmd2W107CnsKCiAg
ICBpbnQgaTsKICAgIGludCBmZDsKICAgIHBpZF90IHBpZDsKICAgIGludCBzbGVlcF90aW1lOwog
ICAgaW50IHRpbWVfdGFrZW49MDsKICAgIGNoYXIgYnVmZmVyW01BWEJVRl07CiAgICBzdHJ1Y3Qg
dGltZXZhbCB0MSwgdDI7CgogICAgc2V0YnVmKHN0ZG91dCwgTlVMTCk7CiAgICAvKiBQb3B1bGF0
ZSBuZXcgYmxvY2sgKi8KICAgIGZvcihpPTA7IGk8TUFYQlVGOyBpKyspCiAgICAgICBidWZmZXJb
aV09J2MnOwoKICAgIC8qIGEgc2luZ2xlIGFyZyAgLSB0aGUgIGZpbGVuYW1lKi8KICAgIGlmIChh
cmdjICE9IDIpewogICAgICAgZnByaW50ZihzdGRlcnIsICJ1c2FnZTogJXMgPGZpbGU+XG4iLCBh
cmd2WzBdKTsKICAgICAgIF9leGl0KDIpOwogICAgfQoKICAgIC8qIENoZWNrIGFyZyBpcyBhIGZp
bGUgY2FuIG9wZW4gci93ICovCiAgICBpZiAoKGZkPW9wZW4oYXJndlsxXSwgT19SRFdSLCAwNzc3
KSkgPDApIHsKICAgICAgIGZwcmludGYoc3RkZXJyLCAiY291bGQgbm90IGNyZWF0ZS9vcGVuICVz
IFxuIiwgYXJndlsxXSk7CiAgICAgICBfZXhpdCgxKTsKICAgIH0KCgogICAgLyogTG9vcCBmb3Jl
dmVyICovCiAgICB3aGlsZSgxKXsKICAgICAgICAgICAvKiBSZXNldCBmaWxlIHBvaW50ZXIgdG8g
c3RhcnQgb2YgZmlsZSAqLwogICAgICAgICAgIGlmIChsc2VlayhmZCwgMCwgU0VFS19TRVQpIDwg
MCkgewogICAgICAgICAgICAgIGZwcmludGYoc3RkZXJyLCAiY291bGQgbm90IHNlZWsgdG8gYmVn
aW5uaW5nIG9mICVzXG4iLCBhcmd2WzFdKTsKICAgICAgICAgICAgICBfZXhpdCgxKTsKICAgICAg
ICAgICB9CgogICAgICAgICAgIC8qIExvY2sgZW50aXJlIGZpbGUgZm9yIGV4Y2x1c2l2ZSBhY2Nl
c3MgIGFuZCB0aW1lIGhvdyBsb25nIGl0IHRha2VzIHRvIGdldCBsb2NrKi8KICAgICAgICAgICBn
ZXR0aW1lb2ZkYXkoJnQxLCBOVUxMKTsKICAgICAgICAgICBpZiAobG9ja2YoZmQsIEZfTE9DSywg
MCkgPCAwKSB7CiAgICAgICAgICAgICAgZnByaW50ZihzdGRlcnIsICJjb3VsZCBub3QgbG9jayB3
aG9sZSBmaWxlICVzXG4iLCBhcmd2WzFdKTsKICAgICAgICAgICAgICBfZXhpdCgxKTsKICAgICAg
ICAgICB9CiAgICAgICAgICAgZ2V0dGltZW9mZGF5KCZ0MiwgTlVMTCk7CiAgICAgICAgICAgdGlt
ZV90YWtlbj0odDIudHZfc2VjIC0gdDEudHZfc2VjKSoxMDAwMDAwICsgKHQyLnR2X3VzZWMgLSB0
MS50dl91c2VjKTsKICAgICAgICAgICAgICBwcmludGYoImxvY2tmKCkgdG9vayAgJWQgdXNcbiIs
IHRpbWVfdGFrZW4pOwoKICAgICAgICAgICAvKiBVbmxvY2sgZmlsZSAgYW5kIHRpbWUgaG93IGxv
bmcgdGhhdCB0YWtlcyovCiAgICAgICAgICAgZ2V0dGltZW9mZGF5KCZ0MSwgTlVMTCk7CiAgICAg
ICAgICAgaWYgKGxvY2tmKGZkLCBGX1VMT0NLLCAwKSA8IDApIHsKICAgICAgICAgICAgICBmcHJp
bnRmKHN0ZGVyciwgImNvdWxkIG5vdCB1bmxvY2sgZmlsZSAlc1xuIiwgYXJndlsxXSk7CiAgICAg
ICAgICAgICAgX2V4aXQoMSk7CiAgICAgICAgICAgfQogICAgICAgICAgIGdldHRpbWVvZmRheSgm
dDIsIE5VTEwpOwogICAgICAgICAgIHRpbWVfdGFrZW49KHQyLnR2X3NlYyAtIHQxLnR2X3NlYykq
MTAwMDAwMCArICh0Mi50dl91c2VjIC0gdDEudHZfdXNlYyk7CiAgICAgICAgICAgICAgcHJpbnRm
KCJ1bmxvY2soKSB0b29rICVkIHVzXG4iLCB0aW1lX3Rha2VuKTsKCiAgfQpfZXhpdCgwKTsKfQo=

--_002_HK2PR0401MB1570ACF852B10ADA56DB0059FE820HK2PR0401MB1570_--

