Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37667 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415Ab3KDUvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 15:51:22 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
CC: J Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 4/5] NFSv4: Sanity check the server reply in _nfs4_server_capabilities
Date: Mon, 4 Nov 2013 15:51:11 -0500
Message-ID: <1383598272-17737-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383598272-17737-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want to be setting capabilities and/or requesting attributes
that are not appropriate for the NFSv4 minor version.

- Ensure that we clear the NFS_CAP_SECURITY_LABEL capability when appropriate
- Ensure that we limit the attribute bitmasks to the mounted_on_fileid
  attribute and less for NFSv4.0
- Ensure that we limit the attribute bitmasks to suppattr_exclcreat and
  less for NFSv4.1
- Ensure that we limit it to change_sec_label or less for NFSv4.2

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c    | 25 ++++++++++++++++++++-----
 include/linux/nfs4.h |  2 ++
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e28b5c77cbc..ed2a0e6b9aed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2706,6 +2706,10 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 		nfs4_close_state(ctx->state, ctx->mode);
 }
 
+#define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
+#define FATTR4_WORD2_NFS41_MASK (2*FATTR4_WORD2_SUPPATTR_EXCLCREAT - 1UL)
+#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_CHANGE_SECURITY_LABEL - 1UL)
+
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
 	struct nfs4_server_caps_arg args = {
@@ -2721,12 +2725,25 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
+		/* Sanity check the server answers */
+		switch (server->nfs_client->cl_minorversion) {
+		case 0:
+			res.attr_bitmask[1] &= FATTR4_WORD1_NFS40_MASK;
+			res.attr_bitmask[2] = 0;
+			break;
+		case 1:
+			res.attr_bitmask[2] &= FATTR4_WORD2_NFS41_MASK;
+			break;
+		case 2:
+			res.attr_bitmask[2] &= FATTR4_WORD2_NFS42_MASK;
+		}
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
 				NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
 				NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
 				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
-				NFS_CAP_CTIME|NFS_CAP_MTIME);
+				NFS_CAP_CTIME|NFS_CAP_MTIME|
+				NFS_CAP_SECURITY_LABEL);
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
 			server->caps |= NFS_CAP_ACLS;
 		if (res.has_links != 0)
@@ -2755,14 +2772,12 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 #endif
 		memcpy(server->attr_bitmask_nl, res.attr_bitmask,
 				sizeof(server->attr_bitmask));
+		server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
 
-		if (server->caps & NFS_CAP_SECURITY_LABEL) {
-			server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
-			res.attr_bitmask[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
-		}
 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+		server->cache_consistency_bitmask[2] = 0;
 		server->acl_bitmask = res.acl_bitmask;
 		server->fh_expire_type = res.fh_expire_type;
 	}
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index bfe6c379a24e..c6f41b616965 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -396,6 +396,8 @@ enum lock_type4 {
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
+#define FATTR4_WORD2_CHANGE_SECURITY_LABEL \
+					(1UL << 17)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)
-- 
1.8.3.1

