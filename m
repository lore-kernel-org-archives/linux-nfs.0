Return-Path: <SRS0=qOnK=7W=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5F2C433E0
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jun 2020 23:23:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 91F3B2067B
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jun 2020 23:23:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725948AbgFIXXC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jun 2020 19:23:02 -0400
Received: from youngberry.canonical.com ([91.189.89.112]:38214 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725468AbgFIXXB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2020 19:23:01 -0400
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
        by youngberry.canonical.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.86_2)
        (envelope-from <colin.king@canonical.com>)
        id 1jina5-0005EV-L6; Tue, 09 Jun 2020 23:22:57 +0000
From:   Colin King <colin.king@canonical.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Cc:     kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: remove redundant pointer clnt
Date:   Wed, 10 Jun 2020 00:22:57 +0100
Message-Id: <20200609232257.1118354-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.27.0.rc0
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The pointer clnt is being initialized with a value that is never
read and so this is assignment redundant and can be removed. The
pointer can removed because it is being used as a temporary
variable and it is clearer to make the direct assignment and remove
it completely.

Addresses-Coverity: ("Unused value")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfs/nfs4proc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e32717fd1169..7a56e2ab473b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9518,7 +9518,6 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	struct rpc_clnt *clnt = server->client;
 	struct nfs4_call_sync_data data = {
 		.seq_server = server,
 		.seq_args = &args.seq_args,
@@ -9535,8 +9534,7 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 	int status;
 
 	if (use_integrity) {
-		clnt = server->nfs_client->cl_rpcclient;
-		task_setup.rpc_client = clnt;
+		task_setup.rpc_client = server->nfs_client->cl_rpcclient;
 
 		cred = nfs4_get_clid_cred(server->nfs_client);
 		msg.rpc_cred = cred;
-- 
2.27.0.rc0

