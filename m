From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/25] NFS: Address a couple of nits in
	nfs_follow_referral()
Date: Tue, 13 Nov 2007 13:31:37 -0500
Message-ID: <20071113183137.5087.58369.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0YO-0000S9-ER
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:04 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0YU-0005e7-1P
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:10 -0800
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

Fix an outdated block comment, and address a comparison between a signed
and unsigned integer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index dd5fef2..bd1b161 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -114,10 +114,7 @@ static inline int valid_ipaddr4(const char *buf)
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
  * @dentry - parent directory
- * @fspath - fs path returned in fs_locations
- * @mntpath - mount path to new server
- * @hostname - hostname of new server
- * @addr - host addr of new server
+ * @locations - array of NFSv4 server location information
  *
  */
 static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
@@ -131,7 +128,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
 	};
 	char *page = NULL, *page2 = NULL;
-	int loc, s, error;
+	unsigned int s;
+	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
