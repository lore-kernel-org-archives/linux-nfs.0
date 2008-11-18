From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] showmount command: call nfs_getport instead of local
	getport
Date: Tue, 18 Nov 2008 14:29:35 -0500
Message-ID: <20081118192934.22516.68346.stgit@ingres.1015granger.net>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50881 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbYKRTbG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 14:31:06 -0500
In-Reply-To: <20081118192711.22516.2801.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 959229a..cbc8f1a 100644
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

