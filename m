From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: add mountproto= mount option to force
 mount protocol
Date: Fri, 22 Jun 2007 10:27:33 -0400
Message-ID: <20070622102733.2686b9ca.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1k6r-0000lN-Ki
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 07:27:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I1k6u-0002Lp-Mw
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 07:27:41 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l5MERYSA013514
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:27:34 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l5MERYXo020452
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:27:34 -0400
Received: from tupile.connectathon.org (vpn-14-92.rdu.redhat.com [10.11.14.92])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l5MERY2W025181
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:27:34 -0400
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

Recently some changes were made to mount.nfs to make mount.nfs use UDP
by default to talk to mountd. If someone specifies tcp or proto=tcp as
an option, then the communication with mountd is also done via TCP.
Most people can just remove these options to work around this since TCP
is the new default. If someone is using shared automount maps on a
network that hosts a mix of clients with different protocol defaults,
then they can't do this without making the old clients fall back to
using UDP.

This patch adds a new mount option "mountproto" that forces the client
to use a specific network protocol when talking to mountd, and updates
the nfs manpage to describe the new option. It should apply cleanly to
current nfs-utils git tree.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 673556c..bcc1a13 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -170,6 +170,20 @@ for hosts that can run multiple NFS servers.
 The default value is 100005 which is the standard RPC
 mount daemon program number.
 .TP 1.5i
+.I mountproto=n
+Force the mount call to use a specific network protocol
+independent of the NFS protocol used.
+Valid protocol types are
+.IR udp
+and
+.IR tcp .
+The default is to use UDP and then fall back to TCP if the
+server doesn't respond. If the
+.IR proto=tcp
+or
+.IR tcp
+options are specified, then the default is to just use TCP.
+.TP 1.5i
 .I mountvers=n
 Use an alternate RPC version number to contact the
 mount daemon on the remote host.  This option is useful
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 815064a..ec54c99 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -547,6 +547,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap *nfs_pmap = &nfs_server->pmap;
+	unsigned long mountproto = 0;
 	int len;
 	char *opt, *opteq, *p, *opt_b;
 	char *mounthost = NULL;
@@ -714,6 +715,18 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				else
 					strncpy(data->context, context,
 							NFS_MAX_CONTEXT_LEN);
+			} else if  (!strcmp(opt, "mountproto")) {
+				if (!strcmp(opteq+1, "udp"))
+					mountproto = IPPROTO_UDP;
+#if NFS_MOUNT_VERSION >= 2
+				else if (!strcmp(opteq+1, "tcp") &&
+					   nfs_mount_version > 2)
+					mountproto = IPPROTO_TCP;
+#endif
+				else if (sloppy)
+					continue;
+				else
+					goto bad_parameter;
  			} else if (sloppy)
 				continue;
 			else
@@ -822,6 +835,11 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 		}
 		strcat(new_opts, cbuf);
 	}
+
+	/* override mount protocol if it was specified */
+	if (mountproto)
+		mnt_pmap->pm_prot = mountproto;
+
 	/* See if the nfs host = mount host. */
 	if (mounthost) {
 		if (!nfs_gethostbyname(mounthost, mnt_saddr))

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
