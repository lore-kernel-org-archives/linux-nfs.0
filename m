Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:56129 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1BJMNf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 07:13:35 -0500
Subject: [PATCH 1/2] Fix memory corruption due to not expected FS_LOCATION
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <1297338894.3667.0.camel@vT510>
References: <1297338894.3667.0.camel@vT510>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Feb 2011 15:13:32 +0300
Message-ID: <1297340012.3667.5.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There is a remote vulnerability for nfs4-client. That allows
a remote NFSv4 server or attacker in middle rewrite memory on
NFSv4 client.
Of course if encryption is used then only server can do corruption.

1. Client send GETATTR request to server, but there are not
   checks for bitmask in reply from server. Therefore server may return
   more attributes than were asked.

2. Pointer to struct nfs_fattr is passed to decode_getfattr(), but
   that parameter is considered as pointer to struct nfs4_fs_locations
   in case set FATTR4_WORD0_FS_LOCATIONS in reply from server.

   But there is no check for pointer type that was passed!

3. Remote side can set FATTR4_WORD0_FS_LOCATIONS and fill
   datas fsattr4_fs_locations in reply to client.

4. sizeof(nfs4_fs_locations) is about 92080 bytes in kernel 2.6.38

   So ~ 90 Kbytes can be overwritten in memory of NFSv4 client.

   Fortunately, nfs_fattr is allocated via kmalloc and
   is not stored in stack. So generally kmalloc-192 is corrupted.

   Affected kernels: all from v2.6.18
   Commit 683b57b435326eb512c7305892683b6205669448
   "NFSv4: Implement the fs_locations function call"

5.
 Simple testcase for NFSv4 server: add next code at begin of
 nfsd4_encode_fattr()

       if (!strcmp("filexxx", dentry->d_name.name)) {
               bmval[0] |= FATTR4_WORD0_FS_LOCATIONS;
               bmval0 |= FATTR4_WORD0_FS_LOCATIONS;
       }

 NFSv4 client that tries to touch 'filexxx' will catch kernel panic.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/nfs4xdr.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 242b392..8dbfd9a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4301,7 +4301,8 @@ xdr_error:
 }
 
 static int decode_getfattr_generic(struct xdr_stream *xdr, struct
nfs_fattr *fattr,
-		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep)
+		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep,
+		int expect_fsloc)
 {
 	__be32 *savep;
 	uint32_t attrlen,
@@ -4316,6 +4317,9 @@ static int decode_getfattr_generic(struct
xdr_stream *xdr, struct nfs_fattr *fat
 	if (status < 0)
 		goto xdr_error;
 
+	if (!expect_fsloc)
+		bitmap[0] &= ~FATTR4_WORD0_FS_LOCATIONS;
+
 	status = decode_attr_length(xdr, &attrlen, &savep);
 	if (status < 0)
 		goto xdr_error;
@@ -4333,7 +4337,7 @@ xdr_error:
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr
*fattr,
 		const struct nfs_server *server, int may_sleep)
 {
-	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep);
+	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep,
0);
 }
 
 /*
@@ -6338,9 +6342,11 @@ static int nfs4_xdr_dec_fs_locations(struct
rpc_rqst *req,
 	if (status)
 		goto out;
 	xdr_enter_page(xdr, PAGE_SIZE);
-	status = decode_getfattr(xdr, &res->fs_locations->fattr,
+	status = decode_getfattr_generic(xdr, &res->fs_locations->fattr,
+				 NULL,
 				 res->fs_locations->server,
-				 !RPC_IS_ASYNC(req->rq_task));
+				 !RPC_IS_ASYNC(req->rq_task),
+				 1);
 out:
 	return status;
 }
@@ -6677,6 +6683,8 @@ int nfs4_decode_dirent(struct xdr_stream *xdr,
struct nfs_entry *entry,
 	if (decode_attr_bitmap(xdr, bitmap) < 0)
 		goto out_overflow;
 
+	bitmap[0] &= ~FATTR4_WORD0_FS_LOCATIONS;
+
 	if (decode_attr_length(xdr, &len, &p) < 0)
 		goto out_overflow;
 
-- 
1.7.1


