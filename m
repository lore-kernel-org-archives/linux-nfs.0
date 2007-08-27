From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] NFS: Return a real error code from mount(2)
Date: Mon, 27 Aug 2007 13:30:34 -0400
Message-ID: <20070827173033.23426.55967.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPiQm-0003Fg-5G
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:31:16 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPiQq-0007xY-HM
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:31:20 -0700
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

Don't filter the return code from nfs_mount() or the rpcb client.
Return the real error code so that user space applications can display
a reasonable error and have a chance at a useful retry strategy.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index af47dbd..e2cda5f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1166,7 +1166,7 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
 
 		status = nfs_try_mount(&args, mntfh);
 		if (status)
-			return -EINVAL;
+			return status;
 
 		/*
 		 * Translate to nfs_mount_data, which nfs_fill_super


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
