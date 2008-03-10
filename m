From: Jiang Guiqing <jianggq@cn.fujitsu.com>
Subject: [PATCH] nfs_updatepage must not extend the write
Date: Mon, 10 Mar 2008 14:07:44 +0800
Message-ID: <47D4D030.9060906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54827 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbYCJGIT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 02:08:19 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,all

I think, when mounting nfs with sync option, nfs_updatepage must not
extend the write to cover the entire page.

Signed-off-by: Jiang Guiqing <jianggq@cn.fujitsu.com>

---
  linux-2.6.25-rc4/fs/nfs/write.c |    3 ++-
  1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/linux-2.6.25-rc4/fs/nfs/write.c b/linux-2.6.25-rc4/fs/nfs/write.c
index 80c61fd..94d6aaf 100644
--- a/linux-2.6.25-rc4/fs/nfs/write.c
+++ b/linux-2.6.25-rc4/fs/nfs/write.c
@@ -734,7 +734,8 @@ int nfs_updatepage(struct file *file, struct page *page,
  	 */
  	if (nfs_write_pageuptodate(page, inode) &&
  			inode->i_flock == NULL &&
-			!(file->f_flags & O_SYNC)) {
+			!(file->f_flags & O_SYNC) &&
+			!(IS_SYNC(inode))) {
  		count = max(count + offset, nfs_page_length(page));
  		offset = 0;
  	}
-- 
1.5.3.8

Thanks.
-Jiang Guiqing

