From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/4] gssd: read port number from info file if supplied
Date: Thu, 01 May 2008 09:35:00 -0400
Message-ID: <20080501133500.28884.44044.stgit@jazz.citi.umich.edu>
References: <20080501133455.28884.4768.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:26856 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbYEANfB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 09:35:01 -0400
In-Reply-To: <20080501133455.28884.4768.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Check the info file information to see if a port number is supplied.
If so, use it rather than the standard port number.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd_proc.c |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index e17edde..6f14c34 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -80,6 +80,7 @@ struct clnt_info {
 	int			krb5_poll_index;
 	int			spkm3_fd;
 	int			spkm3_poll_index;
+	int			port;
 };
 
 void init_client_list(void);
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 6860cc8..bac7295 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -102,7 +102,7 @@ int pollsize;  /* the size of pollaray (in pollfd's) */
 /* XXX buffer problems: */
 static int
 read_service_info(char *info_file_name, char **servicename, char **servername,
-		  int *prog, int *vers, char **protocol) {
+		  int *prog, int *vers, char **protocol, int *port) {
 #define INFOBUFLEN 256
 	char		buf[INFOBUFLEN];
 	static char	dummy[128];
@@ -112,6 +112,8 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	char		program[16];
 	char		version[16];
 	char		protoname[16];
+	char		cb_port[128];
+	char		*p;
 	in_addr_t	inaddr;
 	int		fd = -1;
 	struct hostent	*ent = NULL;
@@ -143,6 +145,10 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		goto fail;
 	}
 
+	cb_port[0] = '\0';
+	if ((p = strstr(buf, "port")) != NULL)
+		sscanf(p, "port: %127s\n", cb_port);
+
 	/* check service, program, and version */
 	if(memcmp(service, "nfs", 3)) return -1;
 	*prog = atoi(program + 1); /* skip open paren */
@@ -163,6 +169,8 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
 		goto fail;
 	memcpy(*servicename, buf, strlen(buf));
+	if (cb_port[0] != '\0')
+		*port = atoi(cb_port);
 
 	if (!(*protocol = strdup(protoname)))
 		goto fail;
@@ -238,7 +246,7 @@ process_clnt_dir_files(struct clnt_info * clp)
 	if ((clp->servicename == NULL) &&
 	     read_service_info(info_file_name, &clp->servicename,
 				&clp->servername, &clp->prog, &clp->vers,
-				&clp->protocol))
+				&clp->protocol, &clp->port))
 		return -1;
 	return 0;
 }
@@ -587,6 +595,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
 			 clp->servername, uid);
 		goto out_fail;
 	}
+	if (clp->port)
+		((struct sockaddr_in *)a->ai_addr)->sin_port = htons(clp->port);
 	if (a->ai_protocol == IPPROTO_TCP) {
 		if ((rpc_clnt = clnttcp_create(
 					(struct sockaddr_in *) a->ai_addr,

