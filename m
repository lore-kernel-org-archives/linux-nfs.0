From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/17] mount.nfs: White space clean up
Date: Sun, 15 Jul 2007 23:16:15 -0400
Message-ID: <20070716031615.11209.78383.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH4L-0001vK-SS
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:18 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH4P-0000OF-Bn
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:21 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c           |   55 +++++++++++++++++++++++++----------------
 utils/mount/mount_constants.h |    1 -
 2 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 6f98eae..f1eab0a 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -64,12 +64,14 @@ static struct option longopts[] = {
   { NULL, 0, 0, 0 }
 };
 
-/* Map from -o and fstab option strings to the flag argument to mount(2).  */
+/*
+ * Map from -o and fstab option strings to the flag argument to mount(2).
+ */
 struct opt_map {
-  const char *opt;              /* option name */
-  int  skip;                    /* skip in mtab option string */
-  int  inv;                     /* true if flag value should be inverted */
-  int  mask;                    /* flag mask value */
+	const char *opt;	/* option name */
+	int skip;		/* skip in mtab option string */
+	int inv;		/* true if flag value should be inverted */
+	int mask;		/* flag mask value */
 };
 
 static const struct opt_map opt_map[] = {
@@ -183,8 +185,11 @@ static void print_one(char *spec, char *node, char *type, char *opts)
 	}
 }
 
-/* Try to build a canonical options string.  */
-static char * fix_opts_string (int flags, const char *extra_opts) {
+/*
+ * Build a canonical mount option string for /etc/mtab.
+ */
+static char *fix_opts_string(int flags, const char *extra_opts)
+{
 	const struct opt_map *om;
 	char *new_opts;
 
@@ -277,8 +282,8 @@ void mount_usage()
 	printf("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n");
 }
 
-static inline void
-parse_opt(const char *opt, int *mask, char *extra_opts, int len) {
+static void parse_opt(const char *opt, int *mask, char *extra_opts, int len)
+{
 	const struct opt_map *om;
 
 	for (om = opt_map; om->opt != NULL; om++) {
@@ -300,30 +305,35 @@ parse_opt(const char *opt, int *mask, char *extra_opts, int len) {
 		strcat(extra_opts, opt);
 }
 
-/* Take -o options list and compute 4th and 5th args to mount(2).  flags
-   gets the standard options (indicated by bits) and extra_opts all the rest */
-static void parse_opts (const char *options, int *flags, char **extra_opts)
+/*
+ * Convert the provided mount command-line options into the 4th &
+ * 5th arguments to mount(2).  Output parameter "@flags" gets the
+ * standard options (indicated by MS_ bits), and output parameter
+ * "@extra_opts" gets all the filesystem-specific options.
+ */
+static void parse_opts(const char *options, int *flags, char **extra_opts)
 {
 	if (options != NULL) {
 		char *opts = xstrdup(options);
 		char *opt, *p;
-		int len = strlen(opts) + 1;		/* include room for a null */
+		int len = strlen(opts) + 1;	/* include room for a null */
 		int open_quote = 0;
 
 		*extra_opts = xmalloc(len);
 		**extra_opts = '\0';
 
-		for (p=opts, opt=NULL; p && *p; p++) {
+		for (p = opts, opt = NULL; p && *p; p++) {
 			if (!opt)
-				opt = p;		/* begin of the option item */
+				opt = p;	/* begin of the option item */
 			if (*p == '"')
-				open_quote ^= 1;	/* reverse the status */
+				open_quote ^= 1; /* reverse the status */
 			if (open_quote)
-				continue;		/* still in a quoted block */
+				continue;	/* still in a quoted block */
 			if (*p == ',')
-				*p = '\0';		/* terminate the option item */
+				*p = '\0';	/* terminate the option item */
+
 			/* end of option item or last item */
-			if (*p == '\0' || *(p+1) == '\0') {
+			if (*p == '\0' || *(p + 1) == '\0') {
 				parse_opt(opt, flags, *extra_opts, len);
 				opt = NULL;
 			}
@@ -424,8 +434,10 @@ int main(int argc, char *argv[])
 			exit(EX_USAGE);
 		}
 	}
-	if (optind != argc-2) {
-		/* Extra non-option words at the end... */
+	/*
+	 * Extra non-option words at the end...
+	 */
+	if (optind != argc - 2) {
 		mount_usage();
 		exit(EX_USAGE);
 	}
@@ -503,4 +515,3 @@ out:
 	free(mount_point);
 	exit(mnt_err);
 }
-
diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
index 3e40841..914deb7 100644
--- a/utils/mount/mount_constants.h
+++ b/utils/mount/mount_constants.h
@@ -56,4 +56,3 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
 #endif
 
 #endif /* _NFS_MOUNT_CONSTANTS_H */
-


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
