Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36933 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab2BPSAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:00:21 -0500
Received: by eekc14 with SMTP id c14so979061eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:00:20 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: nfsd41: add missing break when encoding op_why_no_deleg
Date: Thu, 16 Feb 2012 20:00:15 +0200
Message-Id: <1329415215-20220-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---

Note: This patch applies only to my tree at
git://linux-nfs.org/~bhalevy/linux-pnfs.git
as the relevant code is not submitted upstream yet

 fs/nfsd/nfs4xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 54a4c5e..7b08846 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3051,6 +3051,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 			RESERVE_SPACE(8);
 			WRITE32(open->op_why_no_deleg);
 			WRITE32(0);	/* deleg signaling not supported yet */
+			break;
 		default:
 			RESERVE_SPACE(4);
 			WRITE32(open->op_why_no_deleg);
-- 
1.7.6.5

