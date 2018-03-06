Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:41118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753914AbeCFSDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Mar 2018 13:03:25 -0500
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] clnt_dg_call: Change the memory allocation
Date: Tue,  6 Mar 2018 13:03:23 -0500
Message-Id: <20180306180323.12131-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the memory allocation from the stack
to the heap by calling calloc() verses alloca

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1552163
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_dg.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/src/clnt_dg.c b/src/clnt_dg.c
index 884a2db..1d55b1e 100644
--- a/src/clnt_dg.c
+++ b/src/clnt_dg.c
@@ -430,7 +430,7 @@ get_reply:
 	  struct sockaddr_in err_addr;
 	  struct sockaddr_in *sin = (struct sockaddr_in *)&cu->cu_raddr;
 	  struct iovec iov;
-	  char *cbuf = (char *) alloca (outlen + 256);
+	  char *cbuf = (char *) mem_alloc(outlen + 256);
 	  int ret;
 
 	  if (cbuf == NULL) 
@@ -462,13 +462,13 @@ get_reply:
 		 cmsg = CMSG_NXTHDR (&msg, cmsg))
 	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
 		{
-		  free(cbuf);
+		  mem_free(cbuf, (outlen + 256));
 		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
 		  cu->cu_error.re_errno = e->ee_errno;
 		  release_fd_lock(cu->cu_fd, mask);
 		  return (cu->cu_error.re_status = RPC_CANTRECV);
 		}
-	  free(cbuf);
+	  mem_free(cbuf, (outlen + 256));
 	}
 #endif
 
-- 
2.14.3

