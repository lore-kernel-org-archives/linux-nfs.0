Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66294C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2D0682082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q3zK/pkw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D0682082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726748AbeLAHO3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:29 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:35483 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHO3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:29 -0500
Received: by mail-oi1-f194.google.com with SMTP id v6so5787844oif.2;
        Fri, 30 Nov 2018 12:04:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=6zt/YWGQAQJzm1pGDaEw7wvtmJ5ZI+B3uWmI29UKanI=;
        b=Q3zK/pkwves+5bncZW1fHbihRhBOIextwKpOtvMJFNK603y1TWWNls9pJfOwHKeFH7
         c44nVR0n6/0lgGZxs96brWsMZtEkgOE5nxp2A+ZV4egPXqUyMgSwVsSXgJoe5uBxBKFz
         rma5qpLGNpmEV0isBxIxRwAIw0Ayv4XhiPGTE1kAgqsoSeFaUv9wLkGxdax/PfTeZ8sx
         jiiTOOZgxmvF9qHGJu1XR7ov003YLREQTpXIQFSzo3JFihO1bv+v7O7DdEt3a6PTM9PB
         ZcvsWYl1hpkv1ljOZQ5hFZGx0HEqci+nN/2hu5vFADwt2eX2hXHRHTM8C8+HDE6tYonC
         dVvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=6zt/YWGQAQJzm1pGDaEw7wvtmJ5ZI+B3uWmI29UKanI=;
        b=pT3r6RGwK4+J6zT325A+xwCE/PTiwKsH4XiqrCpsRuQJfZTJDTO56WGBpe/z/LrDEF
         tH/CDjqtXEqaQnRMV5njOkMBh8FjhOJK45603YJagXHwukBjFcMOhC2Hz8Vg0a9YON8e
         g+BqjQN2xYZeGIulaQR3Xwczff0IM4PpgSq9G86+DkRuJIUvDuv4b7ChUJ1tMjr0+Pu3
         zZybjvBF4wwsFulSQ2QZ0PeiUqre1i9CDmPpQaWFTt+obPQn0RPB3ntunrqHIXDhPb2Q
         U/pGoYo+UcVBcmvEACUC97aLY0FPDJ4Ap4aeHXKoWKBEocqYOhAoke1E0FummkVlcyQr
         +CnA==
X-Gm-Message-State: AA+aEWauJjK7MUKGzrUJuR/PRm0g8sHLydZFSQQtbT8Dnrafalit2FET
        GxfStl1LadvwXORDfrKxcuacmuHA
X-Google-Smtp-Source: AFSGD/Xv1gJgMCFKEINJTv08mXr2ySFbmMLA9xymD+/F3o91egsnJEzB9OTBqmplJOijcY52tmuUJA==
X-Received: by 2002:aca:3e06:: with SMTP id l6mr4299834oia.299.1543608244342;
        Fri, 30 Nov 2018 12:04:04 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.04.02
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:04:02 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 07/10] NFSD check stateids against copy stateids
Date:   Fri, 30 Nov 2018 15:03:45 -0500
Message-Id: <20181130200348.59524-8-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Incoming stateid (used by a READ) could be a saved copy stateid.
On first use make it active and check that the copy has started
within the allowable lease time.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4state.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eaa136f..7b3586ab 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5203,6 +5203,49 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 
 	return 0;
 }
+/*
+ * A READ from an inter server to server COPY will have a
+ * copy stateid. Return the parent nfs4_stid.
+ */
+static __be32 _find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
+		     struct nfs4_cpntf_state **cps)
+{
+	struct nfs4_cpntf_state *state = NULL;
+
+	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
+		return nfserr_bad_stateid;
+	spin_lock(&nn->s2s_cp_lock);
+	state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
+	if (state)
+		refcount_inc(&state->cp_p_stid->sc_count);
+	spin_unlock(&nn->s2s_cp_lock);
+	if (!state)
+		return nfserr_bad_stateid;
+	*cps = state;
+	return 0;
+}
+
+static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
+			       struct nfs4_stid **stid)
+{
+	__be32 status;
+	struct nfs4_cpntf_state *cps = NULL;
+
+	status = _find_cpntf_state(nn, st, &cps);
+	if (status)
+		return status;
+
+	/* Did the inter server to server copy start in time? */
+	if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies)) {
+		nfs4_put_stid(cps->cp_p_stid);
+		return nfserr_partner_no_auth;
+	} else
+		cps->cp_active = true;
+
+	*stid = cps->cp_p_stid;
+
+	return nfs_ok;
+}
 
 /*
  * Checks for stateid operations
@@ -5235,6 +5278,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
+	if (status == nfserr_bad_stateid)
+		status = find_cpntf_state(nn, stateid, &s);
 	if (status)
 		return status;
 	status = nfsd4_stid_check_stateid_generation(stateid, s,
-- 
1.8.3.1

