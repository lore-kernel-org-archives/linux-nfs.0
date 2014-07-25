Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:58190 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760265AbaGYLey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:54 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so4864459qgf.35
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 9/9] nfsd: remove dl_fh field from struct nfs4_delegation
Date: Fri, 25 Jul 2014 07:34:27 -0400
Message-Id: <1406288067-20663-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the nfs4_file has a filehandle in it, we no longer need to
keep a per-delegation copy of it. Switch to using the one in the
nfs4_file instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 2 +-
 fs/nfsd/nfs4state.c    | 3 +--
 fs/nfsd/state.h        | 1 -
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c393d6ca3fce..e9813389687b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -337,7 +337,7 @@ static void encode_cb_recall4args(struct xdr_stream *xdr,
 	p = xdr_reserve_space(xdr, 4);
 	*p++ = xdr_zero;			/* truncate */
 
-	encode_nfs_fh4(xdr, &dp->dl_fh);
+	encode_nfs_fh4(xdr, &dp->dl_file->fi_fhandle);
 
 	hdr->nops++;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ecfddca9b841..b0f83beeca75 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -604,7 +604,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
-	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
 	return dp;
 out_dec:
@@ -3097,7 +3096,7 @@ void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	block_delegations(&dp->dl_fh);
+	block_delegations(&dp->dl_file->fi_fhandle);
 
 	/*
 	 * We can't do this in nfsd_break_deleg_cb because it is
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0097d4771521..39747736e83b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -96,7 +96,6 @@ struct nfs4_delegation {
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
-	struct knfsd_fh		dl_fh;
 	int			dl_retries;
 	struct nfsd4_callback	dl_recall;
 };
-- 
1.9.3

