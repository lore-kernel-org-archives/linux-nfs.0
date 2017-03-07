Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33100 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbdCGJXP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 04:23:15 -0500
Received: by mail-it0-f68.google.com with SMTP id g138so4191356itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Mar 2017 01:22:56 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] SUNRPC/backchanel: set XPT_CONG_CTRL flag for bc xprt
Message-ID: <b321152e-cbe8-94b3-498c-1d32e7c7be2d@gmail.com>
Date: Tue, 7 Mar 2017 17:22:43 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xprt for backchannel is created separately, not in TCP/UDP code.
Because without the flags, the requests from NFSv41 backchannel are
rejected in svc_process_common(),

1191         if (versp->vs_need_cong_ctrl &&
1192             !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
1193                 goto err_bad_vers;

Fixes: 5283b03ee5 ("nfs/nfsd/sunrpc: enforce transport...")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/svcsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8931e33..2b720fa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1635,6 +1635,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 
 	xprt = &svsk->sk_xprt;
 	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
+	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 
 	serv->sv_bc_xprt = xprt;
 
-- 
2.9.3

