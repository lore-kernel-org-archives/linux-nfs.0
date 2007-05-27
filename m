From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] NFSD: fix uninitialized variable
Date: Sun, 27 May 2007 06:34:42 -0400
Message-ID: <20070527103442.GA10594@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>, neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HsG5I-0002v9-Nm
	for nfs@lists.sourceforge.net; Sun, 27 May 2007 03:34:48 -0700
Received: from havoc.gtf.org ([69.61.125.42])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HsG5K-0004EV-IH
	for nfs@lists.sourceforge.net; Sun, 27 May 2007 03:34:51 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

ClVubGlrZSBtYW55IG9mIHRoZSBib2d1cyB3YXJuaW5ncyBzcGV3ZWQgYnkgZ2NjLCB0aGlzIG9u
ZSBhY3R1YWxseQpjb21wbGFpbnMgYWJvdXQgYSByZWFsIGJ1ZzoKCmZzL25mc2QvbmZzNGFjbC5j
OiBJbiBmdW5jdGlvbiDigJhfcG9zaXhfdG9fbmZzdjRfb25l4oCZOgpmcy9uZnNkL25mczRhY2wu
YzoyMjc6IHdhcm5pbmc6IOKAmHBhcy5vd25lcuKAmSBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVk
IGluIHRoaXMgZnVuY3Rpb24KZnMvbmZzZC9uZnM0YWNsLmM6MjI3OiB3YXJuaW5nOiDigJhwYXMu
Z3JvdXDigJkgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uCmZzL25m
c2QvbmZzNGFjbC5jOjIyNzogd2FybmluZzog4oCYcGFzLm90aGVy4oCZIG1heSBiZSB1c2VkIHVu
aW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbgoKU2lnbmVkLW9mZi1ieTogSmVmZiBHYXJ6aWsg
PGplZmZAZ2FyemlrLm9yZz4KCmRpZmYgLS1naXQgYS9mcy9uZnNkL25mczRhY2wuYyBiL2ZzL25m
c2QvbmZzNGFjbC5jCmluZGV4IGNjM2I3YmEuLjdmZDRkNDQgMTAwNjQ0Ci0tLSBhL2ZzL25mc2Qv
bmZzNGFjbC5jCisrKyBiL2ZzL25mc2QvbmZzNGFjbC5jCkBAIC0xODMsOCArMTgzLDggQEAgc3Rh
dGljIHZvaWQKIHN1bW1hcml6ZV9wb3NpeF9hY2woc3RydWN0IHBvc2l4X2FjbCAqYWNsLCBzdHJ1
Y3QgcG9zaXhfYWNsX3N1bW1hcnkgKnBhcykKIHsKIAlzdHJ1Y3QgcG9zaXhfYWNsX2VudHJ5ICpw
YSwgKnBlOwotCXBhcy0+dXNlcnMgPSAwOwotCXBhcy0+Z3JvdXBzID0gMDsKKworCW1lbXNldChw
YXMsIDAsIHNpemVvZigqcGFzKSk7CiAJcGFzLT5tYXNrID0gMDc7CiAKIAlwZSA9IGFjbC0+YV9l
bnRyaWVzICsgYWNsLT5hX2NvdW50OwoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBlbWFp
bCBpcyBzcG9uc29yZWQgYnkgREIyIEV4cHJlc3MKRG93bmxvYWQgREIyIEV4cHJlc3MgQyAtIHRo
ZSBGUkVFIHZlcnNpb24gb2YgREIyIGV4cHJlc3MgYW5kIHRha2UKY29udHJvbCBvZiB5b3VyIFhN
TC4gTm8gbGltaXRzLiBKdXN0IGRhdGEuIENsaWNrIHRvIGdldCBpdCBub3cuCmh0dHA6Ly9zb3Vy
Y2Vmb3JnZS5uZXQvcG93ZXJiYXIvZGIyLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5u
ZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
