Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Subject: [PATCH] gssd: clean up function args for read_service_info
Date: Fri, 18 Dec 2009 09:24:51 -0500
Message-Id: <1261146291-2561-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

All of the parameters are pointers to fields in a clnt_info struct. Just
pass a pointer to the struct instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   43 ++++++++++++++++++++-----------------------
 1 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 795e06c..2649236 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -202,9 +202,8 @@ sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
 
 /* XXX buffer problems: */
 static int
-read_service_info(char *info_file_name, char **servicename, char **servername,
-		  int *prog, int *vers, char **protocol,
-		  struct sockaddr *addr) {
+read_service_info(char *info_file_name, struct clnt_info *clp)
+{
 #define INFOBUFLEN 256
 	char		buf[INFOBUFLEN + 1];
 	static char	dummy[128];
@@ -218,8 +217,9 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	char		*p;
 	int		fd = -1;
 	int		numfields;
+	struct sockaddr *addr = (struct sockaddr *) &clp->addr;
 
-	*servicename = *servername = *protocol = NULL;
+	clp->servicename = clp->servername = clp->protocol = NULL;
 
 	if ((fd = open(info_file_name, O_RDONLY)) == -1) {
 		printerr(0, "ERROR: can't open %s: %s\n", info_file_name,
@@ -253,43 +253,43 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	/* check service, program, and version */
 	if (memcmp(service, "nfs", 3) != 0)
 		return -1;
-	*prog = atoi(program + 1); /* skip open paren */
-	*vers = atoi(version);
+	clp->prog = atoi(program + 1); /* skip open paren */
+	clp->vers = atoi(version);
 
 	if (strlen(service) == 3 ) {
-		if ((*prog != 100003) || ((*vers != 2) && (*vers != 3) &&
-		    (*vers != 4)))
+		if ((clp->prog != 100003) || ((clp->vers != 2) && (clp->vers != 3) &&
+		    (clp->vers != 4)))
 			goto fail;
 	} else if (memcmp(service, "nfs4_cb", 7) == 0) {
-		if (*vers != 1)
+		if (clp->vers != 1)
 			goto fail;
 	}
 
 	if (!addrstr_to_sockaddr(addr, address, port))
 		goto fail;
 
-	*servername = sockaddr_to_hostname(addr, address);
-	if (*servername == NULL)
+	clp->servername = sockaddr_to_hostname(addr, address);
+	if (clp->servername == NULL)
 		goto fail;
 
-	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
+	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, clp->servername);
 	if (nbytes > INFOBUFLEN)
 		goto fail;
 
-	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
+	if (!(clp->servicename = calloc(strlen(buf) + 1, 1)))
 		goto fail;
-	memcpy(*servicename, buf, strlen(buf));
+	memcpy(clp->servicename, buf, strlen(buf));
 
-	if (!(*protocol = strdup(protoname)))
+	if (!(clp->protocol = strdup(protoname)))
 		goto fail;
 	return 0;
 fail:
 	printerr(0, "ERROR: failed to read service info\n");
 	if (fd != -1) close(fd);
-	free(*servername);
-	free(*servicename);
-	free(*protocol);
-	*servicename = *servername = *protocol = NULL;
+	free(clp->servername);
+	free(clp->servicename);
+	free(clp->protocol);
+	clp->servicename = clp->servername = clp->protocol = NULL;
 	return -1;
 }
 
@@ -382,10 +382,7 @@ process_clnt_dir_files(struct clnt_info * clp)
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
-	if ((clp->servicename == NULL) &&
-	     read_service_info(info_file_name, &clp->servicename,
-				&clp->servername, &clp->prog, &clp->vers,
-				&clp->protocol, (struct sockaddr *) &clp->addr))
+	if (!clp->servicename && read_service_info(info_file_name, clp))
 		return -1;
 	return 0;
 }
-- 
1.6.5.2

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
