From: Peter Breitenlohner <peb@mppmu.mpg.de>
Subject: nfs-utils-1.0.6
Date: Tue, 7 Oct 2003 13:07:17 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0310071237550.634@pcl321.mppmu.mpg.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1803957763-286064169-1065524837=:634"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A6ph6-0002W5-00
	for <nfs@lists.sourceforge.net>; Tue, 07 Oct 2003 04:07:56 -0700
Received: from pccn7.mppmu.mpg.de ([134.107.24.11])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A6ph2-0002ZM-Ri
	for nfs@lists.sourceforge.net; Tue, 07 Oct 2003 04:07:53 -0700
Received: from pcl321.mppmu.mpg.de (pcl321.mppmu.mpg.de [134.107.3.54])
	by pccn7.mppmu.mpg.de (Postfix) with ESMTP id E05ECBDBC
	for <nfs@lists.sourceforge.net>; Tue,  7 Oct 2003 13:07:17 +0200 (CEST)
Received: from pcl321.mppmu.mpg.de (localhost [127.0.0.1])
	by pcl321.mppmu.mpg.de (8.12.9/8.12.9) with ESMTP id h97B7HmV004697
	for <nfs@lists.sourceforge.net>; Tue, 7 Oct 2003 13:07:17 +0200
Received: from localhost (peb@localhost)
	by pcl321.mppmu.mpg.de (8.12.9/8.12.9/Submit) with ESMTP id h97B7HBc004694
	for <nfs@lists.sourceforge.net>; Tue, 7 Oct 2003 13:07:17 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1803957763-286064169-1065524837=:634
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

please consider the attached patch for nfs-utils-1.0.6.
Two comments:

(1) just a typo (some leftover old text) in the mountd manpage.

(2) IMHO, there is no really good reason to use the distributed rpcgen
(basically from 1999) when there is a perfectly good and newer one from
glibc-2.x.y (x>1), e.g., glibc-2.2.5 from 2001, glibc-2.3.2 from 2002 (or
from netkit-rpc-0.17 for libc5). Of course, my patch for this is crude, and
nfs-utils probably ought to test for a good installed rpcgen and fall back
to the distributed one if nothing else is available.

regards
Peter Breitenlohner <peb@mppmu.mpg.de>
--1803957763-286064169-1065524837=:634
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="nfs-utils-1.0.6-patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0310071307170.634@pcl321.mppmu.mpg.de>
Content-Description: 
Content-Disposition: attachment; filename="nfs-utils-1.0.6-patch"

ZGlmZiAtdXIgbmZzLXV0aWxzLTEuMC42Lm9yaWcvY29uZmlnLm1rLmluIG5m
cy11dGlscy0xLjAuNi9jb25maWcubWsuaW4NCi0tLSBuZnMtdXRpbHMtMS4w
LjYub3JpZy9jb25maWcubWsuaW4JMjAwMy0wNy0wNCAwNTo0MzozMy4wMDAw
MDAwMDAgKzAyMDANCisrKyBuZnMtdXRpbHMtMS4wLjYvY29uZmlnLm1rLmlu
CTIwMDMtMTAtMDcgMTE6NTE6MDguMDAwMDAwMDAwICswMjAwDQpAQCAtNTIs
NyArNTIsNyBAQA0KIExOX1MJCT0gbG4gLXNmDQogUkFOTElCCQk9IEBSQU5M
SUJADQogSU5ERU5UCQk9IGluZGVudA0KLVJQQ0dFTgkJPSAkKFRPUCliaW4v
cnBjZ2VuDQorUlBDR0VOCQk9IHJwY2dlbg0KIEdFVEtWRVIJCT0gJChUT1Ap
dG9vbHMvZ2V0a3ZlcnNpb24NCiBJTlNUQUxMCQk9IGluc3RhbGwNCiBNQU4y
UFMJCT0gZ3JvZmYgLVRwcyAtbWFuDQpkaWZmIC11ciBuZnMtdXRpbHMtMS4w
LjYub3JpZy90b29scy9NYWtlZmlsZSBuZnMtdXRpbHMtMS4wLjYvdG9vbHMv
TWFrZWZpbGUNCi0tLSBuZnMtdXRpbHMtMS4wLjYub3JpZy90b29scy9NYWtl
ZmlsZQkyMDAwLTAzLTIxIDAxOjQ2OjE4LjAwMDAwMDAwMCArMDEwMA0KKysr
IG5mcy11dGlscy0xLjAuNi90b29scy9NYWtlZmlsZQkyMDAzLTEwLTA3IDEx
OjUxOjM2LjAwMDAwMDAwMCArMDIwMA0KQEAgLTIsNyArMiw3IEBADQogIyBW
YXJpb3VzIGRlYnVnZ2luZy90ZXN0aW5nIHRvb2xzDQogIw0KIA0KLVNVQkRJ
UlMJPSBycGNnZW4gZ2V0aXZlcnNpb24gZ2V0a3ZlcnNpb24gIHJwY2RlYnVn
IGxvY2t0ZXN0DQorU1VCRElSUwk9IGdldGl2ZXJzaW9uIGdldGt2ZXJzaW9u
ICBycGNkZWJ1ZyBsb2NrdGVzdA0KICMgbmxtdGVzdCBkb2Vzbid0IHdvcmsg
DQogDQogaW5jbHVkZSAkKFRPUClydWxlcy5taw0KZGlmZiAtdXIgbmZzLXV0
aWxzLTEuMC42Lm9yaWcvdXRpbHMvbW91bnRkL21vdW50ZC5tYW4gbmZzLXV0
aWxzLTEuMC42L3V0aWxzL21vdW50ZC9tb3VudGQubWFuDQotLS0gbmZzLXV0
aWxzLTEuMC42Lm9yaWcvdXRpbHMvbW91bnRkL21vdW50ZC5tYW4JMjAwMy0w
Ny0xOCAwMToxNzoyOC4wMDAwMDAwMDAgKzAyMDANCisrKyBuZnMtdXRpbHMt
MS4wLjYvdXRpbHMvbW91bnRkL21vdW50ZC5tYW4JMjAwMy0xMC0wNyAxMTo1
MjoxNC4wMDAwMDAwMDAgKzAyMDANCkBAIC00NCw3ICs0NCw2IEBADQogYWRk
cyBhbiBlbnRyeSB0byB0aGUNCiAuQiAvdmFyL2xpYi9uZnMvcm10YWINCiBm
aWxlLiBXaGVuIHJlY2VpdmluZyBhbiB1bm1vdW50IHJlcXVlc3QsIHRoYXQg
ZW50cnkgaXMgcmVtb3ZlZC4NCi11c2VyIGxldmVsIHBhcnQgb2YgdGhlIE5G
UyBzZXJ2aWNlLg0KIC5QDQogSG93ZXZlciwgdGhpcyBmaWxlIGlzIG1vc3Rs
eSBvcm5hbWVudGFsLiBPbmUsIHRoZSBjbGllbnQgY2FuIGNvbnRpbnVlDQog
dG8gdXNlIHRoZSBmaWxlIGhhbmRsZSBldmVuIGFmdGVyIGNhbGxpbmcNCg==

--1803957763-286064169-1065524837=:634--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
