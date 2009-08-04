From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] svcgss: reply AUTH_BADCRED to RPCSEC_GSS with unkown services
Date: Tue, 04 Aug 2009 17:27:52 +0800
Message-ID: <4A77FF18.4040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52940 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755287AbZHDJ34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 05:29:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When RPC messages is received with RPCSEC_GSS, and if the RPCSEC_GSS
include unkown services (not RPC_GSS_SVC_NONE, RPC_GSS_SVC_INTEGRITY
and RPC_GSS_SVC_PRIVACY), the response is considered as AUTH_BADCRED
in svcauth_gss_accept(), but the response be drop by
svcauth_gss_release(). I think response with AUTH_BADCRED is correct
one. So this patch fixed it.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
  static int
  svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
  {
         switch (gc->gc_svc) {
         case RPC_GSS_SVC_NONE:
         ...
         case RPC_GSS_SVC_INTEGRITY:
         ...
         case RPC_GSS_SVC_PRIVACY:
         ...
         default:
                 goto auth_err; <-- reply with AUTH_BADCRED
         }
   ...
   }

  static int
  svcauth_gss_release(struct svc_rqst *rqstp)
  {
      ...
      switch (gc->gc_svc) {
      case RPC_GSS_SVC_NONE:
              break;
      case RPC_GSS_SVC_INTEGRITY:
      ...
      case RPC_GSS_SVC_PRIVACY:
      ...
      default:
             goto out_err; <--- will drop it
      }
      ...
  }
---
 net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 2278a50..6dce327 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1370,7 +1370,7 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 			goto out_err;
 		break;
 	default:
-		goto out_err;
+		goto out;
 	}
 
 out:
-- 
1.6.2.2




