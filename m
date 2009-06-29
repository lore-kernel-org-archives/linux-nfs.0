From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/31] mount.nfs: Add more debugging output around
	nfs_getport()
Date: Mon, 29 Jun 2009 13:36:41 -0400
Message-ID: <20090629173641.2076.75316.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53665 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869AbZF2RhC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:02 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So we can see how rpcbind queries are failing during mount processing,
add some debugging messages (enabled with "mount.nfs -v") around the
nfs_getport() calls.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 3080378..9661995 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -509,6 +509,21 @@ static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
 			port);
 }
 
+static void nfs_pp_debug2(const char *str)
+{
+	if (!verbose)
+		return;
+
+	if (rpc_createerr.cf_error.re_status == RPC_CANTRECV ||
+	    rpc_createerr.cf_error.re_status == RPC_CANTSEND)
+		nfs_error(_("%s: portmap query %s%s - %s"),
+				progname, str, clnt_spcreateerror(""),
+				strerror(rpc_createerr.cf_error.re_errno));
+	else
+		nfs_error(_("%s: portmap query %s%s"),
+				progname, str, clnt_spcreateerror(""));
+}
+
 /*
  * Use the portmapper to discover whether or not the service we want is
  * available. The lists 'versions' and 'protos' define ordered sequences
@@ -540,6 +555,9 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 	p_vers = vers ? &vers : versions;
 
 	for (;;) {
+		if (verbose)
+			printf(_("%s: prog %lu, trying vers=%lu, prot=%u\n"),
+				progname, prog, *p_vers, *p_prot);
 		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
 		if (p_port) {
 			if (!port || port == p_port) {
@@ -555,22 +573,24 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 		    rpc_createerr.cf_stat != RPC_TIMEDOUT &&
 		    rpc_createerr.cf_stat != RPC_CANTRECV &&
 		    rpc_createerr.cf_stat != RPC_PROGVERSMISMATCH)
-			goto out_bad;
+			break;
 
 		if (!prot) {
-			if (*++p_prot)
+			if (*++p_prot) {
+				nfs_pp_debug2("retrying");
 				continue;
+			}
 			p_prot = protos;
 		}
 		if (rpc_createerr.cf_stat == RPC_TIMEDOUT ||
 		    rpc_createerr.cf_stat == RPC_CANTRECV)
-			goto out_bad;
+			break;
 
 		if (vers || !*++p_vers)
 			break;
 	}
 
-out_bad:
+	nfs_pp_debug2("failed");
 	return 0;
 
 out_ok:

