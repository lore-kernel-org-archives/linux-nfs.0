From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] sunrpc: parse and return errors reported by gssd
Date: Thu,  7 Jan 2010 09:42:02 -0500
Message-ID: <1262875325-4488-2-git-send-email-jlayton@redhat.com>
References: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel currently ignores any error code sent by gssd and always
considers it to be -EACCES. In order to better handle the situation of
an expired KRB5 TGT, the kernel needs to be able to parse and deal with
the errors that gssd sends. Aside from -EACCES the only error we care
about is -EKEYEXPIRED, which we're using to indicate that the upper
layers should retry the call a little later.

To maintain backward compatibility with older gssd's, any error other
than -EKEYEXPIRED is interpreted as -EACCES.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 66cb89c..11f2915 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -206,8 +206,14 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	ctx->gc_win = window_size;
 	/* gssd signals an error by passing ctx->gc_win = 0: */
 	if (ctx->gc_win == 0) {
-		/* in which case, p points to  an error code which we ignore */
-		p = ERR_PTR(-EACCES);
+		/*
+		 * in which case, p points to an error code. Anything other
+		 * than -EKEYEXPIRED gets converted to -EACCES.
+		 */
+		p = simple_get_bytes(p, end, &ret, sizeof(ret));
+		if (!IS_ERR(p))
+			p = (ret == -EKEYEXPIRED) ? ERR_PTR(-EKEYEXPIRED) :
+						    ERR_PTR(-EACCES);
 		goto err;
 	}
 	/* copy the opaque wire context */
@@ -646,6 +652,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		err = PTR_ERR(p);
 		switch (err) {
 		case -EACCES:
+		case -EKEYEXPIRED:
 			gss_msg->msg.errno = err;
 			err = mlen;
 			break;
-- 
1.6.5.2
