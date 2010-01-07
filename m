From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] showmount: try v3 before falling back to v1
Date: Thu, 07 Jan 2010 11:37:54 -0500
Message-ID: <4B460DE2.8060700@RedHat.com>
References: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Dan McGee <dpmcgee@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096Ab0AGRLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 12:11:48 -0500
In-Reply-To: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Addressed the not freeing of the client handle when the RPC_PROGVERSMISMATCH
error occurs. Also discovered there no hang when the server does not 
support TCP connections due to the fact the clnt_create() quires the
server on what transports are supported... 

steved.


Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jan 7 11:30:03 2010 -0500

    showmount: Try the highest mount version then fall back to lower ones
    
    Showmount should try the highest mount version first then fall
    back to the lower ones when the server returns a RPC_PROGVERSMISMATCH
    error. The idea being not using the lower mount versions will begin
    the process of moving away from NFSv2 support.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 418e8b9..80fd47a 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -78,29 +78,36 @@ static void usage(FILE *fp, int n)
 	exit(n);
 }
 
-static const char *nfs_sm_pgmtbl[] = {
+static const char *mount_pgm_tbl[] = {
 	"showmount",
 	"mount",
 	"mountd",
 	NULL,
 };
 
+static const rpcvers_t mount_vers_tbl[] = {
+	MOUNTVERS_NFSV3,
+	MOUNTVERS_POSIX,
+	MOUNTVERS,
+};
+static const int max_vers_tblsz = 
+	(sizeof(mount_vers_tbl)/sizeof(mount_vers_tbl[0]));
+
 /*
  * Generate an RPC client handle connected to the mountd service
  * at @hostname, or die trying.
  *
  * Supports both AF_INET and AF_INET6 server addresses.
  */
-static CLIENT *nfs_get_mount_client(const char *hostname)
+static CLIENT *nfs_get_mount_client(const char *hostname, rpcvers_t vers)
 {
-	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
+	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, mount_pgm_tbl);
 	CLIENT *client;
 
-	client = clnt_create(hostname, program, MOUNTVERS, "tcp");
+	client = clnt_create(hostname, program, vers, "tcp");
 	if (client)
 		return client;
-
-	client = clnt_create(hostname, program, MOUNTVERS, "udp");
+	client = clnt_create(hostname, program, vers, "udp");
 	if (client)
 		return client;
 
@@ -123,6 +130,7 @@ int main(int argc, char **argv)
 	int i;
 	int n;
 	int maxlen;
+	int unsigned vers=0;
 	char **dumpv;
 
 	program_name = argv[0];
@@ -185,7 +193,8 @@ int main(int argc, char **argv)
 		break;
 	}
 
-	mclient = nfs_get_mount_client(hostname);
+again:
+	mclient = nfs_get_mount_client(hostname, mount_vers_tbl[vers]);
 	mclient->cl_auth = authunix_create_default();
 	total_timeout.tv_sec = TOTAL_TIMEOUT;
 	total_timeout.tv_usec = 0;
@@ -197,6 +206,12 @@ int main(int argc, char **argv)
 			(xdrproc_t) xdr_void, NULL,
 			(xdrproc_t) xdr_exports, (caddr_t) &exportlist,
 			total_timeout);
+		if (clnt_stat == RPC_PROGVERSMISMATCH) {
+			if (++vers <  max_vers_tblsz) {
+				clnt_destroy(mclient);
+				goto again;
+			}
+		}
 		if (clnt_stat != RPC_SUCCESS) {
 			clnt_perror(mclient, "rpc mount export");
 			clnt_destroy(mclient);
@@ -232,6 +247,12 @@ int main(int argc, char **argv)
 		(xdrproc_t) xdr_void, NULL,
 		(xdrproc_t) xdr_mountlist, (caddr_t) &dumplist,
 		total_timeout);
+	if (clnt_stat == RPC_PROGVERSMISMATCH) {
+		if (++vers <  max_vers_tblsz) {
+			clnt_destroy(mclient);
+			goto again;
+		}
+	}
 	if (clnt_stat != RPC_SUCCESS) {
 		clnt_perror(mclient, "rpc mount dump");
 		clnt_destroy(mclient);

