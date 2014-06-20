Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:46839 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757085AbaFTRla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 13:41:30 -0400
Received: by mail-ig0-f181.google.com with SMTP id h15so776023igd.8
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 10:41:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] nfs: Fix cache_validity check in nfs_write_pageuptodate()
Date: Fri, 20 Jun 2014 13:41:23 -0400
Message-Id: <1403286083-14345-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1403286083-14345-3-git-send-email-trond.myklebust@primarydata.com>
References: <20140620125140.GH4510@tonberry.usersys.redhat.com>
 <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
 <1403286083-14345-2-git-send-email-trond.myklebust@primarydata.com>
 <1403286083-14345-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Scott Mayhew <smayhew@redhat.com>

NFS_INO_INVALID_DATA cannot be ignored, even if we have a delegation.

We're still having some problems with data corruption when multiple
clients are appending to a file and those clients are being granted
write delegations on open.

To reproduce:

Client A:
vi /mnt/`hostname -s`
while :; do echo "XXXXXXXXXXXXXXX" >>/mnt/file; sleep $(( $RANDOM % 5 )); done

Client B:
vi /mnt/`hostname -s`
while :; do echo "YYYYYYYYYYYYYYY" >>/mnt/file; sleep $(( $RANDOM % 5 )); done

What's happening is that in nfs_update_inode() we're recognizing that
the file size has changed and we're setting NFS_INO_INVALID_DATA
accordingly, but then we ignore the cache_validity flags in
nfs_write_pageuptodate() because we have a delegation.  As a result,
in nfs_updatepage() we're extending the write to cover the full page
even though we've not read in the data to begin with.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 48cca1a65a4b..8534ee5c207d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -928,12 +928,14 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 
 	if (nfs_have_delegated_attributes(inode))
 		goto out;
-	if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
+	if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
 		return false;
 	smp_rmb();
 	if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
 		return false;
 out:
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+		return false;
 	return PageUptodate(page) != 0;
 }
 
-- 
1.9.3

