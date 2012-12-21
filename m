Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36909 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188Ab2LUQCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 11:02:40 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        =?UTF-8?q?Pawe=C5=82=20Sikora?= <pawel.sikora@agmk.net>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Kill fscache warnings when mounting without -ofsc
Date: Fri, 21 Dec 2012 11:02:32 -0500
Message-Id: <1356105752-711-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fscache code will currently bleat a "non-unique superblock keys"
warning even if the user is mounting without the 'fsc' option.
There should be no reason to even initialise the superblock cache cookie
unless we're planning on using fscache for something, so ensure that
we check for the NFS_OPTION_FSCACHE flag before calling into the
fscache code.

Reported-by: Paweł Sikora <pawel.sikora@agmk.net>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>
Acked-by: David Howells <dhowells@redhat.com>
---
 fs/nfs/super.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index aa5315b..c25cadf8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2375,19 +2375,30 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 				 struct nfs_parsed_mount_data *parsed,
 				 struct nfs_clone_mount *cloned)
 {
+	struct nfs_server *nfss = NFS_SB(sb);
 	char *uniq = NULL;
 	int ulen = 0;
 
-	if (parsed && parsed->fscache_uniq) {
-		uniq = parsed->fscache_uniq;
-		ulen = strlen(parsed->fscache_uniq);
+	nfss->fscache_key = NULL;
+	nfss->fscache = NULL;
+
+	if (parsed) {
+		if (!(parsed->options & NFS_OPTION_FSCACHE))
+			return;
+		if (parsed->fscache_uniq) {
+			uniq = parsed->fscache_uniq;
+			ulen = strlen(parsed->fscache_uniq);
+		}
 	} else if (cloned) {
 		struct nfs_server *mnt_s = NFS_SB(cloned->sb);
+		if (!(mnt_s->options & NFS_OPTION_FSCACHE))
+			return;
 		if (mnt_s->fscache_key) {
 			uniq = mnt_s->fscache_key->key.uniquifier;
 			ulen = mnt_s->fscache_key->key.uniq_len;
 		};
-	}
+	} else
+		return;
 
 	nfs_fscache_get_super_cookie(sb, uniq, ulen);
 }
-- 
1.7.11.7

