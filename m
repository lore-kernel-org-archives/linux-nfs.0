From: James Lentini <jlentini@netapp.com>
Subject: [PATCH] NFS: fix length computation in nfs_validate_mount_data
Date: Wed, 29 Aug 2007 15:26:01 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0708291509500.2779@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTDO-00050e-30
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:28:34 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTDQ-0006TH-F9
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:28:38 -0700
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


While experimenting with the new string mount infrastructure, I 
noticed an off by one error in the computation of the hostname's 
length. This patch fixes the length computation to match the same 
computation in nfs4_validate_mount_data().

Signed-off-by: James Lentini <jlentini@netapp.com>
---

 fs/nfs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- fs/nfs/super.c	2007-08-29 15:06:59.320932000 -0400
+++ fs/nfs/super.c	2007-08-29 15:07:51.439960000 -0400
@@ -1153,7 +1153,7 @@ static int nfs_validate_mount_data(struc
 		c = strchr(dev_name, ':');
 		if (c == NULL)
 			return -EINVAL;
-		len = c - dev_name - 1;
+		len = c - dev_name;
 		if (len > sizeof(data->hostname))
 			return -EINVAL;
 		strncpy(data->hostname, dev_name, len);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
