Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f48.google.com ([209.85.214.48]:35682 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965Ab3HFOa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 10:30:27 -0400
Received: by mail-bk0-f48.google.com with SMTP id jf20so182335bkc.21
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 07:30:25 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: rwheeler@redhat.com, avati@redhat.com, viro@ZenIV.linux.org.uk
Cc: bfoster@redhat.com, dhowells@redhat.com, eparis@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        swhiteho@redhat.com, mszeredi@suse.cz
Subject: [PATCH 4/4] fuse: drop dentry on failed revalidate
Date: Tue,  6 Aug 2013 16:30:03 +0200
Message-Id: <1375799403-28544-5-git-send-email-miklos@szeredi.hu>
In-Reply-To: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anand Avati <avati@redhat.com>

Drop a subtree when we find that it has moved or been delated.  This can be
done as long as there are no submounts under this location.

If the directory was moved and we come across the same directory in a
future lookup it will be reconnected by d_materialise_unique().

Signed-off-by: Anand Avati <avati@redhat.com>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dir.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 131d14b..4ba5893 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -226,8 +226,13 @@ static int fuse_dentry_revalidate(struct dentry *entry, unsigned int flags)
 		if (!err) {
 			struct fuse_inode *fi = get_fuse_inode(inode);
 			if (outarg.nodeid != get_node_id(inode)) {
+				int ret = 0;
+
+				if (check_submounts_and_drop(entry) != 0)
+					ret = 1;
+
 				fuse_queue_forget(fc, forget, outarg.nodeid, 1);
-				return 0;
+				return ret;
 			}
 			spin_lock(&fc->lock);
 			fi->nlookup++;
-- 
1.8.1.4

