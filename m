From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] showmount: destroy RPC client when finished
Date: Tue, 05 Aug 2008 14:12:42 -0400
Message-ID: <20080805181241.23104.72863.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:13266 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760510AbYHESNp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:45 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m75IDhwi032717
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 13:13:43 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m758eGo5021272
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:40 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ICg1e023203
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:12:42 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: call clnt_destroy() in the showmount command as needed to
destroy the RPC client properly (and close the associated socket) before
the program exits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 213a573..b6cea92 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -393,6 +393,7 @@ int main(int argc, char **argv)
 			total_timeout);
 		if (clnt_stat != RPC_SUCCESS) {
 			clnt_perror(mclient, "rpc mount export");
+			clnt_destroy(mclient);
 			exit(1);
 		}
 		if (headers)
@@ -416,6 +417,7 @@ int main(int argc, char **argv)
 			printf("\n");
 			exportlist = exportlist->ex_next;
 		}
+		clnt_destroy(mclient);
 		exit(0);
 	}
 
@@ -426,8 +428,10 @@ int main(int argc, char **argv)
 		total_timeout);
 	if (clnt_stat != RPC_SUCCESS) {
 		clnt_perror(mclient, "rpc mount dump");
+		clnt_destroy(mclient);
 		exit(1);
 	}
+	clnt_destroy(mclient);
 
 	n = 0;
 	for (list = dumplist; list; list = list->ml_next)
@@ -481,4 +485,3 @@ int main(int argc, char **argv)
 	}
 	exit(0);
 }
-

