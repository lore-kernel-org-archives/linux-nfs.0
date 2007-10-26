From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/27] NFS: Clean up: copy hostname with kstrndup
	during mount	processing
Date: Fri, 26 Oct 2007 13:32:40 -0400
Message-ID: <20071026173240.31475.40562.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT3E-0007LW-0n
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:09 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3I-0000SO-E2
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:57 -0700
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

Clean up: mount option parsing uses kstrndup in several places, rather than
using kzalloc.  Replace the few remaining uses of kzalloc with kstrndup,
for consistency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5c553b1..ccfe303 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1642,21 +1642,16 @@ static int nfs4_validate_mount_data(void *options,
 		len = c - dev_name;
 		if (len > NFS4_MAXNAMLEN)
 			return -ENAMETOOLONG;
-		args->nfs_server.hostname = kzalloc(len, GFP_KERNEL);
-		if (args->nfs_server.hostname == NULL)
-			return -ENOMEM;
-		strncpy(args->nfs_server.hostname, dev_name, len - 1);
+		/* N.B. caller will free nfs_server.hostname in all cases */
+		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
 
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
 			return -ENAMETOOLONG;
-		args->nfs_server.export_path = kzalloc(len + 1, GFP_KERNEL);
-		if (args->nfs_server.export_path == NULL)
-			return -ENOMEM;
-		strncpy(args->nfs_server.export_path, c, len);
+		args->nfs_server.export_path = kstrndup(c, len, GFP_KERNEL);
 
-		dprintk("MNTPATH: %s\n", args->nfs_server.export_path);
+		dprintk("NFS: MNTPATH: '%s'\n", args->nfs_server.export_path);
 
 		if (args->client_address == NULL)
 			goto out_no_client_address;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
