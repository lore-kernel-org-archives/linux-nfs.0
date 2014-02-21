Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f42.google.com ([209.85.219.42]:48891 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbaBUSKg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Feb 2014 13:10:36 -0500
Received: by mail-oa0-f42.google.com with SMTP id j17so2547991oag.15
        for <linux-nfs@vger.kernel.org>; Fri, 21 Feb 2014 10:10:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSd: NFSv4.1 OPEN must use the session-derived client id
Date: Fri, 21 Feb 2014 13:10:33 -0500
Message-Id: <1393006233-15366-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 states:

 The client can set the clientid field to any value and the server MUST
 ignore it.  Instead, the server MUST derive the client ID from the
 session ID of the SEQUENCE operation of the COMPOUND request

Make it so...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 693e1458e2ca..d23f4cdbc891 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2826,6 +2826,21 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
 	return nfserr_bad_seqid;
 }
 
+/*
+ * RFC5661: OPEN MUST ignore the client-supplied clientid argument and
+ * substitute the session clientid
+ */
+static void nfsd41_set_open_clientid(struct nfsd4_compound_state *cstate,
+		struct nfsd4_open *open)
+{
+	struct nfs4_client *clp;
+
+	if (!nfsd4_has_session(cstate))
+		return;
+	clp = cstate->session->se_client;
+	memcpy(&open->op_clientid, &clp->cl_clientid, sizeof(open->op_clientid));
+}
+
 __be32
 nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		    struct nfsd4_open *open, struct nfsd_net *nn)
@@ -2836,6 +2851,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *oo = NULL;
 	__be32 status;
 
+	nfsd41_set_open_clientid(cstate, open);
+
 	if (STALE_CLIENTID(&open->op_clientid, nn))
 		return nfserr_stale_clientid;
 	/*
-- 
1.8.5.3

