From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH] mount.nfs: fix a typo: "-o nolocks" -> "-o nolock"
Date: Wed, 1 Aug 2007 18:12:53 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708011806220.18305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.d>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGMR1-0002Fk-5M
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 15:12:51 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGMR4-0006Bp-WF
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 15:12:55 -0700
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

	Fix a minor typo: the option is "-o nolock", not "-o nolocks".

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/mount/nfsmount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index bd3403c..f642e0c 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -851,7 +851,7 @@ noauth_flavors:
 		if (!start_statd()) {
 			nfs_error(_("%s: rpc.statd is not running but is "
 				"required for remote locking.\n"
-				"   Either use '-o nolocks' to keep "
+				"   Either use '-o nolock' to keep "
 				"locks local, or start statd."),
 					progname);
 			goto fail;
-- 
1.4.4


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
