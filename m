From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/12] text-based mount.nfs:
Date: Mon, 08 Oct 2007 11:54:07 -0400
Message-ID: <20071008155407.15051.60775.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvp-0007k8-7x
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:09 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuvu-000170-2e
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:14 -0700
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

Introduce a function for probing the server for what it supports, and then
rewriting the mount options using the probe results.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  113 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c048be0..d000695 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -238,6 +238,119 @@ static int set_mandatory_options(const char *type,
 }
 
 /*
+ * Reconstruct the mount option string based on a portmapper probe
+ * of the server.  Returns one if the server's portmapper returned
+ * something we can use, otherwise zero.
+ *
+ * Unfortunately, for fallback, we need to parse out the mount options
+ * in user space.  Unrecognized options are ignored here.
+ *
+ * Order of processing:
+ * 1.  fill in mnt_server and nfs_server, based on existing options
+ * 2.  strip out transport and NFS version related options
+ * 3.  probe the server
+ * 4.  append fresh transport and NFS version related options
+ *
+ * Returns a new group of mount options if successful; otherwise NULL
+ * is returned if some failure occurred.
+ */
+static struct mount_options *rewrite_mount_options(char *str)
+{
+	struct mount_options *options;
+	char *option, new_option[64];
+	clnt_addr_t mnt_server = { };
+	clnt_addr_t nfs_server = { };
+
+	options = po_split(str);
+	if (!options)
+		return NULL;
+
+	option = po_get(options, "addr");
+	if (option) {
+		nfs_server.saddr.sin_family = AF_INET;
+		if (!inet_aton((const char *)option, &nfs_server.saddr.sin_addr))
+			goto err;
+	} else
+		goto err;
+
+	option = po_get(options, "mountaddr");
+	if (option) {
+		mnt_server.saddr.sin_family = AF_INET;
+		if (!inet_aton((const char *)option, &mnt_server.saddr.sin_addr))
+			goto err;
+	} else
+		memcpy(&mnt_server.saddr, &nfs_server.saddr,
+				sizeof(mnt_server.saddr));
+
+	option = po_get(options, "mountport");
+	if (option)
+		mnt_server.pmap.pm_port = atoi(option);
+	mnt_server.pmap.pm_prog = MOUNTPROG;
+	option = po_get(options, "mountprog");
+	if (option)
+		mnt_server.pmap.pm_prog = atoi(option);
+	option = po_get(options, "mountvers");
+	if (option)
+		mnt_server.pmap.pm_vers = atoi(option);
+
+	option = po_get(options, "port");
+	if (option) {
+		nfs_server.pmap.pm_port = atoi(option);
+		po_remove_all(options, "port");
+	}
+	nfs_server.pmap.pm_prog = NFS_PROGRAM;
+	option = po_get(options, "nfsprog");
+	if (option)
+		nfs_server.pmap.pm_prog = atoi(option);
+
+	po_remove_all(options, "nfsvers");
+	po_remove_all(options, "vers");
+	po_remove_all(options, "tcp");
+	po_remove_all(options, "udp");
+
+	option = po_get(options, "proto");
+	if (option) {
+		if (strcmp(option, "tcp") == 0)
+			po_remove_all(options, "proto");
+		if (strcmp(option, "udp") == 0)
+			po_remove_all(options, "proto");
+	}
+
+	if (!probe_bothports(&mnt_server, &nfs_server)) {
+		rpc_mount_errors("rpcbind", 0, 0);
+		goto err;
+	}
+
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "nfsvers=%lu", nfs_server.pmap.pm_vers);
+	if (po_append(options, new_option) == PO_FAILED)
+		goto err;
+
+	if (nfs_server.pmap.pm_prot == IPPROTO_TCP)
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=tcp");
+	else
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=udp");
+	if (po_append(options, new_option) == PO_FAILED)
+		goto err;
+
+	if (nfs_server.pmap.pm_port != NFS_PORT) {
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "port=%lu", nfs_server.pmap.pm_port);
+		if (po_append(options, new_option) == PO_FAILED)
+			goto err;
+
+	}
+
+	return options;
+
+err:
+	po_destroy(options);
+	return NULL;
+}
+
+/*
  * Attempt an NFSv2/3 mount via a mount(2) system call.
  *
  * Returns 1 if successful.  Otherwise, returns zero.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
