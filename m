Received: from rcsinet10.oracle.com ([148.87.113.121]:33670 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab0LIAUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 19:20:12 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "stefan.bader@canonical.com" <stefan.bader@canonical.com>
CC: "bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>, Trond Myklebust
	<trond.myklebust@fys.uio.no>, Linux NFS Mailing List
	<linux-nfs@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Chuck
 Lever <chuck.lever@oracle.com>
Subject: Re: [Bug 24302] Kernel crashes when repeatedly trying to mount nfs
 share that is failing
Sender: "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Date: Wed, 8 Dec 2010 19:20:16 -0500
Message-ID: <A205A7F2-6E7C-4129-BC3A-D2AE5E38DFE6@oracle.com>
References: <bug-24302-104@https.bugzilla.kernel.org/>
 <201012081830.oB8IUZ4t027387@demeter2.kernel.org>
 <1291835010.3067.4.camel@heimdal.trondhjem.org>
 <3F9D016C-9EDF-4B65-AD77-F225D5F1FA66@oracle.com>
In-Reply-To: <3F9D016C-9EDF-4B65-AD77-F225D5F1FA66@oracle.com>
Content-Type: multipart/mixed;
	boundary="_002_A205A7F26E7C4129BC3AD2AE5E38DFE6oraclecom_"
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--_002_A205A7F26E7C4129BC3AD2AE5E38DFE6oraclecom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <44F33D8713D8C6469960496B924BDA5A@namprd02.prod.outlook.com>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
</head>
<body>
<div class="BodyFragment"><font size="2"><span style="font-size:11pt;">
<div class="PlainText">Hi Stefan-<br>
<br>
On Dec 8, 2010, at 3:35 PM, Chuck Lever wrote:<br>
<br>
&gt; <br>
&gt; On Dec 8, 2010, at 2:03 PM, Trond Myklebust wrote:<br>
&gt; <br>
&gt;&gt; On Wed, 2010-12-08 at 18:30 &#43;0000, bugzilla-daemon@bugzilla.kernel.org<br>
&gt;&gt; wrote:<br>
&gt;&gt;&gt; <a href="https://bugzilla.kernel.org/show_bug.cgi?id=24302">https://bugzilla.kernel.org/show_bug.cgi?id=24302</a><br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; Andrew Morton &lt;akpm@linux-foundation.org&gt; changed:<br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; What&nbsp;&nbsp;&nbsp; |Removed&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |Added<br>
&gt;&gt;&gt; ----------------------------------------------------------------------------<br>
&gt;&gt;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Component|Other&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |NFS<br>
&gt;&gt;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; AssignedTo|fs_other@kernel-bugs.osdl.o |trond.myklebust@fys.uio.no<br>
&gt;&gt;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |rg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; --- Comment #8 from Andrew Morton &lt;akpm@linux-foundation.org&gt;&nbsp; 2010-12-08 18:30:32 ---<br>
&gt;&gt;&gt; OK, I reassigned it to NFS.&nbsp; If that was wrong then at least the NFS guys<br>
&gt;&gt;&gt; should be able to help point things in the right direction.<br>
&gt;&gt; <br>
&gt;&gt; &lt;Switching to email interface. Please do not edit the bugzilla entry<br>
&gt;&gt; directly, since that will lose the above Cc information&gt;<br>
&gt;&gt; <br>
&gt;&gt; <br>
&gt;&gt; Chuck,<br>
&gt;&gt; <br>
&gt;&gt; Stefan appears to be hitting a panic in the nfs_umount() call from<br>
&gt;&gt; nfs_walk_authlist(). Can you take a look, please?<br>
&gt; <br>
&gt; Recv'd.&nbsp; I'll have a look.<br>
<br>
Apologies in advance for the attachment.&nbsp; There are a few other clean ups that can be done, but this seems to be the minimal fix.&nbsp; Please try this and let us know if it addresses your panic.<br>
<br>
</div>
</span></font></div>
<div class="BodyFragment"><font size="2"><span style="font-size:11pt;">
<div class="PlainText"><br>
<br>
The faulty commit went in a while back, so this patch is probably appropriate for stable kernels (back to 2.6.31, where this was likely introduced).<br>
<br>
-- <br>
Chuck Lever<br>
chuck[dot]lever[at]oracle[dot]com<br>
<br>
<br>
<br>
<br>
</div>
</span></font></div>
</body>
</html>

--_002_A205A7F26E7C4129BC3AD2AE5E38DFE6oraclecom_
Content-Type: application/octet-stream; name="diff"
Content-Description: diff
Content-Disposition: attachment; filename="diff"; size=1967;
	creation-date="Thu, 25 Jan 2018 00:17:58 GMT";
	modification-date="Thu, 25 Jan 2018 00:17:58 GMT"
Content-ID: <A4ED228F77268B4093713CA56AF06F4F@namprd02.prod.outlook.com>
Content-Transfer-Encoding: base64

Y29tbWl0IDA3MTZkNDAyMDU0NDhjMzczMDdjMmU0OTdlNGU0MzE2ZmI5OTE3ZWENCkF1dGhvcjog
Q2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9yYWNsZS5jb20+DQpEYXRlOiAgIFdlZCBEZWMgOCAx
OTowNzoxMiAyMDEwIC0wNTAwDQoNCiAgICBORlM6IEZpeCBwYW5pYyBhZnRlciBuZnNfdW1vdW50
KCkNCiAgICANCiAgICBBZnRlciBhIGZldyB1bnN1Y2Nlc3NmdWwgTkZTIG1vdW50IGF0dGVtcHRz
IGluIHdoaWNoIHRoZSBjbGllbnQgYW5kDQogICAgc2VydmVyIGNhbm5vdCBhZ3JlZSBvbiBhbiBh
dXRoZW50aWNhdGlvbiBmbGF2b3IgYm90aCBzdXBwb3J0LCB0aGUNCiAgICBjbGllbnQgcGFuaWNz
LiAgbmZzX3Vtb3VudCgpIGlzIGludm9rZWQgaW4gdGhlIGtlcm5lbCBpbiB0aGlzIGNhc2UuDQog
ICAgDQogICAgVHVybnMgb3V0IHRoaXMgcGFydGljdWxhciBVTU5UIFJQQyBpbnZvY2F0aW9uIGNh
dXNlcyB0aGUgUlBDIGNsaWVudCB0bw0KICAgIHdyaXRlIG9mZiB0aGUgZW5kIG9mIHRoZSBycGNf
Y2xudCdzIGlvc3RhdCBhcnJheS4gIFRoaXMgaXMgYmVjYXVzZSB0aGUNCiAgICBtb3VudCBjbGll
bnQncyBucnByb2NzIGZpZWxkIGlzIGluaXRpYWxpemVkIHdpdGggdGhlIGNvdW50IG9mIGRlZmlu
ZWQNCiAgICBwcm9jZWR1cmVzICh0d286IE1OVCBhbmQgVU1OVCksIHJhdGhlciB0aGFuIHRoZSBz
aXplIG9mIHRoZSBjbGllbnQncw0KICAgIHByb2MgYXJyYXkgKGZvdXIpLg0KICAgIA0KICAgIFRo
ZSBmaXggaXMgdG8gdXNlIHRoZSBzYW1lIGluaXRpYWxpemF0aW9uIHRlY2huaXF1ZSB1c2VkIGJ5
IG1vc3Qgb3RoZXINCiAgICB1cHBlciBsYXllciBjbGllbnRzIGluIHRoZSBrZXJuZWwuDQogICAg
DQogICAgSW50cm9kdWNlZCBieSBjb21taXQgMGI1MjQxMjMsIHdoaWNoIGZhaWxlZCB0byB1cGRh
dGUgbnJwcm9jcyB3aGVuIGl0DQogICAgYWRkZWQgc3VwcG9ydCBmb3IgVU1OVC4NCiAgICANCiAg
ICBTZWUgYWxzbzoNCiAgICANCiAgICAgIGh0dHBzOi8vYnVnemlsbGEua2VybmVsLm9yZy9zaG93
X2J1Zy5jZ2k/aWQ9MjQzMDINCiAgICANCiAgICBSZXBvcnRlZC1ieTogU3RlZmFuIEJhZGVyIDxz
dGVmYW4uYmFkZXJAY2Fub25pY2FsLmNvbT4NCiAgICBTaWduZWQtb2ZmLWJ5OiBDaHVjayBMZXZl
ciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCg0KZGlmZiAtLWdpdCBhL2ZzL25mcy9tb3VudF9j
bG50LmMgYi9mcy9uZnMvbW91bnRfY2xudC5jDQppbmRleCBlOGQzOTBjLi4xNmRhNDU3IDEwMDY0
NA0KLS0tIGEvZnMvbmZzL21vdW50X2NsbnQuYw0KKysrIGIvZnMvbmZzL21vdW50X2NsbnQuYw0K
QEAgLTQ5MiwxMyArNDkyLDEzIEBAIHN0YXRpYyBzdHJ1Y3QgcnBjX3Byb2NpbmZvIG1udDNfcHJv
Y2VkdXJlc1tdID0gew0KIA0KIHN0YXRpYyBzdHJ1Y3QgcnBjX3ZlcnNpb24gbW50X3ZlcnNpb24x
ID0gew0KIAkubnVtYmVyCQk9IDEsDQotCS5ucnByb2NzCT0gMiwNCisJLm5ycHJvY3MJPSBBUlJB
WV9TSVpFKG1udF9wcm9jZWR1cmVzKSwNCiAJLnByb2NzCQk9IG1udF9wcm9jZWR1cmVzLA0KIH07
DQogDQogc3RhdGljIHN0cnVjdCBycGNfdmVyc2lvbiBtbnRfdmVyc2lvbjMgPSB7DQogCS5udW1i
ZXIJCT0gMywNCi0JLm5ycHJvY3MJPSAyLA0KKwkubnJwcm9jcwk9IEFSUkFZX1NJWkUobW50X3By
b2NlZHVyZXMpLA0KIAkucHJvY3MJCT0gbW50M19wcm9jZWR1cmVzLA0KIH07DQogDQo=

--_002_A205A7F26E7C4129BC3AD2AE5E38DFE6oraclecom_--
