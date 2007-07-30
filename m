From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: show addr=ipaddr in /proc/mounts rather than
	hostname
Date: Mon, 30 Jul 2007 08:47:38 -0400
Message-ID: <20070730084738.d8fad088.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFUf2-0000bS-Ti
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 05:47:44 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFUf5-0003j3-LM
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 05:47:49 -0700
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

A minor thing, but useful when working with a server with multiple
addrs. This looks like it might also be necessary if Miklos' effort
to eliminate /etc/mtab ever comes to fruition.

When displaying mount options in /proc/mounts, the kernel prints
"addr=hostname". This info is redundant since we already have the
hostname displayed as part of the "device" section of the mount. This
patch changes it to display the IP address to which the socket is
connected.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6228a16..7854a35 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -509,8 +509,8 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 
 	nfs_show_mount_options(m, nfss, 0);
 
-	seq_puts(m, ",addr=");
-	seq_escape(m, nfss->nfs_client->cl_hostname, " \t\n\\");
+	seq_printf(m, ",addr="NIPQUAD_FMT,
+		NIPQUAD(nfss->nfs_client->cl_addr.sin_addr));
 
 	return 0;
 }
-- 
1.5.2.2

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
