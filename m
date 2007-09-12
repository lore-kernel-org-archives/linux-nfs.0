From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/24] text-based mount.nfs: Fix mounthost= processing
Date: Wed, 12 Sep 2007 12:15:06 -0400
Message-ID: <20070912161506.23491.18278.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUrs-0004OW-5m
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:09 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUrw-0002MG-5u
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:12 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGEGDm027085
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:14:16 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGF6hc023549
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:15:06 -0400
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

The nfs(5) man page shows that the mounthost= option takes a name, not an
address.  The kernel's text-based mount option parsing logic expects an
IPv4 address.

Resolve the hostname and pass in a new mount option, 'mountaddr=', to the
kernel.  This is necessary because the kernel cannot itself resolve
hostnames to addresses.

This requires a patch to the kernel to recognize the new 'mountaddr='
option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d10e3d3..2fa5781 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -225,6 +225,28 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
 }
 
 /*
+ * Called to resolve the 'mounthost=' hostname and append a new
+ * option using an IPv4 address.
+ */
+static int fix_up_mounthost_opt(struct mount_options *options)
+{
+	struct sockaddr_in maddr;
+	char *mounthost, new_option[32];
+
+	mounthost = po_get(options, "mounthost");
+	if (!mounthost)
+		return 1;
+
+	if (!fill_ipv4_sockaddr(mounthost, &maddr))
+		return 0;
+
+	snprintf(new_option, sizeof(new_option) - 1,
+			"mountaddr=%s", inet_ntoa(maddr.sin_addr));
+
+	return po_append(options, new_option);
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount
@@ -261,6 +283,9 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!append_addr_option(&saddr, options, child))
 		goto out;
 
+	if (!fix_up_mounthost_opt(options))
+		goto out;
+
 	free(*extra_opts);
 	*extra_opts = po_join(options);
 	if (!*extra_opts) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
