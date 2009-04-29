From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/7] gssd: refactor update_client_list()
Date: Wed, 29 Apr 2009 17:56:21 -0400
Message-ID: <20090429215621.25811.84774.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47706 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758250AbZD2V4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:21 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Split out the processing for a pipe to a separate routine.  The next
patch adds a new pipe to be processed.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_main_loop.c |    3 +--
 utils/gssd/gssd_proc.c      |   28 +++++++++++++++++++++-------
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 917b662..397fd14 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -132,8 +132,7 @@ gssd_run()
 		while (dir_changed) {
 			dir_changed = 0;
 			if (update_client_list()) {
-				printerr(0, "ERROR: couldn't update "
-					 "client list\n");
+				/* Error msg is already printed */
 				exit(1);
 			}
 		}
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 02239d2..0fc0c42 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -478,25 +478,25 @@ find_client(char *dirname)
 	return 0;
 }
 
-/* Used to read (and re-read) list of clients, set up poll array. */
-int
-update_client_list(void)
+static int
+process_pipedir(char *pipe_name)
 {
 	struct dirent **namelist;
 	int i, j;
 
-	if (chdir(pipefs_nfsdir) < 0) {
+	if (chdir(pipe_name) < 0) {
 		printerr(0, "ERROR: can't chdir to %s: %s\n",
-			 pipefs_nfsdir, strerror(errno));
+			 pipe_name, strerror(errno));
 		return -1;
 	}
 
-	j = scandir(pipefs_nfsdir, &namelist, NULL, alphasort);
+	j = scandir(pipe_name, &namelist, NULL, alphasort);
 	if (j < 0) {
 		printerr(0, "ERROR: can't scandir %s: %s\n",
-			 pipefs_nfsdir, strerror(errno));
+			 pipe_name, strerror(errno));
 		return -1;
 	}
+
 	update_old_clients(namelist, j);
 	for (i=0; i < j; i++) {
 		if (i < FD_ALLOC_BLOCK
@@ -507,9 +507,23 @@ update_client_list(void)
 	}
 
 	free(namelist);
+
 	return 0;
 }
 
+/* Used to read (and re-read) list of clients, set up poll array. */
+int
+update_client_list(void)
+{
+	int retval = -1;
+
+	retval = process_pipedir(pipefs_nfsdir);
+	if (retval)
+		printerr(0, "ERROR: processing %s\n", pipefs_nfsdir);
+
+	return retval;
+}
+
 static int
 do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	    gss_buffer_desc *context_token)

