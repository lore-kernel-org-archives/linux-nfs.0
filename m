Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33323 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbGaWO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 18:14:26 -0400
Received: by qged69 with SMTP id d69so55525777qge.0
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 15:14:25 -0700 (PDT)
Subject: [PATCH 6/6] nfsidmap: Clean up other exit status cases
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com
Date: Fri, 31 Jul 2015 15:14:23 -0700
Message-ID: <20150731221423.50685.40853.stgit@seurat.1015granger.net>
In-Reply-To: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
References: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it unambiguous where 0 or 1 represent an exit status.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c |   29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index e9941b4..88e5c1e 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -286,7 +286,7 @@ static int key_invalidate(char *keystr, int keymask)
 
 	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
 		xlog_err("fopen(%s) failed: %m", PROCKEYS);
-		return 1;
+		return EXIT_FAILURE;
 	}
 
 	while(fgets(buf, BUFSIZ, fp) != NULL) {
@@ -325,13 +325,13 @@ static int key_invalidate(char *keystr, int keymask)
 			if (errno != EOPNOTSUPP) {
 				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
 				fclose(fp);
-				return 1;
+				return EXIT_FAILURE;
 			} else {
 				/* older kernel compatibility attempt: */
 				if (keyctl_revoke(key) < 0) {
 					xlog_err("keyctl_revoke(0x%x) failed: %m", key);
 					fclose(fp);
-					return 1;
+					return EXIT_FAILURE;
 				}
 			}
 		}
@@ -339,12 +339,12 @@ static int key_invalidate(char *keystr, int keymask)
 		keymask &= ~mask;
 		if (keymask == 0) {
 			fclose(fp);
-			return 0;
+			return EXIT_SUCCESS;
 		}
 	}
 	xlog_err("'%s' key was not found.", keystr);
 	fclose(fp);
-	return 1;
+	return EXIT_FAILURE;
 }
 
 int main(int argc, char **argv)
@@ -403,7 +403,7 @@ int main(int argc, char **argv)
 
 	if ((rc = nfs4_init_name_mapping(PATH_IDMAPDCONF)))  {
 		xlog_errno(rc, "Unable to create name to user id mappings.");
-		return 1;
+		return EXIT_FAILURE;
 	}
 	if (!verbose)
 		verbose = conf_get_num("General", "Verbosity", 0);
@@ -414,20 +414,18 @@ int main(int argc, char **argv)
 		return list_keyring(DEFAULT_KEYRING);
 
 	if (keystr) {
-		rc = key_invalidate(keystr, keymask);
-		return rc;		
+		return key_invalidate(keystr, keymask);
 	}
 	if (clearing) {
 		xlog_syslog(0);
-		rc = keyring_clear(DEFAULT_KEYRING);
-		return rc;		
+		return keyring_clear(DEFAULT_KEYRING);
 	}
 
 	xlog_stderr(0);
 	if ((argc - optind) != 2) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		xlog_warn(usage, progname);
-		return 1;
+		return EXIT_FAILURE;
 	}
 
 	if (verbose)
@@ -438,13 +436,14 @@ int main(int argc, char **argv)
 	arg = strdup(argv[optind]);
 	if (arg == NULL) {
 		xlog_err("strdup failed: %m");
-		return 1;
+		return EXIT_FAILURE;
 	}
 	type = strtok(arg, ":");
 	value = strtok(NULL, ":");
-    if (value == NULL) {
+	if (value == NULL) {
+		free(arg);
 		xlog_err("Error: Null uid/gid value.");
-		return 1;
+		return EXIT_FAILURE;
 	}
 	if (verbose) {
 		xlog_warn("key: 0x%lx type: %s value: %s timeout %ld",
@@ -464,7 +463,7 @@ int main(int argc, char **argv)
 		rc = name_lookup(value, key, GROUP);
 
 	/* Set timeout to 10 (600 seconds) minutes */
-	if (rc == 0)
+	if (rc == EXIT_SUCCESS)
 		keyctl_set_timeout(key, timeout);
 
 	free(arg);

