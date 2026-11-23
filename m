Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438769;
	b=FWAVrBmU+k8FXvwUj/oD45jVzBD0Y2R8gS5246aKKPGmjFs0nMI3G9MDBejAR8reGhi+
	 SO4L3S1iz83BaMgKUWMBlR2/V+XtSjQ5tvlMiNgtvBoThoqmM63AaDSvEmoqS7PqJ73bD
	 Va2hxRZasoBaykrCz/qzf8/2oMKzXiogYdGqFvK5siJy1AgniFSymSD7/QKkleXlSTX/K
	 JpsR9l25ALKMWJGjCJyI02WasFtdYuOHdeIi+5v6CbH0yAMOB9rodVqFfm0pjdljsFoh+
	 nnIxKpd1dLvI8eJICeimx/sTNKcIdVP0DTa9OVMp1a28ONI9Ppgn1fKWq8W2MBSBwow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438769;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EZSpnZlL8gNTPlGNgAs8d3Krs3Gsn2Z8b45Cr/NTJQw=;
	b=LsXURJxPsohQfiCUP0tMalF+HcLsgqowvuOROAUYR86G1xAk6d2sA8nsOKIWulXxE7Pc
	 J4bfFjASGLynoJH6h5l2h9OZ2Qsjjr+vHug364amXUboTuEk8SMxv6TaZcAdKmDyELfiU
	 hC13gBs5QCuPp1pD+fl1x4I9ZkEDLZJQVRyblAQ5R/3dE+0O+Zddqwtyv+GvJ8slaZrn8
	 HoouPN97oIDDmrVt6oXinVx3Eeg/q4PWHDfKk+xRSwztodtD5WEs9FXR5WA9lVTQU6QPd
	 hvHyY5T+EiKOE/LLLHp/A3iufiTRKFFQadajWVz3BddYEjUAdWhP5PUuQLfNf8jZnYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kcsqXLke;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 566FE606A321;
	Mon, 23 Nov 2026 12:59:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kcsqXLke
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFAEE1F0156C;
	Mon, 23 Nov 2026 12:59:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438768;
	bh=EZSpnZlL8gNTPlGNgAs8d3Krs3Gsn2Z8b45Cr/NTJQw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kcsqXLkeA+gBxK3mywWkl+GAAOxvRv7mLuYCDgEufguK/bwFghU19+UDBJbfpf4nK
	 QxtySkBTOjCXfmoVMjQy7WFTAklHFJtCR2J3Ifgm1QgptnMJGdKaCteBPBAmX+oebn
	 tMvJCptWYPRcg7+gXi142aTbsXLzl36SJ1jfUtaHHM6FoU515U3Wt+EHc0oGlnnKbz
	 yUvHvg7qnVSnYDAs8rOTY20YLzwaNELFoaTYHswgfCTE/Ytkd/Jk7fShVEbuEyZICG
	 vapxld9Uwe+ipi58T6kNc3/d7pwDvHnAFkB9G5LyZENNVy57vH4UOVtQ33RcoxSaD0
	 9s/EDRvuQizkg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:10 -0800
Subject: [PATCH v2 07/11] nfsd: recall when a CB_GETATTR reply omits the
 size
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261123-delegts-fixes-v2-7-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3116; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=lkP42evRkorYaKR/aawJ9jEmNQO7sFKsC47VpjtdSHw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDilAshV1KEaEPZnccjHxzNKSppOL0Wi4el4F
 7cw9UCSYlKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pQAKCRAADmhBGVaC
 FX7mEACArUM9F4zuUNCsyFeiCdZV56oUKk0acaTH/DC+zc8ekQAQEFOy2KW3ZzZC7CztMvgTvAF
 Tm5Xuze/qGxvslIkyBOlBKaufuGrv52nPeGmOECP1wTTxSbHnEcBQZoEdBuqWbv4U5WiN+PAHfB
 bbsFkho+i1MyCSYdUGfY4i3gqA0oHOqtU//55V244sxGceq2av5ltkWxRgLW5ImjLZK0YZwNQ8Y
 rNU5R8dgfYwkJ+OI7UIt7VH0tdyKP9+kU3w/K17aakN+5Jcotw5tX5UCzoRyYYRcLTZxqU9W8hN
 F7iiSeP98OSA7KLfsR2J4SXMRMSS2VwI0eI6A3NX6iIVhujr5yxRf7yr7zMbEPUstl0EYOFSZzs
 jUruSxkGFEiFbYAfu/2TViFeMHtZHOgK4V1qyfQzvwUTz6Cl0XQmb86pYB9cxiO6lMPJTXn4AWW
 VyvggIwhCHoFWDHSyBCIbgWvT/nZeDbk6cU9xIEj/r+D15XXVhc68nl7vAc9Eeqq5hqc1bJ7eMj
 IOvRQVjePbDdWvstDL3ulN5gM9AO6z7EfsZF9n2HJGoUQwjp+u9AQwyJYhfpCFXYB6V6Q8/KIpe
 ISLGrCaQDnB9RNe/Nbo61bgh0EbVx3e7CgyyASSeH5MsJqf6/V/r2ce8x0LlvPilh3fdIXnWSu2
 OnX5eAqkFxVXlIw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

decode_cb_fattr4() zeroes ncf_cb_fsize and fills it in only if the
reply's bitmap includes SIZE. nfsd4_deleg_getattr_conflict() doesn't
look at that bitmap. For a reply without SIZE, a non-empty file's size
doesn't match zero, so the waiter marks the file modified and sets
ncf_cur_fsize to zero. GETATTR replies then report the file as empty to
every client but the delegation holder.

NFSD always requests SIZE in CB_GETATTR, and the holder may have changed
the size. Add ncf_cb_bitmap0 to hold word 0 of the reply's bitmap,
cleared when the callback is issued. In nfsd4_cb_getattr_done(), treat a
reply without SIZE as failed. The waiter then recalls the delegation, as
for any other CB_GETATTR failure.

A reply that omits CHANGE is left alone. The zero change attribute does
not match, so the waiter errs on the safe side and treats the file as
modified.

Fixes: c5967721e106 ("NFSD: handle GETATTR conflict with write delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4callback.c | 1 +
 fs/nfsd/nfs4state.c    | 8 ++++++++
 fs/nfsd/state.h        | 1 +
 3 files changed, 10 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 70ab4fd32195..ac65ba4c4b7d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -737,6 +737,7 @@ static int nfs4_xdr_dec_cb_getattr(struct rpc_rqst *rqstp,
 		return status;
 	if (xdr_stream_decode_uint32_array(xdr, bitmap, 3) < 0)
 		return -EIO;
+	ncf->ncf_cb_bitmap0 = bitmap[0];
 	if (xdr_stream_decode_u32(xdr, &attrlen) < 0)
 		return -EIO;
 	maxlen = sizeof(ncf->ncf_cb_change) + sizeof(ncf->ncf_cb_fsize);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4e7bbaf65050..645ad916d2ef 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3876,6 +3876,13 @@ nfsd4_cb_getattr_done(struct nfsd4_callback *cb, struct rpc_task *task)
 
 	trace_nfsd_cb_getattr_done(&dp->dl_stid.sc_stateid, task);
 	ncf->ncf_cb_status = task->tk_status;
+	/*
+	 * A reply without SIZE leaves ncf_cb_fsize at zero, which the
+	 * waiter would report as the file's size. Fail the callback, so
+	 * the waiter recalls the delegation instead.
+	 */
+	if (!task->tk_status && !(ncf->ncf_cb_bitmap0 & FATTR4_WORD0_SIZE))
+		ncf->ncf_cb_status = NFS4ERR_IO;
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
 		rpc_delay(task, 2 * HZ);
@@ -4123,6 +4130,7 @@ static void nfs4_cb_getattr(struct nfs4_cb_fattr *ncf)
 
 	/* set to proper status when nfsd4_cb_getattr_done runs */
 	ncf->ncf_cb_status = NFS4ERR_IO;
+	ncf->ncf_cb_bitmap0 = 0;
 
 	/* ensure that wake_bit is done when RUNNING is cleared */
 	set_bit(NFSD4_CALLBACK_WAKE, &ncf->ncf_getattr.cb_flags);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f80abcc278f6..c5f607049aaf 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -205,6 +205,7 @@ struct nfs4_cb_fattr {
 	u32 ncf_cb_status;
 
 	/* from CB_GETATTR reply */
+	u32 ncf_cb_bitmap0;		/* word 0 of the returned bitmap */
 	u64 ncf_cb_change;
 	u64 ncf_cb_fsize;
 	struct timespec64 ncf_cb_mtime;

-- 
2.56.1

