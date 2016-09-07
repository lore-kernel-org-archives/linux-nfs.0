Return-Path: <chucklever@gmail.com>
Sender: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH v1] svcauth_gss: Close connection when dropping an incoming
 message
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: bcodding@redhat.com, linux-nfs@vger.kernel.org
Date: Wed, 07 Sep 2016 16:36:19 -0400
Message-ID: <20160907202552.15084.40866.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

S5.3.3.1 of RFC 2203 requires that an incoming GSS-wrapped message
whose sequence number lies outside the current window is dropped.
The rationale is:

  The reason for discarding requests silently is that the server
  is unable to determine if the duplicate or out of range request
  was due to a sequencing problem in the client, network, or the
  operating system, or due to some quirk in routing, or a replay
  attack by an intruder.  Discarding the request allows the client
  to recover after timing out, if indeed the duplication was
  unintentional or well intended.

However, clients may rely on the server dropping the connection to
indicate that a retransmit is needed. Without a connection reset, a
client can wait forever without retransmitting, and the workload
just stops dead. I've reproduced this behavior by running xfstests
generic/323 on an NFSv4.0 mount with proto=rdma and sec=krb5i.

To address this issue, have the server close the connection when it
silently discards an incoming message due to a GSS sequence number
problem.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
---
Hi-

Passed testing with my reproducer: 10 runs of generic/323 with
proto=rdma and sec=krb5i, with NFSv3, NFSv4.0, and NFSv4.1.
generic/323 is 120 seconds or so of a heavy aio workload.

I tested with that dprintk replaced with pr_warn to confirm that the
reproducer hits this path one or more times per test run.

 net/sunrpc/auth_gss/svcauth_gss.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d858202..3ff52ec 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -696,7 +696,8 @@ gss_verify_header(struct svc_rqst *rqstp, struct rsc *rsci,
 	if (!gss_check_seq_num(rsci, gc->gc_seq)) {
 		dprintk("RPC:       svcauth_gss: discarding request with "
 				"old sequence number %d\n", gc->gc_seq);
-		return SVC_DROP;
+		/* Signal to the client that an RPC message was lost */
+		return SVC_CLOSE;
 	}
 	return SVC_OK;
 }
