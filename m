Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Subject: [PATCH] sunrpc: on successful gss error pipe write,
	don't return error (try #2)
Date: Fri, 18 Dec 2009 11:27:17 -0500
Message-Id: <1261153637-6209-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

When handling the gssd downcall, the kernel should distinguish between a
successful downcall that contains an error code and a failed downcall
(i.e. where the parsing failed or some other sort of problem occurred).

In the former case, gss_pipe_downcall should be returning the number of
bytes written to the pipe instead of an error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3c3c50f..7afc8e2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -645,6 +645,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (IS_ERR(p)) {
 		err = PTR_ERR(p);
 		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
+		/* special case: downcall was successful, but held an error */
+		if (err == -EACCES)
+			err = mlen;
 		goto err_release_msg;
 	}
 	gss_msg->ctx = gss_get_ctx(ctx);
-- 
1.6.5.2

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
