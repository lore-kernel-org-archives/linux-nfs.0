From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] showmount: Use CLNT_CONTROL for version fallback
Date: Thu, 07 Jan 2010 11:26:30 -0500
Message-ID: <20100107162630.27102.9464.stgit@localhost.localdomain>
References: <20100107162421.27102.21422.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:61873 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab0AGQ2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 11:28:25 -0500
In-Reply-To: <20100107162421.27102.21422.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When retrying MNT requests with lower RPC protocol versions, the
showmount command leaves several TCP sockets in TIME_WAIT:  at least
one socket for each rpcbind GETPORT call, and one for each attempted
MNT request.  Note that TIME_WAIT sockets may not be a problem on
an individual client, but this does tie up potentially valuable
network resources on the server for up to 120 seconds.

To reduce the resources required when retrying, downshift the RPC
protocol version of the existing RPC client using CLNT_CONTROL(),
rather than creating a new RPC client for each RPC protocol version.

Without this patch, "showmount -e" targeting a TCP-capable server with
a single export takes 64 packets and leaves 6 sockets in TIME_WAIT if
the server supports only MNTv1.  With it, showmount takes 29 packets
and leaves two TIME_WAIT sockets.

Newer versions of libtirpc will reduce that by one more socket (on
IPv4), and a handful of packets.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 652aa85..343f94b 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -193,12 +193,12 @@ int main(int argc, char **argv)
 		break;
 	}
 
-again:
 	mclient = nfs_get_mount_client(hostname, mount_vers_tbl[vers]);
 	mclient->cl_auth = authunix_create_default();
 	total_timeout.tv_sec = TOTAL_TIMEOUT;
 	total_timeout.tv_usec = 0;
 
+again:
 	if (eflag) {
 		memset(&exportlist, '\0', sizeof(exportlist));
 
@@ -207,8 +207,11 @@ again:
 			(xdrproc_t) xdr_exports, (caddr_t) &exportlist,
 			total_timeout);
 		if (clnt_stat == RPC_PROGVERSMISMATCH) {
-			if (++vers <  max_vers_tblsz)
+			if (++vers < max_vers_tblsz) {
+				(void)CLNT_CONTROL(mclient, CLSET_VERS,
+						(void *)&mount_vers_tbl[vers]);
 				goto again;
+			}
 		}
 		if (clnt_stat != RPC_SUCCESS) {
 			clnt_perror(mclient, "rpc mount export");
@@ -246,8 +249,11 @@ again:
 		(xdrproc_t) xdr_mountlist, (caddr_t) &dumplist,
 		total_timeout);
 	if (clnt_stat == RPC_PROGVERSMISMATCH) {
-		if (++vers <  max_vers_tblsz)
+		if (++vers < max_vers_tblsz) {
+			(void)CLNT_CONTROL(mclient, CLSET_VERS,
+					(void *)&mount_vers_tbl[vers]);
 			goto again;
+		}
 	}
 	if (clnt_stat != RPC_SUCCESS) {
 		clnt_perror(mclient, "rpc mount dump");

