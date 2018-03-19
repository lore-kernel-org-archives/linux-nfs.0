Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41674 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755751AbeCSOgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/10] nfsd: simplify put of fi_deleg_file
Date: Mon, 19 Mar 2018 10:36:26 -0400
Message-Id: <1521470194-24840-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

fi_delegees is basically just a reference count on users of
fi_deleg_file, which is cleared when fi_delegees goes to zero.  The
fi_deleg_file check here is redundant.  Also add an assertion to make
sure we don't have unbalanced puts.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1bdfefe2e6ec..1a0b38fddde4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -849,9 +849,12 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
 	struct file *filp = NULL;
 
+	WARN_ON_ONCE(!fp->fi_delegees);
+
 	spin_lock(&fp->fi_lock);
-	if (fp->fi_deleg_file && --fp->fi_delegees == 0)
+	if (--fp->fi_delegees == 0) {
 		swap(filp, fp->fi_deleg_file);
+	}
 	spin_unlock(&fp->fi_lock);
 
 	if (filp) {
-- 
2.14.3

