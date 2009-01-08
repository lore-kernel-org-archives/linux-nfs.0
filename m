From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] text-based mount command: make po_rightmost() work for N
	options
Date: Thu, 08 Jan 2009 12:32:42 -0500
Message-ID: <20090108173241.19893.57156.stgit@ingres.1015granger.net>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:64539 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbZAHRdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:33:16 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sometimes we need to choose the rightmost option among multiple
different mount options.  For example, we want to find the rightmost
of "proto," "tcp," and "udp".  Or, the rightmost of "vers," "nfsvers,"
"v2," and "v3".

Update po_rightmost() to choose among N options instead of just two.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/parse_opt.c |   28 ++++++++++++++++------------
 utils/mount/parse_opt.h |    9 ++-------
 utils/mount/stropts.c   |   28 +++++++++++++++++++++++-----
 3 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index f61d0dd..4934508 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -421,34 +421,38 @@ po_found_t po_get_numeric(struct mount_options *options, char *keyword, long *va
 #endif	/* HAVE_STRTOL */
 
 /**
- * po_rightmost - determine the relative position of two options
+ * po_rightmost - determine the relative position of several options
  * @options: pointer to mount options
- * @key1: pointer to a C string containing an option keyword
- * @key2: pointer to a C string containing another option keyword
+ * @keys: pointer to an array of C strings containing option keywords
+ *
+ * This function can be used to determine which of several similar
+ * options will be the one to take effect.
  *
  * The kernel parses the mount option string from left to right.
  * If an option is specified more than once (for example, "intr"
  * and "nointr", the rightmost option is the last to be parsed,
  * and it therefore takes precedence over previous similar options.
  *
- * This function can be used to determine which of two similar
- * options will be the one to take effect.
+ * This can also distinguish among multiple synonymous options, such
+ * as "proto=," "udp" and "tcp."
+ *
+ * Returns the index into @keys of the option that is rightmost.
+ * If none of the options are present, returns zero.
  */
-po_rightmost_t po_rightmost(struct mount_options *options,
-			    char *key1, char *key2)
+unsigned int po_rightmost(struct mount_options *options, const char *keys[])
 {
 	struct mount_option *option;
+	unsigned int i;
 
 	if (options) {
 		for (option = options->tail; option; option = option->prev) {
-			if (key2 && strcmp(option->keyword, key2) == 0)
-				return PO_KEY2_RIGHTMOST;
-			if (key1 && strcmp(option->keyword, key1) == 0)
-				return PO_KEY1_RIGHTMOST;
+			for (i = 0; keys[i] != NULL; i++)
+				if (strcmp(option->keyword, keys[i]) == 0)
+					return i;
 		}
 	}
 
-	return PO_NEITHER_FOUND;
+	return 0;
 }
 
 /**
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index 199630f..e132b1c 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -35,12 +35,6 @@ typedef enum {
 	PO_BAD_VALUE = 2,
 } po_found_t;
 
-typedef enum {
-	PO_KEY1_RIGHTMOST = -1,
-	PO_NEITHER_FOUND = 0,
-	PO_KEY2_RIGHTMOST = 1,
-} po_rightmost_t;
-
 struct mount_options;
 
 struct mount_options *	po_split(char *);
@@ -53,7 +47,8 @@ po_found_t		po_contains(struct mount_options *, char *);
 char *			po_get(struct mount_options *, char *);
 po_found_t		po_get_numeric(struct mount_options *,
 					char *, long *);
-po_rightmost_t		po_rightmost(struct mount_options *, char *, char *);
+unsigned int		po_rightmost(struct mount_options *,
+					const char *keys[]);
 po_found_t		po_remove_all(struct mount_options *, char *);
 void			po_destroy(struct mount_options *);
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 43791e6..bd127ab 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -224,9 +224,15 @@ static int nfs_fix_mounthost_option(const sa_family_t family,
  * Returns zero if the "lock" option is in effect, but statd
  * can't be started.  Otherwise, returns 1.
  */
+static const char *nfs_lock_opttbl[] = {
+	"nolock",
+	"lock",
+	NULL,
+};
+
 static int nfs_verify_lock_option(struct mount_options *options)
 {
-	if (po_rightmost(options, "nolock", "lock") == PO_KEY1_RIGHTMOST)
+	if (po_rightmost(options, nfs_lock_opttbl) == 1)
 		return 1;
 
 	if (!start_statd()) {
@@ -316,6 +322,12 @@ static int nfs_is_permanent_error(int error)
  * Returns a new group of mount options if successful; otherwise
  * NULL is returned if some failure occurred.
  */
+static const char *nfs_transport_opttbl[] = {
+	"udp",
+	"tcp",
+	NULL,
+};
+
 static struct mount_options *nfs_rewrite_mount_options(char *str)
 {
 	struct mount_options *options;
@@ -395,12 +407,12 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 			po_remove_all(options, "proto");
 		}
 	}
-	p = po_rightmost(options, "tcp", "udp");
+	p = po_rightmost(options, nfs_transport_opttbl);
 	switch (p) {
-	case PO_KEY2_RIGHTMOST:
+	case 1:
 		nfs_server.pmap.pm_prot = IPPROTO_UDP;
 		break;
-	case PO_KEY1_RIGHTMOST:
+	case 2:
 		nfs_server.pmap.pm_prot = IPPROTO_TCP;
 		break;
 	}
@@ -722,12 +734,18 @@ static int nfsmount_bg(struct nfsmount_info *mi)
  *
  * Returns a valid mount command exit code.
  */
+static const char *nfs_background_opttbl[] = {
+	"bg",
+	"fg",
+	NULL,
+};
+
 static int nfsmount_start(struct nfsmount_info *mi)
 {
 	if (!nfs_validate_options(mi))
 		return EX_FAIL;
 
-	if (po_rightmost(mi->options, "bg", "fg") == PO_KEY1_RIGHTMOST)
+	if (po_rightmost(mi->options, nfs_background_opttbl) == 1)
 		return nfsmount_bg(mi);
 	else
 		return nfsmount_fg(mi);

