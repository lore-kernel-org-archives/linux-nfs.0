From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3/5] nfsd: remove unnecessary NULL checks from
	nfsd_cross_mnt
Date: Wed, 18 Jul 2007 18:57:28 -0400
Message-ID: <11847994503028-git-send-email-bfields@fieldses.org>
References: <20070713114228.3c171a90.akpm@linux-foundation.org>
	<11847994502579-git-send-email-bfields@fieldses.org>
	<11847994502502-git-send-email-bfields@fieldses.org>
	<11847994503243-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, andros@citi.umich.edu,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBISc-0002vk-Oh
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:41 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBISf-0007TO-8Y
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:38 -0700
In-Reply-To: <11847994503243-git-send-email-bfields@fieldses.org>
Message-Id: <ca76105264283034a0f3d9d138bded79f5b2f87e.1184798679.git.bfields@citi.umich.edu>
In-Reply-To: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
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

From: J. Bruce Fields <bfields@citi.umich.edu>

We can now assume that rqst_exp_get_by_name() does not return NULL; so
clean up some unnecessary checks.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b8da5dd..5c97d0e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -120,14 +120,14 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 		mntput(mnt);
 		goto out;
 	}
-	if (exp2 && ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2))) {
+	if ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
 		/* successfully crossed mount point */
 		exp_put(exp);
 		*expp = exp2;
 		dput(dentry);
 		*dpp = mounts;
 	} else {
-		if (exp2) exp_put(exp2);
+		exp_put(exp2);
 		dput(mounts);
 	}
 	mntput(mnt);
-- 
1.5.3.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
