From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] text-based mount.nfs: Remove support for nfsprog=
	option
Date: Mon, 05 Nov 2007 19:55:27 -0500
Message-ID: <20071106005527.4721.16690.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCj0-0003sp-OM
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:26 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCj6-00037S-B7
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

The kernel hasn't supported the underlying parts needed for changing the
NFS program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cf40313..31df51b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -317,9 +317,6 @@ static struct mount_options *rewrite_mount_options(char *str)
 		po_remove_all(options, "port");
 	}
 	nfs_server.pmap.pm_prog = NFS_PROGRAM;
-	option = po_get(options, "nfsprog");
-	if (option)
-		nfs_server.pmap.pm_prog = atoi(option);
 
 	option = po_get(options, "nfsvers");
 	if (option) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
