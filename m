From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] SUNRPC: NFS kernel APIs shouldn't return ENOENT for
	"transport not found"
Date: Tue, 26 Jan 2010 14:04:13 -0500
Message-ID: <20100126190413.3368.99286.stgit@localhost.localdomain>
References: <20100126190214.3368.89388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:20573 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928Ab0AZTE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 14:04:28 -0500
In-Reply-To: <20100126190214.3368.89388.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

write_ports() converts svc_create_xprt()'s ENOENT error return to
EPROTONOSUPPORT so that rpc.nfsd (in user space) can report an error
message that makes sense.

It turns out that several of the other kernel APIs rpc.nfsd use can
also return ENOENT from svc_create_xprt(), by way of lockd_up().

On the client side, an NFSv2 or NFSv3 mount request can also return
the result of lockd_up().  This error may also be returned during an
NFSv4 mount request, since the NFSv4 callback service uses
svc_create_xprt() to create the callback listener.  An ENOENT error
return results in a confusing error message from the mount command.

Let's have svc_create_xprt() return EPROTONOSUPPORT instead of ENOENT.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c      |    6 +-----
 net/sunrpc/svc_xprt.c |    5 ++++-
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2604c3e..f43ecd6 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1002,12 +1002,8 @@ static ssize_t __write_ports_addxprt(char *buf)
 
 	err = svc_create_xprt(nfsd_serv, transport,
 				PF_INET, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0) {
-		/* Give a reasonable perror msg for bad transport string */
-		if (err == -ENOENT)
-			err = -EPROTONOSUPPORT;
+	if (err < 0)
 		return err;
-	}
 	return 0;
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f886ff3..d7ec5ca 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -235,7 +235,10 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
  err:
 	spin_unlock(&svc_xprt_class_lock);
 	dprintk("svc: transport %s not found\n", xprt_name);
-	return -ENOENT;
+
+	/* This errno is exposed to user space.  Provide a reasonable
+	 * perror msg for a bad transport. */
+	return -EPROTONOSUPPORT;
 }
 EXPORT_SYMBOL_GPL(svc_create_xprt);
 

