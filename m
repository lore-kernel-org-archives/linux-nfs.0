Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24FD6C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E02D82082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H2BqQFLg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E02D82082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726660AbeLAHO0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:26 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:45314 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHO0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:26 -0500
Received: by mail-oi1-f194.google.com with SMTP id b141so5750126oii.12;
        Fri, 30 Nov 2018 12:04:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=bEIjIY/rDpE2r6ZLK+fnRmNh662BaBr6ZXthexAcb38=;
        b=H2BqQFLgiDlt9fewMLJ24k/ThSWKt58PK7UebwF0AqxMblhufqUsC/yIanrQ6iQtPv
         4qyewIafDDDwu2jLYJLpiE88n1F6ajd3LrqwPgDpH7MKdd0ZpRDuEZWXIcQnl1nksf2C
         ycT/qj8bMIwVtxKP/3FQc6CLpQ4Yfd4ByNRCSeaIFMtm27DVZlZAxY3+Pj/LrJQxMapR
         6gpUXI6Auq9qnlxd6Dg5wldphIHrg+seH3cOv7p7yLZNiHvbWrR8K/+0X+0CcyvPbjgu
         s9OSukxsHND+jQjzrH5a3EyQQ2YBAQzAjwUZ8R+mvsJwXDL3rIfTQdOi4LO2e0c6L3hU
         k66Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=bEIjIY/rDpE2r6ZLK+fnRmNh662BaBr6ZXthexAcb38=;
        b=dMx0Ue4pzGqpMA+CkvVVkyuPI8aS14dHDLj2zoYO4Cpc6+DnOA8ioMI0mfjCYoi7Kd
         jPm0EB2JC0gGYS+YdmqlE18YwB5CyxoW0P0eecJi+QJt0imK14sihP/b/9aeJoSTGhpx
         l/etBWQYz8RJNE4aGbAQJXYdLn+Pqch3D8olo8P0gwGDscH1bNCBhQMsDDlqSz2SAv3t
         b/LH3Sb85BQjdHZaL7urvg+19BJldZTAyOUiVPNGGXn3V1mYUw3GXc9JX72o81QaaKcI
         cNQll88oUCxOrHJyh0Z6Thubzii4EFcpT1I8b0eoYO86bkchENI17AbTZu0mz9dJ7jlR
         2kYg==
X-Gm-Message-State: AA+aEWbRSGI22B1Cw/qJMtZ4TBymDEjO7aVb7F8O5aGnC7qXL/upEeiH
        V3UwCktezQM1N/9G53uKk1kBoLr9
X-Google-Smtp-Source: AFSGD/WzVsqShWBOTgfCMrRRzvxF4d5uUSVr4fIpftuHaElN89K5L78KaWVtMBkEp9QL3UBNvUbsgw==
X-Received: by 2002:aca:2ccc:: with SMTP id s195mr4283599ois.282.1543608241033;
        Fri, 30 Nov 2018 12:04:01 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:04:00 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 05/10] NFSD return nfs4_stid in nfs4_preprocess_stateid_op
Date:   Fri, 30 Nov 2018 15:03:43 -0500
Message-Id: <20181130200348.59524-6-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Needed for copy to add nfs4_cp_state to the nfs4_stid.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 17 ++++++++++-------
 fs/nfsd/nfs4state.c |  8 ++++++--
 fs/nfsd/state.h     |  3 ++-
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d505990..0152b34 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -781,7 +781,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	/* check stateid */
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&read->rd_stateid, RD_STATE,
-					&read->rd_filp, &read->rd_tmp_file);
+					&read->rd_filp, &read->rd_tmp_file,
+					NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
@@ -954,7 +955,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
 				&cstate->current_fh, &setattr->sa_stateid,
-				WR_STATE, NULL, NULL);
+				WR_STATE, NULL, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -1005,7 +1006,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	trace_nfsd_write_start(rqstp, &cstate->current_fh,
 			       write->wr_offset, cnt);
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-						stateid, WR_STATE, &filp, NULL);
+					stateid, WR_STATE, &filp, NULL, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1042,14 +1043,16 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 		return nfserr_nofilehandle;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
-					    src_stateid, RD_STATE, src, NULL);
+					    src_stateid, RD_STATE, src, NULL,
+					    NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
 		goto out;
 	}
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-					    dst_stateid, WR_STATE, dst, NULL);
+					    dst_stateid, WR_STATE, dst, NULL,
+					    NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
@@ -1353,7 +1356,7 @@ struct nfsd4_copy *
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &fallocate->falloc_stateid,
-					    WR_STATE, &file, NULL);
+					    WR_STATE, &file, NULL, NULL);
 	if (status != nfs_ok) {
 		dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
 		return status;
@@ -1412,7 +1415,7 @@ struct nfsd4_copy *
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
-					    RD_STATE, &file, NULL);
+					    RD_STATE, &file, NULL, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
 		return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f093fbe..be3e967 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5158,7 +5158,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 __be32
 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
+		stateid_t *stateid, int flags, struct file **filpp,
+		bool *tmp_file, struct nfs4_stid **cstid)
 {
 	struct inode *ino = d_inode(fhp->fh_dentry);
 	struct net *net = SVC_NET(rqstp);
@@ -5209,8 +5210,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	if (!status && filpp)
 		status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
 out:
-	if (s)
+	if (s) {
+		if (!status && cstid)
+			*cstid = s;
 		nfs4_put_stid(s);
+	}
 	return status;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6aacb32..304de3b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -606,7 +606,8 @@ struct nfsd4_blocked_lock {
 
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
+		stateid_t *stateid, int flags, struct file **filp,
+		bool *tmp_file, struct nfs4_stid **cstid);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
-- 
1.8.3.1

