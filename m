Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192825;
	b=uzDrf6zzQXRQWCI4Hn02d4BIzFy/TjwbZ7dUjJQUTkJ0A0d/bdcTGGEGhxFITArRv/YD
	 YOrIhdqlOHzqYOd2GN+Mb5ZwdSABAVxQOZO13vZX8Ac90pzlg0OlHYZyNJo7mwgt69NqB
	 U1CrRscKguK5v5cfMztxaKsA4i+cF30n7sN2v4PaDN7weowoY6UOJ4iutNYvKexDAN0hP
	 eYqMyhYVLo0A52eXRW3+t1CDZDP43vwA+GUFJg5AC5AxTpBsEY5NToDr8ZvY3kcKG8yCi
	 VJ1ABOWHkLgG6NBebFB8ZL37iPcEgbj2MefjZroY9agUZ/lD6vzPlTqbrMHxD5IYZ7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192825;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BSs8jfP0DlfjlBVbU3FabL4gQ2HsAONbzT0SQxcndIQ=;
	b=AJhS7w+wT1vAV2G8Fl1WPzUQVXmYUC44ubwx5Nzr10IRRz9VZVAGlAM6yvgk+X8QPN5Q
	 f8vouXDQS0TnAOk+6J/+gZHK5J5SUM7w5XLaFCQ6X9BIfevex/e+XsZfvIhrKZ6Tq8cPC
	 lfyiLNWa4MSXJN9bByKYuRldPwaMBgRAjnD/r/supl+bftJD+GYdCJc7zZThyvVRCzrJz
	 bAthCRQaYJ+BAK4rAmFtpSAW7wiUtTf4TxiMnjAQmg6BqqQ556NwC1ikgX1jJVEuzLuJm
	 Ok7f63IlDzK7KhgHJ/dKlOMX2ZUBEOnR1cLau/IMvvbeLY5Jr3Z0E9mRJpcbrtidaMw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XwYR0Ks7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EF7260A2633;
	Fri, 20 Nov 2026 16:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XwYR0Ks7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ADE9E1F000D1;
	Fri, 20 Nov 2026 16:40:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192825;
	bh=BSs8jfP0DlfjlBVbU3FabL4gQ2HsAONbzT0SQxcndIQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XwYR0Ks7kp9TrJzPVujP5kpZolNx1Ieqrt7cNemvKlMgxmetCsRVNxXkr19iuxR4G
	 wq3z11RYPysRGEJ72MtoWnz5H8XTWz1ycszscSmBmjevIFJOD8qyJGHamB0w7eDjfy
	 gQARZdiqfmrAj0EgEjWUW4qUMDwKQOMVCmpjSVIruKQNORlaL86XDHpKmXfUL7ryR1
	 o1Vs07Vrjh0mbLiUH9e599AXCuPiCWJ+q13U9do42vNG1uFj8ULiuQHZ/DEKN/plIr
	 gP1g7NgW1kHLL4FYyTePyzbJjIqThkKdjn4F2aSDKUIXG5Z5l3Q2L6g+LVS0Sg3QZz
	 g4m0YvUxKp0bQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:13 -0800
Subject: [PATCH 07/11] nfsd: recall when a CB_GETATTR reply omits the size
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
Message-Id: <20261120-delegts-fixes-v1-7-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3053; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Lj+msMu1o5iZ+PBvOXpflq4rJO91q0T23b2z09LwA6c=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfyla1c+MVr6h82gGwyCNShPsWB5WYxIsXAt
 qH7rw3Ht1mJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38gAKCRAADmhBGVaC
 FQW4EADUJtiB1GFmWW+f2S/0sfXYS0jg3gjH+wQrWRSqiGIPE0saMsN8fzLzLgx00suup0e1OM9
 ODu5BdQyGTJwNJ8ytu3KCF4MYIaz2T9E8MIjk6354fXG+bA4S/TsVUy1K3fVZlfgy2WsiYGhVhn
 6mMAf2FEWYpZPqhHpkxavirT34RVbW/cZhQUvGXuCTRZi/PLKgaWLTGRlPcQ2+ggAB+cZHXQVSs
 4GfU3ISJjv+hoHsre4osQMDZIxOnvHJqtDjSGEieEeW/mAPjcGyTOE0OMYGDzpTNVdVE+m+cQO7
 Ji8JilJjFWOwNVL+xAsdFORyds+nsYJjbECMxpVBEbQMAxmmC9GaLB0S5KVh+FJvrMQaeFKqeuv
 fBOWArrWwAOd69wyJBI6sRGy2JL+TDDRos1I21z59TAyA0H/Z1ECDrpgOk3f66tXUdOGtOMZWik
 6/PW9MNGrXGmb+VoV2WIdfaVsMXcFgPuqucKJi+s9b/UURcqtNiF49HAonk9I5etxMpSCokNIut
 AbVPAJzMg/8aSqcX0zQ2AHgPZ8AqdZ2qxJtUvIWgslx1J0PsHijoc+zbPAmL730nXrgRp562geE
 SlEg93WSdpLnjzJFk/DfCfb/VFDITFOUzLFZZOUm49MoReDmd3B4c+p74BjMpB5nCfbKVbTrzdT
 Xa6OjyeJYL7K6dw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

decode_cb_fattr4() zeroes ncf_cb_fsize and fills it in only if the
reply's bitmap includes SIZE. nfsd4_deleg_getattr_conflict() doesn't
look at that bitmap. For a reply without SIZE, a non-empty file's size
doesn't match zero, so the waiter marks the file modified, sets
ncf_cur_fsize to zero, and GETATTR reports the file as empty to
everyone but the delegation holder.

The server always requests SIZE, and a holder may have changed it.
Keep word 0 of the reply's bitmap, cleared when the callback is issued,
and in nfsd4_cb_getattr_done() treat a reply without SIZE as failed.
The waiter then recalls the delegation, as it does for any other
CB_GETATTR failure.

A reply that omits CHANGE is left alone: the zero change attribute
mismatches, so the file is treated as modified, which is the safe
answer.

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
index 0cd139ee0048..eead615aac0a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3876,6 +3876,13 @@ nfsd4_cb_getattr_done(struct nfsd4_callback *cb, struct rpc_task *task)
 
 	trace_nfsd_cb_getattr_done(&dp->dl_stid.sc_stateid, task);
 	ncf->ncf_cb_status = task->tk_status;
+	/*
+	 * A reply without SIZE leaves ncf_cb_fsize at zero, which the
+	 * waiter would report as the file's size. Fail it, so the waiter
+	 * recalls the delegation instead.
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

