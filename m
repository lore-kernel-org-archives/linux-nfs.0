Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101Ab3CSNHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:52 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] NFSv4.1: Select the "most recent locking state" for read/write/setattr stateids
Date: Tue, 19 Mar 2013 09:07:39 -0400
Message-Id: <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Follow the practice described in section 8.2.2 of RFC5661: When sending a
read/write or setattr stateid, set the seqid field to zero in order to
signal that the NFS server should apply the most recent locking state.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c         | 3 ++-
 fs/nfs/nfs4state.c        | 2 ++
 include/linux/nfs_fs_sb.h | 1 +
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4fc1496..c5cc4a8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6855,7 +6855,8 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.init_caps = NFS_CAP_READDIRPLUS
 		| NFS_CAP_ATOMIC_OPEN
 		| NFS_CAP_CHANGE_ATTR
-		| NFS_CAP_POSIX_LOCK,
+		| NFS_CAP_POSIX_LOCK
+		| NFS_CAP_STATEID_NFSV41,
 	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4e95bd7..685b1e9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1053,6 +1053,8 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		goto out;
 	ret = nfs4_copy_open_stateid(dst, state);
 out:
+	if (nfs_server_capable(state->inode, NFS_CAP_STATEID_NFSV41))
+		dst->seqid = 0;
 	return ret;
 }
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6c6ed15..74c9e52 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -197,5 +197,6 @@ struct nfs_server {
 #define NFS_CAP_MTIME		(1U << 13)
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
 #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
+#define NFS_CAP_STATEID_NFSV41	(1U << 16)
 
 #endif
-- 
1.8.1.4

