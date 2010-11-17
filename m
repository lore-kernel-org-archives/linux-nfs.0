Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48021 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756456Ab0KQVQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Nov 2010 16:16:15 -0500
From: andros@netapp.com
To: benny@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] SQUASHME: pnfs-submit: fix highest backchannel slot used
Date: Tue, 16 Nov 2010 22:36:29 -0500
Message-Id: <1289964990-4480-3-git-send-email-andros@netapp.com>
In-Reply-To: <1289964990-4480-2-git-send-email-andros@netapp.com>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
 <1289964990-4480-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Patch 9225185aa0cd29bf85dabca5978199a6b4a73ca6
"SQUASHME: pnfs-submit: highest backchannel slot used for !CONFIG_NFS_V4_1"
removed a check for the session existance.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a77877c..92719f1 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -791,7 +791,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	nfs4_callback_free_slot(cps.session);
+	if (cps.session)
+		nfs4_callback_free_slot(cps.session);
 	/* matched by cb_sequence find_client_with_session */
 	put_session_client(cps.session);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
-- 
1.6.6

