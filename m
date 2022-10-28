Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C5DFECAAA1
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Oct 2022 14:48:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230518AbiJ1Os1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 28 Oct 2022 10:48:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41750 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231199AbiJ1OsK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2022 10:48:10 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A346F204AD2
        for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2022 07:47:05 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 3E21A628CF
        for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2022 14:47:05 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7A5C1C433D6;
        Fri, 28 Oct 2022 14:47:04 +0000 (UTC)
Subject: [PATCH v7 05/14] NFSD: Trace stateids returned via DELEGRETURN
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     neilb@suse.de, jlayton@redhat.com
Date:   Fri, 28 Oct 2022 10:47:03 -0400
Message-ID: <166696842358.106044.5702462087113424436.stgit@klimt.1015granger.net>
In-Reply-To: <166696812922.106044.679812521105874329.stgit@klimt.1015granger.net>
References: <166696812922.106044.679812521105874329.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev3+g9561319
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Handing out a delegation stateid is recorded with the
nfsd_deleg_read tracepoint, but there isn't a matching tracepoint
for recording when the stateid is returned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c |    1 +
 fs/nfsd/trace.h     |    1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c829b828b6fd..93cfae7cd391 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6901,6 +6901,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto put_stateid;
 
+	trace_nfsd_deleg_return(stateid);
 	wake_up_var(d_inode(cstate->current_fh.fh_dentry));
 	destroy_delegation(dp);
 put_stateid:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index b065a4b1e0dc..477c2b035872 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -601,6 +601,7 @@ DEFINE_STATEID_EVENT(layout_recall_release);
 
 DEFINE_STATEID_EVENT(open);
 DEFINE_STATEID_EVENT(deleg_read);
+DEFINE_STATEID_EVENT(deleg_return);
 DEFINE_STATEID_EVENT(deleg_recall);
 
 DECLARE_EVENT_CLASS(nfsd_stateseqid_class,


