From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] knfsd: Fixed problem with NFS exporting
	directories which are mounted on.
Date: Wed,  5 Sep 2007 17:22:12 -0400
Message-ID: <11890273334076-git-send-email-bfields@citi.umich.edu>
References: <1189027333981-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IT2KF-0005yc-6b
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 14:22:15 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IT2KF-0003G3-TT
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 14:22:17 -0700
In-Reply-To: <1189027333981-git-send-email-bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Neil Brown <neilb@suse.de>

Recent changes in NFSd cause a directory which is mounted-on
to not appear properly when the filesystem containing it is exported.

*exp_get* not returns -ENOENT rather than NULL and when
  commit 5d3dbbeaf56d0365ac6b5c0a0da0bd31cc4781e1
removed the NULL checks, it didn't add a check for -ENOENT.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a0c2b25..7867151 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -115,7 +115,8 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 
 	exp2 = rqst_exp_get_by_name(rqstp, mnt, mounts);
 	if (IS_ERR(exp2)) {
-		err = PTR_ERR(exp2);
+		if (PTR_ERR(exp2) != -ENOENT)
+			err = PTR_ERR(exp2);
 		dput(mounts);
 		mntput(mnt);
 		goto out;
-- 
1.5.3


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
