From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] mount.nfs: umount needs to pick up transport
	option	from /etc/mtab
Date: Fri, 03 Aug 2007 13:23:39 -0400
Message-ID: <20070803172339.3357.92975.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0sV-0001wm-9O
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:55 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sZ-0000QQ-4o
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:59 -0700
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

Now that umount's default transport protocol has become more flexible, it
will need to detect both proto=udp and proto=tcp in /etc/mtab.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index e8814a3..a78ab26 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -119,6 +119,16 @@ static int del_mtab(const char *spec, const char *node)
         return EX_FILEIO;
 }
 
+/*
+ * Pick up certain mount options used during the original mount
+ * from /etc/mtab.  The basics include the server's IP address and
+ * the server pathname of the share to unregister.
+ *
+ * These options might also describe the mount port, mount protocol
+ * version, and transport protocol used to punch through a firewall.
+ * We will need this information to get through the firewall again
+ * to do the umount.
+ */
 static int do_nfs_umount(const char *spec, char *opts)
 {
 	char *hostname;
@@ -184,6 +194,8 @@ static int do_nfs_umount(const char *spec, char *opts)
 		pmap->pm_vers = atoi(p+10);
 	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
 		pmap->pm_prot = IPPROTO_UDP;
+	if (opts && (hasmntopt(&mnt, "tcp") || hasmntopt(&mnt, "proto=tcp")))
+		pmap->pm_prot = IPPROTO_TCP;
 
 	if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
 		nfs_error(_("%s: '%s' does not contain a recognized hostname"),


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
