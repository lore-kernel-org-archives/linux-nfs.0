Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:40407 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561AbbKMJJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Nov 2015 04:09:39 -0500
Date: Fri, 13 Nov 2015 10:09:37 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] nfs: allow intra-file CLONE
Message-ID: <20151113090937.GA7024@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de> <1447403929-13743-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447403929-13743-4-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Meh, a fixlet got lost while rebasing.  See below for the one liner
or just grab the git tree from:

	http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone-fixes
	git://git.infradead.org/users/hch/pnfs.git clone-fixes

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 49dbeab..db9b5fe 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -258,7 +258,7 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
 	if (same_inode) {
 		mutex_lock(&src_inode->i_mutex);
-	} if (dst_inode < src_inode) {
+	} else if (dst_inode < src_inode) {
 		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
 		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
 	} else {

