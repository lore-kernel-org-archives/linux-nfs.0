From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/19] text-based mount.nfs:
Date: Mon, 10 Sep 2007 20:59:27 -0400
Message-ID: <20070911005927.24927.3232.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu67-00032r-Vt
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:24 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6C-00086k-K0
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:28 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xGBt028591
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:17 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0xRpS025056
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:59:27 -0400
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
rewriting the mount options as a result.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  140 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 140 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 03267be..deaf9e1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -210,6 +210,146 @@ static int fix_up_mounthost_opt(struct mount_options *options)
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
+ * Returns 1 if successful.  Otherwise, returns zero.
+ */
+static int rewrite_mount_opts(struct mount_options *options)
+{
+	char *option, new_option[64];
+	clnt_addr_t mnt_server = { };
+	clnt_addr_t nfs_server = { };
+
+	option = po_get(options, "addr");
+	if (option) {
+		if (!inet_aton((const char *)option, &nfs_server.saddr.sin_addr))
+			return 0;
+	}
+
+	option = po_get(options, "mountaddr");
+	if (option) {
+		if (!inet_aton((const char *)option, &mnt_server.saddr.sin_addr))
+			return 0;
+	} else
+		memcpy(&mnt_server.saddr, &nfs_server.saddr,
+				sizeof(mnt_server.saddr));
+
+	option = po_get(options, "mountport");
+	if (option) {
+		mnt_server.pmap.pm_port = atoi(option);
+		po_remove_all(options, "mountport");
+	}
+	mnt_server.pmap.pm_prog = MOUNTPROG;
+	option = po_get(options, "mountprog");
+	if (option) {
+		mnt_server.pmap.pm_prog = atoi(option);
+		po_remove_all(options, "mountprog");
+	}
+	option = po_get(options, "mountvers");
+	if (option) {
+		mnt_server.pmap.pm_vers = atoi(option);
+		po_remove_all(options, "mountvers");
+	}
+
+	option = po_get(options, "port");
+	if (option) {
+		nfs_server.pmap.pm_port = atoi(option);
+		po_remove_all(options, "port");
+	}
+	nfs_server.pmap.pm_prog = NFS_PROGRAM;
+	option = po_get(options, "nfsprog");
+	if (option) {
+		nfs_server.pmap.pm_prog = atoi(option);
+		po_remove_all(options, "nfsprog");
+	}
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
+		return 0;
+	}
+
+	if (mnt_server.pmap.pm_prog != MOUNTPROG) {
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "mountprog=%lu", mnt_server.pmap.pm_prog);
+		if (!po_append(options, new_option))
+			return 0;
+	}
+
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "mountvers=%lu", mnt_server.pmap.pm_vers);
+	if (!po_append(options, new_option))
+		return 0;
+
+	if (mnt_server.pmap.pm_prot == IPPROTO_TCP)
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "mountprot=tcp");
+	else
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "mountprot=udp");
+	if (!po_append(options, new_option))
+		return 0;
+
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "mountport=%lu", mnt_server.pmap.pm_port);
+	if (!po_append(options, new_option))
+		return 0;
+
+	if (nfs_server.pmap.pm_prog != NFS_PROGRAM) {
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "nfsprog=%lu", nfs_server.pmap.pm_prog);
+		if (!po_append(options, new_option))
+			return 0;
+	}
+
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "nfsvers=%lu", nfs_server.pmap.pm_vers);
+	po_append(options, new_option);
+
+	if (nfs_server.pmap.pm_prot == IPPROTO_TCP)
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=tcp");
+	else
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=udp");
+	if (!po_append(options, new_option))
+		return 0;
+
+	if (nfs_server.pmap.pm_port != NFS_PORT) {
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "port=%lu", nfs_server.pmap.pm_port);
+		if (!po_append(options, new_option))
+			return 0;
+
+	}
+
+	return 1;
+}
+
+/*
  * Attempt an NFS mount via a mount(2) system call.
  *
  * Returns 1 if successful.  Otherwise, returns zero.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
