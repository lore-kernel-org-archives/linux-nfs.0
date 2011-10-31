Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40701 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932801Ab1JaRMv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:12:51 -0400
MIME-Version: 1.0
In-Reply-To: <1320074323.4714.2.camel@lade.trondhjem.org>
References: <1319798192.26450.1.camel@localhost.localdomain>
	<1320074323.4714.2.camel@lade.trondhjem.org>
Date: Mon, 31 Oct 2011 23:12:50 +0600
Message-ID: <CADZ9YHhq91+Td03OjWbX0rwHwb6Y7QhicsuDqqAUSy2O8=05BA@mail.gmail.com>
Subject: Re: [PATCH] nfs: Fix unused variable warning.
From: Rakib Mullick <rakib.mullick@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org
Content-Type: multipart/mixed; boundary=e89a8f64782347e77104b09b593c
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--e89a8f64782347e77104b09b593c
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 31, 2011 at 9:18 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2011-10-28 at 16:36 +0600, Rakib Mullick wrote:
>
> This will still cause a warning if you compile without RPC_DEBUG (e.g.
> if CONFIG_SYSCTL isn't defined).
>
I didn't get any warning with CONFIG_SYSCTL=3Dn.

> Since there is only one user, it seems better to just open-code the
> NFS_SERVER(data->inode) in the dprintk()...

Okay, it seems reasonable. We can simply remove 'server'. Please
consider the following patch (also attached, might have some white
space issue).

---

 When CONFIG_NFS=3Dy and CONFIG_NFS_V3_{,V4}=3Dn we get the following warni=
ng.
=09
	fs/nfs/write.c: In function =91nfs_writeback_done=92:
	fs/nfs/write.c:1246:21: warning: unused variable =91server=92

 Remove the variable 'server' to fix the above warning.

Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2219c88..a2e4b27 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1243,7 +1243,6 @@ void nfs_writeback_done(struct rpc_task *task,
struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp =3D &data->args;
 	struct nfs_writeres	*resp =3D &data->res;
-	struct nfs_server	*server =3D NFS_SERVER(data->inode);
 	int status;

 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
@@ -1277,7 +1276,7 @@ void nfs_writeback_done(struct rpc_task *task,
struct nfs_write_data *data)
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed =3D %d) !=3D (stable =3D %d)\n",
-				server->nfs_client->cl_hostname,
+				data->inode->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
 			complain =3D jiffies + 300 * HZ;
 		}

--e89a8f64782347e77104b09b593c
Content-Type: application/octet-stream; name="nfs_unused_var_fix.patch"
Content-Disposition: attachment; filename="nfs_unused_var_fix.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gufq54km0

IFdoZW4gQ09ORklHX05GUz15IGFuZCBDT05GSUdfTkZTX1YzX3ssVjR9PW4gd2UgZ2V0IHRoZSBm
b2xsb3dpbmcgd2FybmluZy4KCQoJZnMvbmZzL3dyaXRlLmM6IEluIGZ1bmN0aW9uIOKAmG5mc193
cml0ZWJhY2tfZG9uZeKAmToKCWZzL25mcy93cml0ZS5jOjEyNDY6MjE6IHdhcm5pbmc6IHVudXNl
ZCB2YXJpYWJsZSDigJhzZXJ2ZXLigJkKCiBSZW1vdmUgdGhlIHZhcmlhYmxlICdzZXJ2ZXInIHRv
IGZpeCB0aGUgYWJvdmUgd2FybmluZy4KCgpTaWduZWQtb2ZmLWJ5OiBSYWtpYiBNdWxsaWNrIDxy
YWtpYi5tdWxsaWNrQGdtYWlsLmNvbT4KLS0tCgpkaWZmIC0tZ2l0IGEvZnMvbmZzL3dyaXRlLmMg
Yi9mcy9uZnMvd3JpdGUuYwppbmRleCAyMjE5Yzg4Li5hMmU0YjI3IDEwMDY0NAotLS0gYS9mcy9u
ZnMvd3JpdGUuYworKysgYi9mcy9uZnMvd3JpdGUuYwpAQCAtMTI0Myw3ICsxMjQzLDYgQEAgdm9p
ZCBuZnNfd3JpdGViYWNrX2RvbmUoc3RydWN0IHJwY190YXNrICp0YXNrLCBzdHJ1Y3QgbmZzX3dy
aXRlX2RhdGEgKmRhdGEpCiB7CiAJc3RydWN0IG5mc193cml0ZWFyZ3MJKmFyZ3AgPSAmZGF0YS0+
YXJnczsKIAlzdHJ1Y3QgbmZzX3dyaXRlcmVzCSpyZXNwID0gJmRhdGEtPnJlczsKLQlzdHJ1Y3Qg
bmZzX3NlcnZlcgkqc2VydmVyID0gTkZTX1NFUlZFUihkYXRhLT5pbm9kZSk7CiAJaW50IHN0YXR1
czsKIAogCWRwcmludGsoIk5GUzogJTV1IG5mc193cml0ZWJhY2tfZG9uZSAoc3RhdHVzICVkKVxu
IiwKQEAgLTEyNzcsNyArMTI3Niw3IEBAIHZvaWQgbmZzX3dyaXRlYmFja19kb25lKHN0cnVjdCBy
cGNfdGFzayAqdGFzaywgc3RydWN0IG5mc193cml0ZV9kYXRhICpkYXRhKQogCQlpZiAodGltZV9i
ZWZvcmUoY29tcGxhaW4sIGppZmZpZXMpKSB7CiAJCQlkcHJpbnRrKCJORlM6ICAgICAgIGZhdWx0
eSBORlMgc2VydmVyICVzOiIKIAkJCQkiIChjb21taXR0ZWQgPSAlZCkgIT0gKHN0YWJsZSA9ICVk
KVxuIiwKLQkJCQlzZXJ2ZXItPm5mc19jbGllbnQtPmNsX2hvc3RuYW1lLAorCQkJCWRhdGEtPmlu
b2RlLT5uZnNfY2xpZW50LT5jbF9ob3N0bmFtZSwKIAkJCQlyZXNwLT52ZXJmLT5jb21taXR0ZWQs
IGFyZ3AtPnN0YWJsZSk7CiAJCQljb21wbGFpbiA9IGppZmZpZXMgKyAzMDAgKiBIWjsKIAkJfQo=
--e89a8f64782347e77104b09b593c--
