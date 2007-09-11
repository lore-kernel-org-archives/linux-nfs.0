From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/19] text-based mount.nfs: Fix mounthost= processing
Date: Mon, 10 Sep 2007 20:58:44 -0400
Message-ID: <20070911005844.24927.84467.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu5W-0002w6-Up
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:47 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu5b-00017f-KH
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:51 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0wYMn027681
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:58:34 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0wiZv025008
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:58:45 -0400
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

This will require changes in the kernel to recognize the new option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 3d20d39..da9c14a 100644
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
 	*extra_opts = po_join(options);
 	if (!*extra_opts) {
 		nfs_error(_("%s: internal option parsing error"), progname);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
