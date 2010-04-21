From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/9] NFS: Squelch compiler warning in nfs_add_server_stats()
Date: Wed, 21 Apr 2010 13:43:42 -0400
Message-ID: <20100421174341.2037.14866.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36444 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0DURno (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:43:44 -0400
Received: by mail-pv0-f174.google.com with SMTP id 13so1004163pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:43:44 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:

fs/nfs/iostat.h: In function =E2=80=98nfs_add_server_stats=E2=80=99:
fs/nfs/iostat.h:41: warning: comparison between signed and unsigned int=
eger expressions
fs/nfs/iostat.h:41: warning: comparison between signed and unsigned int=
eger expressions
fs/nfs/iostat.h:41: warning: comparison between signed and unsigned int=
eger expressions
fs/nfs/iostat.h:41: warning: comparison between signed and unsigned int=
eger expressions

Commit fce22848 replaced the open-coded per-cpu logic in several
functions in fs/nfs/iostat.h with a single invocation of
this_cpu_ptr().  This macro assumes its second argument is signed,
not unsigned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/iostat.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index 1d8d5c8..c583248 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -36,14 +36,14 @@ static inline void nfs_inc_stats(const struct inode=
 *inode,
=20
 static inline void nfs_add_server_stats(const struct nfs_server *serve=
r,
 					enum nfs_stat_bytecounters stat,
-					unsigned long addend)
+					long addend)
 {
 	this_cpu_add(server->io_stats->bytes[stat], addend);
 }
=20
 static inline void nfs_add_stats(const struct inode *inode,
 				 enum nfs_stat_bytecounters stat,
-				 unsigned long addend)
+				 long addend)
 {
 	nfs_add_server_stats(NFS_SERVER(inode), stat, addend);
 }
@@ -51,7 +51,7 @@ static inline void nfs_add_stats(const struct inode *=
inode,
 #ifdef CONFIG_NFS_FSCACHE
 static inline void nfs_add_fscache_stats(struct inode *inode,
 					 enum nfs_stat_fscachecounters stat,
-					 unsigned long addend)
+					 long addend)
 {
 	this_cpu_add(NFS_SERVER(inode)->io_stats->fscache[stat], addend);
 }

