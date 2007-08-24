From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/9] mount.nfs: Don't allow the user to specify addr=
	or	clientaddr=.
Date: Fri, 24 Aug 2007 13:11:16 -0400
Message-ID: <20070824171116.10418.56059.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOchH-0003wk-Db
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:47 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOchL-00066P-Lb
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:51 -0700
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

The current mount.nfs implementation doesn't allow users to specify their
own addr= or clientaddr= option.  The new string-based interface does
allow this, even though nfs(5) does not document 'addr=' and specifically
forbids adding 'clientaddr='.

Make the addition of either option by the user a permanent error.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ca79ce0..e43bbf4 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -130,7 +130,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 
 /*
  * Walk through our mount options string, and indicate the presence
- * of 'bg', 'retry=', and 'clientaddr='.
+ * of 'bg', 'retry=', 'addr=', and 'clientaddr='.
  */
 static void extract_interesting_options(char *opts)
 {
@@ -161,9 +161,10 @@ static void extract_interesting_options(char *opts)
 }
 
 /*
- * Append the "addr=" option to the options string.
+ * Append the 'addr=' option to the options string.
  *
- * We always add our own addr= to the end of the options string.
+ * Returns 1 if 'addr=' option created successfully;
+ * otherwise zero.
  */
 static int append_addr_opt(const char *spec, char **extra_opts)
 {
@@ -206,9 +207,9 @@ static int append_addr_opt(const char *spec, char **extra_opts)
 }
 
 /*
- * Append the "clientaddr=" option to the options string.
+ * Append the 'clientaddr=' option to the options string.
  *
- * Returns 1 if clientaddr option created successfully;
+ * Returns 1 if 'clientaddr=' option created successfully;
  * otherwise zero.
  */
 static int append_clientaddr_opt(const char *spec, char **extra_opts)
@@ -257,7 +258,12 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 
 	extract_interesting_options(*extra_opts);
 
-	if (!addr_opt && !append_addr_opt(spec, extra_opts))
+	if (!bg && addr_opt) {
+		nfs_error(_("%s: Illegal option: 'addr='"), progname);
+		goto fail;
+	}
+
+	if (!append_addr_opt(spec, extra_opts))
 		goto fail;
 
 	if (verbose)
@@ -299,10 +305,20 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 
 	extract_interesting_options(*extra_opts);
 
-	if (!addr_opt && !append_addr_opt(spec, extra_opts))
+	if (addr_opt) {
+		nfs_error(_("%s: Illegal option: 'addr='"), progname);
+		goto fail;
+	}
+
+	if (ca_opt) {
+		nfs_error(_("%s: Illegal option: 'clientaddr='"), progname);
+		goto fail;
+	}
+
+	if (!append_addr_opt(spec, extra_opts))
 		goto fail;
 
-	if (!ca_opt && !append_clientaddr_opt(spec, extra_opts))
+	if (!append_clientaddr_opt(spec, extra_opts))
 		goto fail;
 
 	if (verbose)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
