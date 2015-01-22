Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41412 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbAVLLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:18 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 09/20] nfsd: make find_any_file available outside nfs4state.c
Date: Thu, 22 Jan 2015 12:09:55 +0100
Message-Id: <1421925006-24231-10-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/state.h     | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c31b8f8..444d43c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -352,7 +352,7 @@ find_readable_file(struct nfs4_file *f)
 	return ret;
 }
 
-static struct file *
+struct file *
 find_any_file(struct nfs4_file *f)
 {
 	struct file *ret;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd61e7d..18b5ab8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -579,6 +579,7 @@ static inline void get_nfs4_file(struct nfs4_file *fi)
 {
 	atomic_inc(&fi->fi_ref);
 }
+struct file *find_any_file(struct nfs4_file *f);
 
 /* grace period management */
 void nfsd4_end_grace(struct nfsd_net *nn);
-- 
1.9.1

