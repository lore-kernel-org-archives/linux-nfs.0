From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] mount.nfs: Fix "statd not running" error message
Date: Mon, 05 Nov 2007 19:55:12 -0500
Message-ID: <20071106005512.4721.24451.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCj0-0003sq-VF
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:26 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCj5-0002B7-Rn
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:32 -0800
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

When mount.nfs reports that statd isn't running, it suggests using the "-o
nolocks" option, which doesn't exist.  It should say "-o nolock".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsmount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 23dd2f6..3d2ebb1 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -848,7 +848,7 @@ noauth_flavors:
 		if (!start_statd()) {
 			nfs_error(_("%s: rpc.statd is not running but is "
 				"required for remote locking.\n"
-				"   Either use '-o nolocks' to keep "
+				"   Either use '-o nolock' to keep "
 				"locks local, or start statd."),
 					progname);
 			goto fail;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
