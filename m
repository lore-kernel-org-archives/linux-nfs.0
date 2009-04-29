From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 5/7] gssd: handle new client upcall
Date: Wed, 29 Apr 2009 17:56:36 -0400
Message-ID: <20090429215636.25811.40796.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47723 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbZD2V4g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:36 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Add support for handling the new client-side upcall.  The kernel,
beginning with 2.6.29, will attempt to use a new pipe, "gssd",
which can be used for upcalls for all gss mechanisms.

The new upcall is text-based with an <attribute>=<value> format.
Attribute/value pairs are separated by a space, and terminated
with a new-line character.

The intial version has two required attributes,
mech=<gss_mechanism_name> and uid=<user's_UID_number>, and two
optional attributes, target=<gss_target_name> and service=<value>.

Future kernels may add new attribute/value pairs.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.h           |    3 +
 utils/gssd/gssd_main_loop.c |   11 +++
 utils/gssd/gssd_proc.c      |  181 ++++++++++++++++++++++++++++++++++++-------
 3 files changed, 165 insertions(+), 30 deletions(-)

diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index ef2ac54..35da4cf 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -85,6 +85,8 @@ struct clnt_info {
 	int			krb5_poll_index;
 	int			spkm3_fd;
 	int			spkm3_poll_index;
+	int                     gssd_fd;
+	int                     gssd_poll_index;
 	struct sockaddr_storage addr;
 };
 
@@ -92,6 +94,7 @@ void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_spkm3_upcall(struct clnt_info *clp);
+void handle_gssd_upcall(struct clnt_info *clp);
 int gssd_acquire_cred(char *server_name);
 void gssd_run(void);
 
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 1c1ff4f..5a0dda9 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -73,6 +73,17 @@ scan_poll_results(int ret)
 
 	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
 	{
+		i = clp->gssd_poll_index;
+		if (i >= 0 && pollarray[i].revents) {
+			if (pollarray[i].revents & POLLHUP)
+				dir_changed = 1;
+			if (pollarray[i].revents & POLLIN)
+				handle_gssd_upcall(clp);
+			pollarray[clp->gssd_poll_index].revents = 0;
+			ret--;
+			if (!ret)
+				break;
+		}
 		i = clp->krb5_poll_index;
 		if (i >= 0 && pollarray[i].revents) {
 			if (pollarray[i].revents & POLLHUP)
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index c1f0350..2fc26b4 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -73,6 +73,7 @@
 #include "krb5_util.h"
 #include "context.h"
 #include "nfsrpc.h"
+#include "nfslib.h"
 
 /*
  * pollarray:
@@ -289,9 +290,13 @@ destroy_client(struct clnt_info *clp)
 	if (clp->spkm3_poll_index != -1)
 		memset(&pollarray[clp->spkm3_poll_index], 0,
 					sizeof(struct pollfd));
+	if (clp->gssd_poll_index != -1)
+		memset(&pollarray[clp->gssd_poll_index], 0,
+					sizeof(struct pollfd));
 	if (clp->dir_fd != -1) close(clp->dir_fd);
 	if (clp->krb5_fd != -1) close(clp->krb5_fd);
 	if (clp->spkm3_fd != -1) close(clp->spkm3_fd);
+	if (clp->gssd_fd != -1) close(clp->gssd_fd);
 	free(clp->dirname);
 	free(clp->servicename);
 	free(clp->servername);
@@ -311,8 +316,10 @@ insert_new_clnt(void)
 	}
 	clp->krb5_poll_index = -1;
 	clp->spkm3_poll_index = -1;
+	clp->gssd_poll_index = -1;
 	clp->krb5_fd = -1;
 	clp->spkm3_fd = -1;
+	clp->gssd_fd = -1;
 	clp->dir_fd = -1;
 
 	TAILQ_INSERT_HEAD(&clnt_list, clp, list);
@@ -324,17 +331,42 @@ static int
 process_clnt_dir_files(struct clnt_info * clp)
 {
 	char	name[PATH_MAX];
+	char	gname[PATH_MAX];
 	char	info_file_name[PATH_MAX];
 
-	if (clp->krb5_fd == -1) {
-		snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
-		clp->krb5_fd = open(name, O_RDWR);
+	if (clp->gssd_fd == -1) {
+		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
+		clp->gssd_fd = open(gname, O_RDWR);
 	}
-	if (clp->spkm3_fd == -1) {
-		snprintf(name, sizeof(name), "%s/spkm3", clp->dirname);
-		clp->spkm3_fd = open(name, O_RDWR);
+	if (clp->gssd_fd == -1) {
+		if (clp->krb5_fd == -1) {
+			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
+			clp->krb5_fd = open(name, O_RDWR);
+		}
+		if (clp->spkm3_fd == -1) {
+			snprintf(name, sizeof(name), "%s/spkm3", clp->dirname);
+			clp->spkm3_fd = open(name, O_RDWR);
+		}
+
+		/* If we opened a gss-specific pipe, let's try opening
+		 * the new upcall pipe again. If we succeed, close
+		 * gss-specific pipe(s).
+		 */
+		if (clp->krb5_fd != -1 || clp->spkm3_fd != -1) {
+			clp->gssd_fd = open(gname, O_RDWR);
+			if (clp->gssd_fd != -1) {
+				if (clp->krb5_fd != -1)
+					close(clp->krb5_fd);
+				clp->krb5_fd = -1;
+				if (clp->spkm3_fd != -1)
+					close(clp->spkm3_fd);
+				clp->spkm3_fd = -1;
+			}
+		}
 	}
-	if ((clp->krb5_fd == -1) && (clp->spkm3_fd == -1))
+
+	if ((clp->krb5_fd == -1) && (clp->spkm3_fd == -1) &&
+			(clp->gssd_fd == -1))
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
@@ -369,6 +401,15 @@ get_poll_index(int *ind)
 static int
 insert_clnt_poll(struct clnt_info *clp)
 {
+	if ((clp->gssd_fd != -1) && (clp->gssd_poll_index == -1)) {
+		if (get_poll_index(&clp->gssd_poll_index)) {
+			printerr(0, "ERROR: Too many gssd clients\n");
+			return -1;
+		}
+		pollarray[clp->gssd_poll_index].fd = clp->gssd_fd;
+		pollarray[clp->gssd_poll_index].events |= POLLIN;
+	}
+
 	if ((clp->krb5_fd != -1) && (clp->krb5_poll_index == -1)) {
 		if (get_poll_index(&clp->krb5_poll_index)) {
 			printerr(0, "ERROR: Too many krb5 clients\n");
@@ -839,15 +880,13 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	goto out;
 }
 
-
 /*
  * this code uses the userland rpcsec gss library to create a krb5
  * context on behalf of the kernel
  */
-void
-handle_krb5_upcall(struct clnt_info *clp)
+static void
+process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd)
 {
-	uid_t			uid;
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
 	struct authgss_private_data pd;
@@ -863,12 +902,6 @@ handle_krb5_upcall(struct clnt_info *clp)
 	token.value = NULL;
 	memset(&pd, 0, sizeof(struct authgss_private_data));
 
-	if (read(clp->krb5_fd, &uid, sizeof(uid)) < sizeof(uid)) {
-		printerr(0, "WARNING: failed reading uid from krb5 "
-			    "upcall pipe: %s\n", strerror(errno));
-		goto out;
-	}
-
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
@@ -939,7 +972,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		goto out_return_error;
 	}
 
-	do_downcall(clp->krb5_fd, uid, &pd, &token);
+	do_downcall(fd, uid, &pd, &token);
 
 out:
 	if (token.value)
@@ -955,7 +988,7 @@ out:
 	return;
 
 out_return_error:
-	do_error_downcall(clp->krb5_fd, uid, -1);
+	do_error_downcall(fd, uid, -1);
 	goto out;
 }
 
@@ -963,10 +996,9 @@ out_return_error:
  * this code uses the userland rpcsec gss library to create an spkm3
  * context on behalf of the kernel
  */
-void
-handle_spkm3_upcall(struct clnt_info *clp)
+static void
+process_spkm3_upcall(struct clnt_info *clp, uid_t uid, int fd)
 {
-	uid_t			uid;
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
 	struct authgss_private_data pd;
@@ -977,12 +1009,6 @@ handle_spkm3_upcall(struct clnt_info *clp)
 	token.length = 0;
 	token.value = NULL;
 
-	if (read(clp->spkm3_fd, &uid, sizeof(uid)) < sizeof(uid)) {
-		printerr(0, "WARNING: failed reading uid from spkm3 "
-			 "upcall pipe: %s\n", strerror(errno));
-		goto out;
-	}
-
 	if (create_auth_rpc_client(clp, &rpc_clnt, &auth, uid, AUTHTYPE_SPKM3)) {
 		printerr(0, "WARNING: Failed to create spkm3 context for "
 			    "user with uid %d\n", uid);
@@ -1003,7 +1029,7 @@ handle_spkm3_upcall(struct clnt_info *clp)
 		goto out_return_error;
 	}
 
-	do_downcall(clp->spkm3_fd, uid, &pd, &token);
+	do_downcall(fd, uid, &pd, &token);
 
 out:
 	if (token.value)
@@ -1015,6 +1041,101 @@ out:
 	return;
 
 out_return_error:
-	do_error_downcall(clp->spkm3_fd, uid, -1);
+	do_error_downcall(fd, uid, -1);
 	goto out;
 }
+
+void
+handle_krb5_upcall(struct clnt_info *clp)
+{
+	uid_t			uid;
+
+	if (read(clp->krb5_fd, &uid, sizeof(uid)) < sizeof(uid)) {
+		printerr(0, "WARNING: failed reading uid from krb5 "
+			    "upcall pipe: %s\n", strerror(errno));
+		return;
+	}
+
+	return process_krb5_upcall(clp, uid, clp->krb5_fd);
+}
+
+void
+handle_spkm3_upcall(struct clnt_info *clp)
+{
+	uid_t			uid;
+
+	if (read(clp->spkm3_fd, &uid, sizeof(uid)) < sizeof(uid)) {
+		printerr(0, "WARNING: failed reading uid from spkm3 "
+			 "upcall pipe: %s\n", strerror(errno));
+		return;
+	}
+
+	return process_spkm3_upcall(clp, uid, clp->spkm3_fd);
+}
+
+void
+handle_gssd_upcall(struct clnt_info *clp)
+{
+	uid_t			uid;
+	char			*lbuf = NULL;
+	int			lbuflen = 0;
+	char			*p;
+	char			*mech = NULL;
+
+	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
+
+	if (readline(clp->gssd_fd, &lbuf, &lbuflen) != 1) {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			    "failed reading request\n");
+		return;
+	}
+	printerr(2, "%s: '%s'\n", __func__, lbuf);
+
+	/* find the mechanism name */
+	if ((p = strstr(lbuf, "mech=")) != NULL) {
+		mech = malloc(lbuflen);
+		if (!mech)
+			goto out;
+		if (sscanf(p, "mech=%s", mech) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse gss mechanism name "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	} else {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			    "failed to find gss mechanism name "
+			    "in upcall string '%s'\n", lbuf);
+		goto out;
+	}
+
+	/* read uid */
+	if ((p = strstr(lbuf, "uid=")) != NULL) {
+		if (sscanf(p, "uid=%d", &uid) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse uid "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	} else {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			    "failed to find uid "
+			    "in upcall string '%s'\n", lbuf);
+		goto out;
+	}
+
+
+	if (strcmp(mech, "krb5") == 0)
+		process_krb5_upcall(clp, uid, clp->gssd_fd);
+	else if (strcmp(mech, "spkm3") == 0)
+		process_spkm3_upcall(clp, uid, clp->gssd_fd);
+	else
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			    "received unknown gss mech '%s'\n", mech);
+
+out:
+	free(lbuf);
+	free(mech);
+	return;	
+}
+

