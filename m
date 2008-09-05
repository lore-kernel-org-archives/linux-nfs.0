From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/19] showmount: destroy RPC client when finished
Date: Fri, 05 Sep 2008 17:07:13 -0400
Message-ID: <20080905210712.10001.58319.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48279 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbYIEVMX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:12:23 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

