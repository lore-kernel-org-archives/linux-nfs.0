From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] NFS: change NFS mount error return when
	hostname/pathname	too long
Date: Wed, 29 Aug 2007 15:49:37 -0400
Message-ID: <20070829194937.14142.62568.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTXy-0007DP-Oz
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:50 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTY3-0003QP-5q
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:55 -0700
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

According to the mount(2) man page, the proper error return code for the
mount(2) system call when the special device name or the mounted-on
directory name is too long is ENAMETOOLONG.

Also fix an off-by-one error when calculating the length of a hostname.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8e51c9f..84ddd7e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1153,15 +1153,15 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
 		c = strchr(dev_name, ':');
 		if (c == NULL)
 			return -EINVAL;
-		len = c - dev_name - 1;
+		len = c - dev_name;
 		if (len > sizeof(data->hostname))
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		strncpy(data->hostname, dev_name, len);
 		args.nfs_server.hostname = data->hostname;
 
 		c++;
 		if (strlen(c) > NFS_MAXPATHLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		args.nfs_server.export_path = c;
 
 		status = nfs_try_mount(&args, mntfh);
@@ -1668,7 +1668,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 		/* while calculating len, pretend ':' is '\0' */
 		len = c - dev_name;
 		if (len > NFS4_MAXNAMLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		*hostname = kzalloc(len, GFP_KERNEL);
 		if (*hostname == NULL)
 			return -ENOMEM;
@@ -1677,7 +1677,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		*mntpath = kzalloc(len + 1, GFP_KERNEL);
 		if (*mntpath == NULL)
 			return -ENOMEM;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
