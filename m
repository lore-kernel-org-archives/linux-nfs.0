From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 10/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:49:56 -0400
Message-ID: <4A7B25D4.4070204@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B2324.9090406@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 8157fe02ca0d056eb58ba94e8dabd14ead29d2fd
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Aug 6 13:11:00 2009 -0400

    Now that only the Section names are case-insensitive
    the mount code has to make sure the the mount
    options given to the kernel are in the correct
    case.
    
    Fixed a couple of warnings on #ifndefs
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/conffile.h b/support/include/conffile.h
index b263581..6fc5d60 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -64,4 +64,14 @@ extern int      conf_remove(int, char *, char *);
 extern int      conf_remove_section(int, char *);
 extern void     conf_report(void);
 
+/*
+ * Convert letter from upper case to lower case
+ */
+static inline void upper2lower(char *str)
+{
+	char *ptr = str;
+
+	while (*ptr) 
+		*ptr++ = tolower(*ptr);
+}
 #endif				/* _CONFFILE_H_ */
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 97dc88a..b19b739 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -120,18 +120,6 @@ conf_hash(char *s)
 }
 
 /*
- * Convert letter from upper case to lower case
- */
-static inline void upper2lower(char *str)
-{
-	char *ptr = str;
-
-	while (*ptr) 
-		*ptr++ = tolower(*ptr);
-}
-
-
-/*
  * Insert a tag-value combination from LINE (the equal sign is at POS)
  */
 static int
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index cad8c52..e347b0e 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -37,11 +37,11 @@
 #define NFSMOUNT_GLOBAL_OPTS "NFSMount_Global_Options"
 #endif
 
-#ifndef NFSMOUNT_MOUNTPOINT  "MountPoint"
+#ifndef NFSMOUNT_MOUNTPOINT
 #define NFSMOUNT_MOUNTPOINT "MountPoint"
 #endif
 
-#ifndef NFSMOUNT_SERVER "Server"
+#ifndef NFSMOUNT_SERVER
 #define NFSMOUNT_SERVER "Server"
 #endif
 
@@ -83,6 +83,9 @@ char *mountopts_alias(char *opt, int *argtype)
 		*argtype = mnt_alias_tab[i].argtype;
 		return mnt_alias_tab[i].opt;
 	}
+	/* Make option names case-insensitive */
+	upper2lower(opt);
+
 	return opt;
 }
 /*
@@ -202,7 +205,7 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		 * Do not overwrite options if already exists 
 		 */
 		snprintf(buf, BUFSIZ, "%s=", node->field);
-		if (opts && strstr(opts, buf) != NULL)
+		if (opts && strcasestr(opts, buf) != NULL)
 			continue;
 		if (lookup_entry(node->field) != NULL)
 			continue;
