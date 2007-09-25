From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] text-based mount.nfs: add parser init and destroy
	calls
Date: Tue, 25 Sep 2007 13:31:44 -0400
Message-ID: <20070925173144.4845.37022.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaEGC-0001rB-7l
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:48 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaEGG-0001Rq-Nj
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:53 -0700
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

Introduce parser init and destroy calls in the main text-based mount
handling routines.  Don't actually use the parsed option object yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4dbd19e..bdc8f2c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -305,6 +305,7 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
 int nfsmount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
 {
+	struct mount_options *options = NULL;
 	struct sockaddr_in saddr;
 	char *hostname;
 	int err, retval = EX_FAIL;
@@ -318,6 +319,12 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 
 	extract_interesting_options(*extra_opts);
 
+	options = po_split(*extra_opts);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
 	if (!child && addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
 		goto out;
@@ -326,6 +333,11 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!append_addr_opt(&saddr, extra_opts))
 		goto out;
 
+	if (po_join(options, extra_opts) == PO_FAILED) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
 			progname, *extra_opts);
@@ -341,6 +353,7 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	retval = EX_SUCCESS;
 
 out:
+	po_destroy(options);
 	return retval;
 }
 
@@ -361,6 +374,7 @@ out:
 int nfs4mount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
 {
+	struct mount_options *options = NULL;
 	struct sockaddr_in saddr;
 	char *hostname;
 	int err, retval = EX_FAIL;
@@ -374,6 +388,12 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 
 	extract_interesting_options(*extra_opts);
 
+	options = po_split(*extra_opts);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
 	if (addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
 		goto out;
@@ -385,6 +405,11 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!ca_opt && !append_clientaddr_opt(&saddr, extra_opts))
 		goto out;
 
+	if (po_join(options, extra_opts) == PO_FAILED) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
 			progname, *extra_opts);
@@ -400,5 +425,6 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	retval = EX_SUCCESS;
 
 out:
+	po_destroy(options);
 	return retval;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
