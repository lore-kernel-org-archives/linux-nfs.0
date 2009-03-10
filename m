From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix potential double-frees in gssd
Date: Tue, 10 Mar 2009 16:43:56 -0400
Message-ID: <1236717836-14015-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

If read_service_info() fails, it'll free any of the strings that were
allocated, but it doesn't zero out the pointers. If we end up calling
destroy_client on this struct afterward, then we may end up
double-freeing those pointers.

It may be that this is not really a danger with the current way the code
is structured. It may not be possible to call destroy_client() on a
clnt_info struct that's in this state. It's a little hard to tell with
the complicated way that the clnt_info lists are managed.

Regardless though, it's dangerous to keep invalid pointers around like
this. Later code changes may make it more likely for this problem to
occur.

Also eliminate some unneeded NULL pointer checks before freeing memory.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index fb97a13..509946e 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -182,9 +182,10 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 fail:
 	printerr(0, "ERROR: failed to read service info\n");
 	if (fd != -1) close(fd);
-	if (*servername) free(*servername);
-	if (*servicename) free(*servicename);
-	if (*protocol) free(*protocol);
+	free(*servername);
+	free(*servicename);
+	free(*protocol);
+	*servicename = *servername = *protocol = NULL;
 	return -1;
 }
 
@@ -200,10 +201,10 @@ destroy_client(struct clnt_info *clp)
 	if (clp->dir_fd != -1) close(clp->dir_fd);
 	if (clp->krb5_fd != -1) close(clp->krb5_fd);
 	if (clp->spkm3_fd != -1) close(clp->spkm3_fd);
-	if (clp->dirname) free(clp->dirname);
-	if (clp->servicename) free(clp->servicename);
-	if (clp->servername) free(clp->servername);
-	if (clp->protocol) free(clp->protocol);
+	free(clp->dirname);
+	free(clp->servicename);
+	free(clp->servername);
+	free(clp->protocol);
 	free(clp);
 }
 
-- 
1.6.0.6
