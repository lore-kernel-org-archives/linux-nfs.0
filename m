Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:26710 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdFPQMs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 12:12:48 -0400
From: Anna.Schumaker@Netapp.com
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Set FATTR4_WORD0_TYPE for . and .. entries
Date: Fri, 16 Jun 2017 12:12:33 -0400
Message-ID: <20170616161233.29147-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The current code worked okay for getdents(), but getdents64() expects
the d_type field to get filled out properly in the stat structure.
Setting this field fixes xfstests generic/401.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a3b8cd..735b3068a2d1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -275,6 +275,7 @@ const u32 nfs4_fs_locations_bitmap[3] = {
 static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
 		struct nfs4_readdir_arg *readdir)
 {
+	unsigned int attrs = FATTR4_WORD0_FILEID | FATTR4_WORD0_TYPE;
 	__be32 *start, *p;
 
 	if (cookie > 2) {
@@ -305,8 +306,9 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 		memcpy(p, ".\0\0\0", 4);                        /* entry */
 		p++;
 		*p++ = xdr_one;                         /* bitmap length */
-		*p++ = htonl(FATTR4_WORD0_FILEID);             /* bitmap */
-		*p++ = htonl(8);              /* attribute buffer length */
+		*p++ = htonl(attrs);                           /* bitmap */
+		*p++ = htonl(12);             /* attribute buffer length */
+		*p++ = htonl(NF4DIR);
 		p = xdr_encode_hyper(p, NFS_FILEID(d_inode(dentry)));
 	}
 	
@@ -317,8 +319,9 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	memcpy(p, "..\0\0", 4);                         /* entry */
 	p++;
 	*p++ = xdr_one;                         /* bitmap length */
-	*p++ = htonl(FATTR4_WORD0_FILEID);             /* bitmap */
-	*p++ = htonl(8);              /* attribute buffer length */
+	*p++ = htonl(attrs);                           /* bitmap */
+	*p++ = htonl(12);             /* attribute buffer length */
+	*p++ = htonl(NF4DIR);
 	p = xdr_encode_hyper(p, NFS_FILEID(d_inode(dentry->d_parent)));
 
 	readdir->pgbase = (char *)p - (char *)start;
-- 
2.13.1

