Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Subject: [PATCH] sunrpc: on successful gss error pipe write,
	don't return error (try #3)
Date: Fri, 18 Dec 2009 16:23:50 -0500
Message-Id: <1261171430-15075-1-git-send-email-jlayton@redhat.com>
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
bytes written to the pipe instead of an error. In the event of other
errors, we generally want the initiating task to retry the upcall so
we set msg.errno to -EAGAIN. An unexpected error code here is a bug
however, so BUG() in that case.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3c3c50f..66cb89c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -644,7 +644,22 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
 	if (IS_ERR(p)) {
 		err = PTR_ERR(p);
-		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
+		switch (err) {
+		case -EACCES:
+			gss_msg->msg.errno = err;
+			err = mlen;
+			break;
+		case -EFAULT:
+		case -ENOMEM:
+		case -EINVAL:
+		case -ENOSYS:
+			gss_msg->msg.errno = -EAGAIN;
+			break;
+		default:
+			printk(KERN_CRIT "%s: bad return from "
+				"gss_fill_context: %ld\n", __func__, err);
+			BUG();
+		}
 		goto err_release_msg;
 	}
 	gss_msg->ctx = gss_get_ctx(ctx);
-- 
1.6.5.2

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
