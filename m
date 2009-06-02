From: Harshula Jayasuriya <harshula@redhat.com>
Subject: [PATCH] NFS: out of date comment regarding O_EXCL above
 nfs3_proc_create()
Date: Tue, 02 Jun 2009 15:50:24 +1000
Message-ID: <1243921824.16358.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56850 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361AbZFBFuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 01:50:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Recently we were observing the behaviour difference between a 2.4.x and
2.6.x kernel with respect to O_EXCL. A comment above nfs3_proc_create()
from 2.4.x era, "For now, we don't implement O_EXCL." seems inaccurate
in TOT.

If so, here's a patch to remove the comment.

This patch is against:
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
--- 
fs/nfs/nfs3proc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d0cc5ce..ee6a13f 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -299,7 +299,6 @@ static void nfs3_free_createdata(struct nfs3_createdata *data)
 
 /*
  * Create a regular file.
- * For now, we don't implement O_EXCL.
  */
 static int
 nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
--

cya,
#

