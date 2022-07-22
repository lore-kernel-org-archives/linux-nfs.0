Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC517C43334
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jul 2022 20:19:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236775AbiGVUT0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Jul 2022 16:19:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46320 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236531AbiGVUTZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2022 16:19:25 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 206157F50A
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 13:19:25 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id BD1E0B82A1E
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 20:19:23 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 65B85C341C6
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 20:19:22 +0000 (UTC)
Subject: [PATCH v1 04/11] NFSD: Make nfs4_put_copy() static
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 22 Jul 2022 16:19:21 -0400
Message-ID: <165852116144.11403.3030902360061796137.stgit@manet.1015granger.net>
In-Reply-To: <165852076926.11403.44005570813790008.stgit@manet.1015granger.net>
References: <165852076926.11403.44005570813790008.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

All call sites are in fs/nfsd/nfs4proc.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/state.h    |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0bcfb9afca03..7e41f40829c4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1285,7 +1285,7 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-void nfs4_put_copy(struct nfsd4_copy *copy)
+static void nfs4_put_copy(struct nfsd4_copy *copy)
 {
 	if (!refcount_dec_and_test(&copy->refcount))
 		return;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f3d6313914ed..ae596dbf8667 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -703,7 +703,6 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name
 extern bool nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn);
 
 void put_nfs4_file(struct nfs4_file *fi);
-extern void nfs4_put_copy(struct nfsd4_copy *copy);
 extern struct nfsd4_copy *
 find_async_copy(struct nfs4_client *clp, stateid_t *staetid);
 extern void nfs4_put_cpntf_state(struct nfsd_net *nn,


