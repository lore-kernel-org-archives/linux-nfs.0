Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B19325A321
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 19:02:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775674926; cv=none; b=pnm9lEneItMQ5oUNZoFeugGPOAwOpgwRXq7ydv8U0z3+ftKsELUr0k1vrFW98HmtHfM/ooV1FJkVidOfgttXYds2yX+ktesXStiud360Oo5A0b7DL8onG1eYXlgTz+Y6WXyPLIPw1bcsu8jexFaa2/m+IcKfNxPs98yqQ+GuPmc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775674926; c=relaxed/simple;
	bh=lHbrIHx11DDn2eskxdDtM9W0ie+0yXIFxs+IETg7hiM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hmZdAiHhUt+TI8p+vG/09NQoIldOctrcj0hlZokw79F+r+RDvpBFxbdKJHbmbJ0ea4QfSursmy481j9+wonxECLKvTZvWSdSHLGKzP2afP31GU3k3jtceGAnqYrl1MaR+o/IozxmYql/TFQMLwp9uLqwx9x+wIieyUJsvBg4T4k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=QGhSRBf+; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="QGhSRBf+"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775674924;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MrDjx0OAn2RNbGLNE/euPU4CanUCWtCizap8gHsvCWU=;
	b=QGhSRBf+Xi71IQ/7ofGiCcTLvOdKGdPVUBPPZV1r4ee/uIXK8Yoxs6oVgR44GuTLZsdoqT
	VV0jm4FzoB2H0Z3KeBbTvxjmMNrb1pMtmVqJWKotJzxIl2DN1AHYIdWQ+syx69/Og3GnVB
	SSM7bT9msXgxrkv6iu6khVJhKnJ9MxQ=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-348-ogdS3iqoMYy6uEg3DG6HLQ-1; Wed,
 08 Apr 2026 15:00:18 -0400
X-MC-Unique: ogdS3iqoMYy6uEg3DG6HLQ-1
X-Mimecast-MFC-AGG-ID: ogdS3iqoMYy6uEg3DG6HLQ_1775674815
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 1133F180044D;
	Wed,  8 Apr 2026 19:00:15 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.81.138])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id F26C130001BB;
	Wed,  8 Apr 2026 19:00:13 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: chuck.lever@oracle.com,
	jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org,
	neilb@brown.name,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Subject: [PATCH v2 3/3] nfsd: update mtime/ctime on asynchronous COPY with delegated attributes
Date: Wed,  8 Apr 2026 15:00:08 -0400
Message-ID: <20260408190008.85082-4-okorniev@redhat.com>
In-Reply-To: <20260408190008.85082-1-okorniev@redhat.com>
References: <20260408190008.85082-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Asynchronous COPY should update destination file's mtime/ctime upon
completion of copy work (not COPY compound processing).

Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfsd/nfs4proc.c | 23 +++++++++++++++++++++--
 fs/nfsd/xdr4.h     |  1 +
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ac47cddef384..b6490167e78b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2132,8 +2132,19 @@ static int nfsd4_do_async_copy(void *data)
 
 	set_bit(NFSD4_COPY_F_COMPLETED, &copy->cp_flags);
 	trace_nfsd_copy_async_done(copy);
-	nfsd4_send_cb_offload(copy);
 	atomic_dec(&copy->cp_nn->pending_async_copies);
+	/*
+	 * choosing to check for existence of set dentry pointer to indicate
+	 * that we need to update the attributes and do a dput because the
+	 * file flag could be cleared by a DELEGRETURN and then we'd lose
+	 * that copy was started with file opened with NOCMTIME and we got
+	 * a reference on the dentry.
+	 */
+	if (copy->d_dst && copy->cp_res.wr_bytes_written > 0) {
+		nfsd_update_cmtime_attr(copy->d_dst);
+		dput(copy->d_dst);
+	}
+	nfsd4_send_cb_offload(copy);
 	return 0;
 }
 
@@ -2193,6 +2204,11 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		memcpy(&result->cb_stateid, &copy->cp_stateid.cs_stid,
 			sizeof(result->cb_stateid));
 		dup_copy_fields(copy, async_copy);
+		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
+			       FMODE_NOCMTIME) != 0) {
+			async_copy->d_dst = cstate->current_fh.fh_dentry;
+			dget(cstate->current_fh.fh_dentry);
+		}
 		memcpy(async_copy->cp_cb_offload.co_referring_sessionid.data,
 		       cstate->session->se_sessionid.data,
 		       NFS4_MAX_SESSIONID_LEN);
@@ -2221,8 +2237,11 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	release_copy_files(copy);
 	return status;
 out_dec_async_copy_err:
-	if (async_copy)
+	if (async_copy) {
 		atomic_dec(&nn->pending_async_copies);
+		if (async_copy->d_dst)
+			dput(cstate->current_fh.fh_dentry);
+	}
 out_err:
 	if (nfsd4_ssc_is_inter(copy)) {
 		/*
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 417e9ad9fbb3..ddd6e005d3cf 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -752,6 +752,7 @@ struct nfsd4_copy {
 
 	struct nfsd_file        *nf_src;
 	struct nfsd_file        *nf_dst;
+	struct dentry		*d_dst;
 
 	copy_stateid_t		cp_stateid;
 
-- 
2.52.0

