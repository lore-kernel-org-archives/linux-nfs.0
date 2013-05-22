Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:28480 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373Ab3EVXHK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 19:07:10 -0400
From: "Dilger, Andreas" <andreas.dilger@intel.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Yong, Fan" <fan.yong@intel.com>
Subject: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Date: Wed, 22 May 2013 23:06:54 +0000
Message-ID: <CDC2ABAC.3341C%andreas.dilger@intel.com>
Content-Type: multipart/mixed;
	boundary="_002_CDC2ABAC3341Candreasdilgerintelcom_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_CDC2ABAC3341Candreasdilgerintelcom_
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2E06987E30F1454E92F1DBD65D91BB03@intel.com>
Content-Transfer-Encoding: quoted-printable

When exporting a filesystem via NFS, it can generate several kinds
of NFS filesystem IDs. For most of cases, it uses a 32-bit inode
number in the NFS FSID, but this does not work on a filesystem
using a 64-bit root inode number.

In kernel space, NFS can generate/use NFS FSID with a 64-bit inode
number for the "FSID_UUID16_INUM" type. Unfortunately, while the
user space nfs-utils decode the 64-bit inode number from the FSID
correctly, it is truncated when storing it in "struct parsed_fsid".
Expand the "struct parsed_fsid" inode field to store the full 64-bit
root inode number.

Intel-bug-id: LU-2904
Signed-off-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
---
 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 517aa62..a7212e7 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -388,7 +388,7 @@ struct parsed_fsid {
 	int fsidtype;
 	/* We could use a union for this, but it would be more
 	 * complicated; why bother? */
-	unsigned int inode;
+	unsigned long long inode; /* We need 64-bits ino# */
 	unsigned int minor;
 	unsigned int major;
 	unsigned int fsidnum;
--1.7.1

Patch is also attached separately, since it will likely be butchered
by this email client.


Cheers, Andreas
--=20
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division



--_002_CDC2ABAC3341Candreasdilgerintelcom_
Content-Type: application/octet-stream;
	name="nfs-suport-64-bit-root-inode-number.patch"
Content-Description: nfs-suport-64-bit-root-inode-number.patch
Content-Disposition: attachment;
	filename="nfs-suport-64-bit-root-inode-number.patch"; size=1453;
	creation-date="Wed, 22 May 2013 23:06:53 GMT";
	modification-date="Wed, 22 May 2013 23:06:53 GMT"
Content-ID: <085CC010FF0AED41B35B03D1F6857E7E@intel.com>
Content-Transfer-Encoding: base64

RnJvbSBiZWJmNTVkOTkxMzIyYzcyZDViMDliMjE2Yzc3NmFiMDM4N2MwNDNlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBGYW4gWW9uZyA8ZmFuLnlvbmdAaW50ZWwuY29tPgpEYXRlOiBN
b24sIDEzIE1heSAyMDEzIDEzOjUzOjQyICswODAwClN1YmplY3Q6IFtQQVRDSF0gbmZzOiBzdXBw
b3J0IDY0LWJpdCByb290IGlub2RlIG51bWJlciBpbiBORlMgRlNJRAoKV2hlbiBleHBvcnRpbmcg
YSBmaWxlc3lzdGVtIHZpYSBORlMsIGl0IGNhbiBnZW5lcmF0ZSBzZXZlcmFsIGtpbmRzCm9mIE5G
UyBmaWxlc3lzdGVtIElEcy4gRm9yIG1vc3Qgb2YgY2FzZXMsIGl0IHVzZXMgYSAzMi1iaXQgaW5v
ZGUKbnVtYmVyIGluIHRoZSBORlMgRlNJRCwgYnV0IHRoaXMgZG9lcyBub3Qgd29yayBvbiBhIGZp
bGVzeXN0ZW0KdXNpbmcgYSA2NC1iaXQgcm9vdCBpbm9kZSBudW1iZXIuCgpJbiBrZXJuZWwgc3Bh
Y2UsIE5GUyBjYW4gZ2VuZXJhdGUvdXNlIE5GUyBGU0lEIHdpdGggYSA2NC1iaXQgaW5vZGUKbnVt
YmVyIGZvciB0aGUgIkZTSURfVVVJRDE2X0lOVU0iIHR5cGUuIFVuZm9ydHVuYXRlbHksIHdoaWxl
IHRoZQp1c2VyIHNwYWNlIG5mcy11dGlscyBkZWNvZGUgdGhlIDY0LWJpdCBpbm9kZSBudW1iZXIg
ZnJvbSB0aGUgRlNJRApjb3JyZWN0bHksIGl0IGlzIHRydW5jYXRlZCB3aGVuIHN0b3JpbmcgaXQg
aW4gInN0cnVjdCBwYXJzZWRfZnNpZCIuCkV4cGFuZCB0aGUgInN0cnVjdCBwYXJzZWRfZnNpZCIg
aW5vZGUgZmllbGQgdG8gc3RvcmUgdGhlIGZ1bGwgNjQtYml0CnJvb3QgaW5vZGUgbnVtYmVyLgoK
SW50ZWwtYnVnLWlkOiBMVS0yOTA0ClNpZ25lZC1vZmYtYnk6IEZhbiBZb25nIDxmYW4ueW9uZ0Bp
bnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IEFuZHJlYXMgRGlsZ2VyIDxhbmRyZWFzLmRpbGdlckBp
bnRlbC5jb20+Ci0tLQogdXRpbHMvbW91bnRkL2NhY2hlLmMgfCAgICAyICstCiAxIGZpbGVzIGNo
YW5nZWQsIDEgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS91dGls
cy9tb3VudGQvY2FjaGUuYyBiL3V0aWxzL21vdW50ZC9jYWNoZS5jCmluZGV4IDUxN2FhNjIuLmE3
MjEyZTcgMTAwNjQ0Ci0tLSBhL3V0aWxzL21vdW50ZC9jYWNoZS5jCisrKyBiL3V0aWxzL21vdW50
ZC9jYWNoZS5jCkBAIC0zODgsNyArMzg4LDcgQEAgc3RydWN0IHBhcnNlZF9mc2lkIHsKIAlpbnQg
ZnNpZHR5cGU7CiAJLyogV2UgY291bGQgdXNlIGEgdW5pb24gZm9yIHRoaXMsIGJ1dCBpdCB3b3Vs
ZCBiZSBtb3JlCiAJICogY29tcGxpY2F0ZWQ7IHdoeSBib3RoZXI/ICovCi0JdW5zaWduZWQgaW50
IGlub2RlOworCXVuc2lnbmVkIGxvbmcgbG9uZyBpbm9kZTsgLyogV2UgbmVlZCA2NC1iaXRzIGlu
byMgKi8KIAl1bnNpZ25lZCBpbnQgbWlub3I7CiAJdW5zaWduZWQgaW50IG1ham9yOwogCXVuc2ln
bmVkIGludCBmc2lkbnVtOwotLSAKMS43LjEKCg==

--_002_CDC2ABAC3341Candreasdilgerintelcom_--
