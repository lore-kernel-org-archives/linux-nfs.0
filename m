From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH] 2.6 NFS O_DIRECT: should drop inode semaphore
Date: Mon, 8 Mar 2004 10:34:21 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD15@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	type="multipart/alternative";
	boundary="----_=_NextPart_001_01C4053B.F910919D"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0PiV-0003Uf-Vz
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 10:43:07 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B0PaA-0004bs-Ij
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 10:34:30 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4053B.F910919D
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_002_01C4053B.F910919D"


------_=_NextPart_002_01C4053B.F910919D
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

hi trond-

the NFS O_DIRECT path is completely synchronous, as you know.
the VFS layer holds the inode semaphor while calling a file
system's direct_IO method, so this serializes all NFS direct
reads and writes.

i've attached a patch that drops the inode semaphor during
direct reads and writes.  this patch compiles, and the
methodology has been tested in 2.4.  i'd like you to include
this patch in your NFS4_ALL patch to get wider testing before
we ask andrew to include this change in 2.6 kernels.

some have voiced concerns about the combination of O_APPEND
and O_DIRECT, and i've added some logic to address that.

also, i've removed a redundant attribute revalidation.

patch is against 2.6.4-rc2.  comments welcome.

------_=_NextPart_002_01C4053B.F910919D
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.0.6249.1">
<TITLE>[PATCH] 2.6 NFS O_DIRECT: should drop inode semaphore</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>hi trond-</FONT>
</P>

<P><FONT SIZE=3D2>the NFS O_DIRECT path is completely synchronous, as =
you know.</FONT>

<BR><FONT SIZE=3D2>the VFS layer holds the inode semaphor while calling =
a file</FONT>

<BR><FONT SIZE=3D2>system's direct_IO method, so this serializes all NFS =
direct</FONT>

<BR><FONT SIZE=3D2>reads and writes.</FONT>
</P>

<P><FONT SIZE=3D2>i've attached a patch that drops the inode semaphor =
during</FONT>

<BR><FONT SIZE=3D2>direct reads and writes.&nbsp; this patch compiles, =
and the</FONT>

<BR><FONT SIZE=3D2>methodology has been tested in 2.4.&nbsp; i'd like =
you to include</FONT>

<BR><FONT SIZE=3D2>this patch in your NFS4_ALL patch to get wider =
testing before</FONT>

<BR><FONT SIZE=3D2>we ask andrew to include this change in 2.6 =
kernels.</FONT>
</P>

<P><FONT SIZE=3D2>some have voiced concerns about the combination of =
O_APPEND</FONT>

<BR><FONT SIZE=3D2>and O_DIRECT, and i've added some logic to address =
that.</FONT>
</P>

<P><FONT SIZE=3D2>also, i've removed a redundant attribute =
revalidation.</FONT>
</P>

<P><FONT SIZE=3D2>patch is against 2.6.4-rc2.&nbsp; comments =
welcome.</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_002_01C4053B.F910919D--

------_=_NextPart_001_01C4053B.F910919D
Content-Type: TEXT/PLAIN;
	name="01-odirect.patch"
Content-Transfer-Encoding: base64
Content-ID: <Pine.BSO.4.33.0403081326520.17413@citi.umich.edu>
Content-Description: 01-odirect.patch
Content-Disposition: attachment;
	filename="01-odirect.patch"
Content-Location: 1_MULTIPART%3F2_01-odirect.patch

ZGlmZiAtWCAuLi8uLi9kb250LWRpZmYgLU5hdXJwIDAwLXN0b2NrL2ZzL25mcy9kaXJlY3QuYyAw
MS1vZGlyZWN0L2ZzL25mcy9kaXJlY3QuYw0KLS0tIDAwLXN0b2NrL2ZzL25mcy9kaXJlY3QuYwky
MDA0LTAyLTE3IDIyOjU5OjIzLjAwMDAwMDAwMCAtMDUwMA0KKysrIDAxLW9kaXJlY3QvZnMvbmZz
L2RpcmVjdC5jCTIwMDQtMDMtMDggMTM6MjU6MDQuMDk4MjU4MDAwIC0wNTAwDQpAQCAtNDExLDgg
KzQxMSwxMCBAQCBuZnNfZGlyZWN0X3dyaXRlKHN0cnVjdCBpbm9kZSAqaW5vZGUsIHN0DQogICog
YmxvY2tkZXZfZGlyZWN0X0lPLiAgVGhlIE5GUyBjbGllbnQgZG9lc24ndCBoYXZlIGEgYmFja2lu
ZyBibG9jaw0KICAqIGRldmljZSwgc28gd2UgZG8gZXZlcnl0aGluZyBieSBoYW5kIGluc3RlYWQu
DQogICoNCi0gKiBUaGUgaW5vZGUncyBpX3NlbSBpcyBubyBsb25nZXIgaGVsZCBieSB0aGUgVkZT
IGxheWVyIGJlZm9yZSBpdCBjYWxscw0KLSAqIHRoaXMgZnVuY3Rpb24gdG8gZG8gYSB3cml0ZS4N
CisgKiBJZiB0aGUgT19BUFBFTkQgZmxhZyBpcyBzZXQgd2hpbGUgd2UncmUgY2FsbGVkIGZvciBh
IHdyaXRlDQorICogcmVxdWVzdCwgd2UgcmV0dXJuIEVJTlZBTC4gIFdlIGNhbid0IHN0b3AgcmFj
ZXMgd2l0aCBvdGhlcg0KKyAqIGNsaWVudHMgdGhhdCBtaWdodCBjaGFuZ2UgdGhlIGZpbGUgc2l6
ZSBhbmQgY2F1c2UgdXMgdG8NCisgKiBvdmVyd3JpdGUgZGF0YSBhdCB0aGUgZW5kIG9mIHRoZSBm
aWxlLg0KICAqLw0KIGludA0KIG5mc19kaXJlY3RfSU8oaW50IHJ3LCBzdHJ1Y3Qga2lvY2IgKmlv
Y2IsIGNvbnN0IHN0cnVjdCBpb3ZlYyAqaW92LA0KQEAgLTQyOSwyNCArNDMxLDI2IEBAIG5mc19k
aXJlY3RfSU8oaW50IHJ3LCBzdHJ1Y3Qga2lvY2IgKmlvY2INCiAJaWYgKCFpc19zeW5jX2tpb2Ni
KGlvY2IpKQ0KIAkJZ290byBvdXQ7DQogDQotCXJlc3VsdCA9IG5mc19yZXZhbGlkYXRlX2lub2Rl
KE5GU19TRVJWRVIoaW5vZGUpLCBpbm9kZSk7DQotCWlmIChyZXN1bHQgPCAwKQ0KLQkJZ290byBv
dXQ7DQotDQogCXN3aXRjaCAocncpIHsNCiAJY2FzZSBSRUFEOg0KIAkJZHByaW50aygiTkZTOiBk
aXJlY3RfSU8ocmVhZCkgKCVzKSBvZmYvbm8oJUx1LyVsdSlcbiIsDQogCQkJCWRlbnRyeS0+ZF9u
YW1lLm5hbWUsIGZpbGVfb2Zmc2V0LCBucl9zZWdzKTsNCiANCisJCXVwKCZpbm9kZS0+aV9zZW0p
Ow0KIAkJcmVzdWx0ID0gbmZzX2RpcmVjdF9yZWFkKGlub2RlLCBmaWxlLCBpb3YsDQogCQkJCQkJ
ZmlsZV9vZmZzZXQsIG5yX3NlZ3MpOw0KKwkJZG93bigmaW5vZGUtPmlfc2VtKTsNCiAJCWJyZWFr
Ow0KIAljYXNlIFdSSVRFOg0KIAkJZHByaW50aygiTkZTOiBkaXJlY3RfSU8od3JpdGUpICglcykg
b2ZmL25vKCVMdS8lbHUpXG4iLA0KIAkJCQlkZW50cnktPmRfbmFtZS5uYW1lLCBmaWxlX29mZnNl
dCwgbnJfc2Vncyk7DQogDQotCQlyZXN1bHQgPSBuZnNfZGlyZWN0X3dyaXRlKGlub2RlLCBmaWxl
LCBpb3YsDQorCQlpZiAoIShmaWxlLT5mX2ZsYWdzICYgT19BUFBFTkQpKSB7DQorCQkJdXAoJmlu
b2RlLT5pX3NlbSk7DQorCQkJcmVzdWx0ID0gbmZzX2RpcmVjdF93cml0ZShpbm9kZSwgZmlsZSwg
aW92LA0KIAkJCQkJCWZpbGVfb2Zmc2V0LCBucl9zZWdzKTsNCisJCQlkb3duKCZpbm9kZS0+aV9z
ZW0pOw0KKwkJfQ0KIAkJYnJlYWs7DQogCWRlZmF1bHQ6DQogCQlicmVhazsNCg==

------_=_NextPart_001_01C4053B.F910919D--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
