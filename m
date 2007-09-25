From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] text-based mount.nfs: start using new mount
	option	parsing facility
Date: Tue, 25 Sep 2007 13:31:49 -0400
Message-ID: <20070925173149.4845.70715.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaEGB-0001r2-Q8
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:47 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaEGF-0001Se-Mk
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:52 -0700
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

Use the new mount option parsing functions to handle existing mount
option string parsing needs in the text-based mount implementation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   20 +++-----------------
 1 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index bdc8f2c..537a924 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -317,20 +317,13 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!err)
 		goto out;
 
-	extract_interesting_options(*extra_opts);
-
 	options = po_split(*extra_opts);
 	if (!options) {
 		nfs_error(_("%s: internal option parsing error"), progname);
 		goto out;
 	}
 
-	if (!child && addr_opt) {
-		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		goto out;
-	}
-
-	if (!append_addr_opt(&saddr, extra_opts))
+	if (!append_addr_option(&saddr, options))
 		goto out;
 
 	if (po_join(options, extra_opts) == PO_FAILED) {
@@ -386,23 +379,16 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!err)
 		goto out;
 
-	extract_interesting_options(*extra_opts);
-
 	options = po_split(*extra_opts);
 	if (!options) {
 		nfs_error(_("%s: internal option parsing error"), progname);
 		goto out;
 	}
 
-	if (addr_opt) {
-		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		goto out;
-	}
-
-	if (!append_addr_opt(&saddr, extra_opts))
+	if (!append_addr_option(&saddr, options))
 		goto out;
 
-	if (!ca_opt && !append_clientaddr_opt(&saddr, extra_opts))
+	if (!append_clientaddr_option(&saddr, options))
 		goto out;
 
 	if (po_join(options, extra_opts) == PO_FAILED) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
