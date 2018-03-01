Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:41750 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1032798AbeCARGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Mar 2018 12:06:32 -0500
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)
Date: Thu,  1 Mar 2018 12:06:29 -0500
Message-Id: <20180301170629.20780-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1337142
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_dg.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/src/clnt_dg.c b/src/clnt_dg.c
index 248138b..884a2db 100644
--- a/src/clnt_dg.c
+++ b/src/clnt_dg.c
@@ -433,6 +433,11 @@ get_reply:
 	  char *cbuf = (char *) alloca (outlen + 256);
 	  int ret;
 
+	  if (cbuf == NULL) 
+	  {
+	  	cu->cu_error.re_errno = errno;
+		return (cu->cu_error.re_status = RPC_CANTRECV);
+	  }
 	  iov.iov_base = cbuf + 256;
 	  iov.iov_len = outlen;
 	  msg.msg_name = (void *) &err_addr;
@@ -457,11 +462,13 @@ get_reply:
 		 cmsg = CMSG_NXTHDR (&msg, cmsg))
 	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
 		{
+		  free(cbuf);
 		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
 		  cu->cu_error.re_errno = e->ee_errno;
 		  release_fd_lock(cu->cu_fd, mask);
 		  return (cu->cu_error.re_status = RPC_CANTRECV);
 		}
+	  free(cbuf);
 	}
 #endif
 
-- 
2.14.3

