From: Harshula <harshula@sgi.com>
Subject: [PATCH] sunrpc: GSS integrity and decryption failures should
	return GARBAGE_ARGS
Date: Tue, 19 Feb 2008 20:19:41 +1100
Message-ID: <1203412781.10159.95.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:52374 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752093AbYBSJTr (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 04:19:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

In function svcauth_gss_accept() (net/sunrpc/auth_gss/svcauth_gss.c) the
code that handles GSS integrity and decryption failures should be
returning GARBAGE_ARGS as specified in RFC 2203. Is there a reason why
this is not the case? If not, here's a patch.

http://www.ietf.org/rfc/rfc2203.txt
----------------------------------------------------------
5.3.3.4.2.  GSS_VerifyMIC() Failure

   When GSS_VerifyMIC() is called to verify the verifier in request, a
   failure results in an RPC response with a reply status of MSG_DENIED,
   reject status of AUTH_ERROR and an auth status of
   RPCSEC_GSS_CREDPROBLEM.

   When GSS_VerifyMIC() is called to verify the call arguments (service
   is rpc_gss_svc_integrity), a failure results in an RPC response with
   a reply status of MSG_ACCEPTED, and an acceptance status of
   GARBAGE_ARGS.

5.3.3.4.3.  GSS_Unwrap() Failure

   When GSS_Unwrap() is called to decrypt the call arguments (service is
   rpc_gss_svc_privacy), a failure results in an RPC response with a
   reply status of MSG_ACCEPTED, and an acceptance status of
   GARBAGE_ARGS.
----------------------------------------------------------

This patch is against:
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: Harshula Jayasuriya <harshula@sgi.com>
---

 net/sunrpc/auth_gss/svcauth_gss.c |    9 +++++++--
 net/sunrpc/svc.c                  |    3 +--
 2 files changed, 8 insertions(+), 4 deletions(-)

--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1146,7 +1146,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32
*authp)
                case RPC_GSS_SVC_INTEGRITY:
                        if (unwrap_integ_data(&rqstp->rq_arg,
                                        gc->gc_seq, rsci->mechctx))
-                               goto auth_err;
+                               goto garbage_args;
                        /* placeholders for length and seq. number: */
                        svc_putnl(resv, 0);
                        svc_putnl(resv, 0);
@@ -1154,7 +1154,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32
*authp)
                case RPC_GSS_SVC_PRIVACY:
                        if (unwrap_priv_data(rqstp, &rqstp->rq_arg,
                                        gc->gc_seq, rsci->mechctx))
-                               goto auth_err;
+                               goto garbage_args;
                        /* placeholders for length and seq. number: */
                        svc_putnl(resv, 0);
                        svc_putnl(resv, 0);
@@ -1169,6 +1169,11 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32
*authp)
                ret = SVC_OK;
                goto out;
        }
+garbage_args:
+       /* Restore write pointer to its original value: */
+       xdr_ressize_check(rqstp, reject_stat);
+       ret = SVC_GARBAGE;
+       goto out;
 auth_err:
        /* Restore write pointer to its original value: */
        xdr_ressize_check(rqstp, reject_stat);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a290e15..a6c74fe 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -915,8 +915,7 @@ svc_process(struct svc_rqst *rqstp)
        case SVC_OK:
                break;
        case SVC_GARBAGE:
-               rpc_stat = rpc_garbage_args;
-               goto err_bad;
+               goto err_garbage;
        case SVC_SYSERR:
                rpc_stat = rpc_system_err;
                goto err_bad;

cya,
#

