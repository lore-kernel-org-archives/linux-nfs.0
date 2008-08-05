From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] showmount command: call nfs_getport instead of local
	getport
Date: Tue, 05 Aug 2008 14:12:53 -0400
Message-ID: <20080805181252.23104.44695.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17710 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760477AbYHESNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:43 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m75IDfUf025638
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:41 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m75BQwPW014132
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:40 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ICri2023231
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:12:53 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have the showmount command invoke the shared nfs_getport() function
instead of its own local version.  This gives the showmount command
immediate support for querying via rpcbindv3/v4 in addition to
portmapper, and sets the stage for AF_INET6 support in showmount.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 6acd7e6..360f2fa 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -37,6 +37,8 @@
 #include <mount.h>
 #include <unistd.h>
 
+#include "nfsrpc.h"
+
 #define TIMEOUT_UDP	3
 #define TIMEOUT_TCP	10
 #define TOTAL_TIMEOUT	20
@@ -352,9 +354,9 @@ int main(int argc, char **argv)
 	mclient = NULL;
 	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
 	if (msock != -1) {
-		server_addr.sin_port = getport(&server_addr,
-					 MOUNTPROG, MOUNTVERS, IPPROTO_TCP);
-		if (server_addr.sin_port) {
+		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+					sizeof(server_addr), MOUNTPROG,
+					MOUNTVERS, IPPROTO_TCP)) {
 			ret = connect_nb(msock, &server_addr, 0);
 			if (ret == 0) /* success */
 				mclient = clnttcp_create(&server_addr,
@@ -367,9 +369,9 @@ int main(int argc, char **argv)
 	}
 
 	if (!mclient) {
-		server_addr.sin_port = getport(&server_addr,
-					 MOUNTPROG, MOUNTVERS, IPPROTO_UDP);
-		if (!server_addr.sin_port) {
+		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+					sizeof(server_addr), MOUNTPROG,
+					MOUNTVERS, IPPROTO_UDP)) {
 			clnt_pcreateerror("showmount");
 			exit(1);
 		}

