From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/24] libnsm.a: Factor atomic write code out of
	nsm_get_state()
Date: Thu, 14 Jan 2010 12:31:11 -0500
Message-ID: <20100114173111.26079.38685.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32373 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757399Ab0ANRb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:29 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're about to use the same logic (mktemp, write, rename) for
other new purposes, so pull it out into its own function.

This change also addresses a latent bug: O_TRUNC is now used when
creating the temporary file.  This eliminates the possibility of
getting stale data in the temp file, if somehow a previous "atomic
write" was interrupted and didn't remove the temporary file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nsm/file.c |  134 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 89 insertions(+), 45 deletions(-)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index fc3241a..10769d9 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -195,6 +195,94 @@ nsm_make_pathname(const char *directory)
 	return path;
 }
 
+/*
+ * Returns a dynamically allocated, '\0'-terminated buffer
+ * containing an appropriate pathname, or NULL if an error
+ * occurs.  Caller must free the returned result with free(3).
+ */
+__attribute_malloc__
+static char *
+nsm_make_temp_pathname(const char *pathname)
+{
+	size_t size;
+	char *path;
+	int len;
+
+	size = strlen(pathname) + sizeof(".new") + 2;
+	if (size > PATH_MAX)
+		return NULL;
+
+	path = malloc(size);
+	if (path == NULL)
+		return NULL;
+
+	len = snprintf(path, size, "%s.new", pathname);
+	if (error_check(len, size)) {
+		free(path);
+		return NULL;
+	}
+
+	return path;
+}
+
+/*
+ * Use "mktemp, write, rename" to update the contents of a file atomically.
+ *
+ * Returns true if completely successful, or false if some error occurred.
+ */
+static _Bool
+nsm_atomic_write(const char *path, const void *buf, const size_t buflen)
+{
+	_Bool result = false;
+	ssize_t len;
+	char *temp;
+	int fd;
+
+	temp = nsm_make_temp_pathname(path);
+	if (temp == NULL) {
+		xlog(L_ERROR, "Failed to create new path for %s", path);
+		goto out;
+	}
+
+	fd = open(temp, O_CREAT | O_TRUNC | O_SYNC | O_WRONLY, 0644);
+	if (fd == -1) {
+		xlog(L_ERROR, "Failed to create %s: %m", temp);
+		goto out;
+	}
+
+	len = write(fd, buf, buflen);
+	if (exact_error_check(len, buflen)) {
+		xlog(L_ERROR, "Failed to write %s: %m", temp);
+		(void)close(fd);
+		(void)unlink(temp);
+		goto out;
+	}
+
+	if (close(fd) == -1) {
+		xlog(L_ERROR, "Failed to close %s: %m", temp);
+		(void)unlink(temp);
+		goto out;
+	}
+
+	if (rename(temp, path) == -1) {
+		xlog(L_ERROR, "Failed to rename %s -> %s: %m",
+				temp, path);
+		(void)unlink(temp);
+		goto out;
+	}
+
+	/* Ostensibly, a sync(2) is not needed here because
+	 * open(O_CREAT), write(O_SYNC), and rename(2) are
+	 * already synchronous with persistent storage, for
+	 * any file system we care about. */
+
+	result = true;
+
+out:
+	free(temp);
+	return result;
+}
+
 /**
  * nsm_setup_pathnames - set up pathname
  * @progname: C string containing name of program, for error messages
@@ -326,7 +414,6 @@ nsm_get_state(_Bool update)
 	int fd, state = 0;
 	ssize_t result;
 	char *path = NULL;
-	char *newpath = NULL;
 
 	path = nsm_make_pathname(NSM_STATE_FILE);
 	if (path == NULL) {
@@ -365,54 +452,11 @@ update:
 
 	if (update) {
 		state += 2;
-
-		newpath = nsm_make_pathname(NSM_STATE_FILE ".new");
-		if (newpath == NULL) {
-			xlog(L_ERROR,
-			  "Failed to create path for " NSM_STATE_FILE ".new");
-			state = 0;
-			goto out;
-		}
-
-		fd = open(newpath, O_CREAT | O_SYNC | O_WRONLY, 0644);
-		if (fd == -1) {
-			xlog(L_ERROR, "Failed to create %s: %m", newpath);
-			state = 0;
-			goto out;
-		}
-
-		result = write(fd, &state, sizeof(state));
-		if (exact_error_check(result, sizeof(state))) {
-			xlog(L_ERROR, "Failed to write %s: %m", newpath);
-			(void)close(fd);
-			(void)unlink(newpath);
-			state = 0;
-			goto out;
-		}
-
-		if (close(fd) == -1) {
-			xlog(L_ERROR, "Failed to close %s: %m", newpath);
-			(void)unlink(newpath);
-			state = 0;
-			goto out;
-		}
-
-		if (rename(newpath, path) == -1) {
-			xlog(L_ERROR, "Failed to rename %s -> %s: %m",
-					newpath, path);
-			(void)unlink(newpath);
+		if (!nsm_atomic_write(path, &state, sizeof(state)))
 			state = 0;
-			goto out;
-		}
-
-		/* Ostensibly, a sync(2) is not needed here because
-		 * open(O_CREAT), write(O_SYNC), and rename(2) are
-		 * already synchronous with persistent storage, for
-		 * any file system we care about. */
 	}
 
 out:
-	free(newpath);
 	free(path);
 	return state;
 }

