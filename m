Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 937F535DD1C;
	Thu,  2 Jul 2026 20:24:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783023853; cv=none; b=HgmncO7Nb09p8u7s+KCwjVAPzHpcW06jZCLuqzNnqeFBmDD+p+nu0ixZDKcyFSbWeO30IMqutmgkcL45RmSHhjr5nuxtlj/nGG0MoY1UC++0QN5Bq77flVs9+vehlLwgxnh7e6756ro3lp/E6A9SgjhBrtmumcoUeeFkoBUqdBw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783023853; c=relaxed/simple;
	bh=Pygw4ryOg79zPL8Zohf12UHXWkYFz8zzfhg5Nk32in4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uCIdXT3pktNoCS76sPTc0EAwIvGUcE6Dw9N1FF10iA1bWom2s9haKMI5vUoiuD+vDjs6h5J6wTxfGn9QwzrmXP9x0f3D6T0aBZLPkZ3ZcGAflwuhDz5Qh5CksmTjxAxToMssQqXBeWauzuBth2+iZhPM0D04TbBA7e3X5SrXpzU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=biJ0PlW2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="biJ0PlW2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 28BA71F00A3A;
	Thu,  2 Jul 2026 20:24:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783023852;
	bh=09nabSfTIjxx+ORUphDRsoJ6nNrhADfGgMUIXyxRsNE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=biJ0PlW23nAU0+HaoUgg/7cftSZVjlkcfH5k2ciuXkAkJod5IcuevAdaQcd39TtlB
	 hQaFFKWH1svZrVFeroIV1LrdsDbm/RXuF3qPgkqFsOwBSy4j1Y6GGj3geUJzW4UQ8c
	 xND90ai0SBWgMp9A9N2JqUXlXn/KRJc+y1QH7HbfQrw4KXdlKBnldur1gJH5qy8g8h
	 UPhicbxrqvTDqs+HvdZ0WUUOr76m0i9wSsRB3LjdOZiXoeesN5bLJUJmSBjfne3oPd
	 toK80lwXL/jjV3XpjAfJo4K8a70/SQ0wfowQUDM3l+z8iIiqiNZEqY1ubgYgDtPcAa
	 a0p/gJ/pE5ebw==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>
Subject: [PATCH 6.18.y 2/3] nfsd: update mtime/ctime on COPY in presence of delegated attributes
Date: Thu,  2 Jul 2026 16:24:08 -0400
Message-ID: <20260702202409.1583677-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260702202409.1583677-1-cel@kernel.org>
References: <20260702202409.1583677-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Olga Kornievskaia <okorniev@redhat.com>

commit 4183cf383b6faec17a0882b84cd2d901dba62b16 upstream.

When delegated attributes are given on open, the file is opened with
NOCMTIME and modifying operations do not update mtime/ctime as to not get
out-of-sync with the client's delegated view. However, for COPY operation,
the server should update its view of mtime/ctime and reflect that in any
GETATTR queries.

Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Cc: stable@vger.kernel.org
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 11 ++++++++++-
 fs/nfsd/xdr4.h     |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dd22bfd168b5..1c5dd65ecfa6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1956,8 +1956,10 @@ static int nfsd4_do_async_copy(void *data)
 
 	set_bit(NFSD4_COPY_F_COMPLETED, &copy->cp_flags);
 	trace_nfsd_copy_async_done(copy);
-	nfsd4_send_cb_offload(copy);
 	atomic_dec(&copy->cp_nn->pending_async_copies);
+	if (copy->cp_res.wr_bytes_written > 0 && copy->attr_update)
+		nfsd_update_cmtime_attr(copy->nf_dst->nf_file, 0);
+	nfsd4_send_cb_offload(copy);
 	return 0;
 }
 
@@ -2017,6 +2019,9 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		memcpy(&result->cb_stateid, &copy->cp_stateid.cs_stid,
 			sizeof(result->cb_stateid));
 		dup_copy_fields(copy, async_copy);
+		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
+			       FMODE_NOCMTIME) != 0)
+			async_copy->attr_update = true;
 		memcpy(async_copy->cp_cb_offload.co_referring_sessionid.data,
 		       cstate->session->se_sessionid.data,
 		       NFS4_MAX_SESSIONID_LEN);
@@ -2035,6 +2040,10 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	} else {
 		status = nfsd4_do_copy(copy, copy->nf_src->nf_file,
 				       copy->nf_dst->nf_file, true);
+		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
+			       FMODE_NOCMTIME) != 0 &&
+				copy->cp_res.wr_bytes_written > 0)
+			nfsd_update_cmtime_attr(copy->nf_dst->nf_file, 0);
 	}
 out:
 	trace_nfsd_copy_done(copy, status);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1ce8e12ae335..d0ef5e7f1077 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -745,6 +745,7 @@ struct nfsd4_copy {
 
 	struct nfsd_file        *nf_src;
 	struct nfsd_file        *nf_dst;
+	bool			attr_update;
 
 	copy_stateid_t		cp_stateid;
 
-- 
2.54.0

