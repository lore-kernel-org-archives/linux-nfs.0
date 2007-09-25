From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] text-based mount.nfs: Fix mounthost= processing
Date: Tue, 25 Sep 2007 13:32:00 -0400
Message-ID: <20070925173200.4845.21140.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaEGQ-0001tL-OJ
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:32:02 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaEGV-0001YJ-JK
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:32:07 -0700
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

The 'mounthost=' option names a host where the mountd service is running.
The option is used to direct clients to use a different host for the mountd
procotol than the host where the NFS service is running.

The nfs(5) man page shows that the 'mounthost=' option takes a name, not
an address.  The kernel's text-based mount option parsing logic expects an
IPv4 address.  This is necessary because the kernel cannot itself resolve
hostnames to addresses.

Resolve the hostname and pass in a new mount option that contains the
resolved address, 'mountaddr=', to the kernel.

This requires a patch to the kernel to recognize the new 'mountaddr='
option, and to change the 'mounthost=' parsing logic to treat the value of
this option as a simple string.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e3a3ac9..b31b3a2 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -191,6 +191,30 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
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
+	if (po_append(options, new_option) == PO_SUCCEEDED)
+		return 1;
+	return 0;
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount
@@ -227,6 +251,9 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!append_addr_option(&saddr, options))
 		goto out;
 
+	if (!fix_up_mounthost_opt(options))
+		goto out;
+
 	if (po_join(options, extra_opts) == PO_FAILED) {
 		nfs_error(_("%s: internal option parsing error"), progname);
 		goto out;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
