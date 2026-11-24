Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549763;
	b=ecV4kFnX2koCNRpgSXRokUcV91SdfoHV7n33vKFhrzA4TWg9z1VlDjLvyCPtbkI1COix
	 zMibcZMhRQr04ka2erh8nRpuXbQ/5qCVxz/JjAaBJnxlJW0e4Z6K3ugP1L9QAQ10a/DNc
	 gRm6Tm8WjqY+ZWNfozzUypwadX/y0pDcoRXsXbgbjKXgkfk2oXGU7rtnWcu+wwpoJrj0H
	 L/j0PdfgdYdeMksXx3yJv7Ou+nGy0lSBM1O/nHxQKSiachZGMQd6LLhIUipoLSUQcQVpK
	 Vn5OETUZP6Kly3HUBZjo3UmMwIMBhnosOEWDeLlIX9eVKGSrP1YGmLcEga5+zYICvpQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549763;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=yvgOq0d9S6TtDtOdFnJxyYYnrpcSihTZuHtkKlDf9h0=;
	b=sCNVTS4BwDHiiPwweQB218cBV7Y49pIHAaLsHjcoO+PpcUBw3ATVxrrofHX5iMNmzytL
	 dxFquwNcC48nbtoCSsSjamoslTWPkBDJCquFCIGwtK/l0nIexOj9lrzec5jp1vlVoe6c6
	 4hCw3+f6Lb0DrZ1cFkE91kx1F93rxQHteifjkBlHo8+GxXTJNF0MNCZH5T7V1W7Tn9wct
	 PMbGf+s7XXyQDRJUCM8PBNtWIZKEzqLL0Bu72BGMJ2TKMTTemPSpd/6YQ3Yx/gX+O81/Z
	 lmZUpXpLI+/Y7jY/ClvGusgu+Vshz3dQDBZvyj9Uv0P+SdCnWcSYAi2w5WcTUH9D4RA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvF2mjBB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F339606A323;
	Tue, 24 Nov 2026 19:49:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvF2mjBB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 734EF1F000EB;
	Tue, 24 Nov 2026 19:49:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549763;
	bh=yvgOq0d9S6TtDtOdFnJxyYYnrpcSihTZuHtkKlDf9h0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JvF2mjBB4THKCV4tAV3KkZYDJMMWZdNNHS8ttb51kOia+iGsD03qHZuCwsaMNqZQJ
	 BKDuFjUSZx6CJt1OVpwhIIZr1cBbPRvKCrh2n0Eq7gpEzX6Pv7x7TtzFiOT7ue5IdG
	 GbH4IAlkSf5oQuDJ37SbI2SJl5kHSZq8riHQP+tz9RL/HnOwloZ3VGWGHog+jIBz44
	 WLcgIAMB6hxcE1GWXZtjGpFDahra53PBrEirbgNeZwI1rnzoRQp3W7ChBku6e9Z+qn
	 3cjCmehswE3HmhmXQ7qP3gEX6wBrAklrqAQYxsKIioUKu8PX0yuTeleigzDs/L996g
	 +avurPdtXY33g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:46 -0500
Subject: [PATCH v3 07/12] nfsd: recall when a CB_GETATTR reply omits the
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
Message-Id: <20261124-delegts-fixes-v3-7-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3116; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=DhLEfE/Jg000N/BGIhPExPeKjIZnZt2tSyzjPie4Irc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo2KwD9mBLN4UY7pmb4e0oER+9nqB1rYE8du
 jgYzTPlA+uJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNgAKCRAADmhBGVaC
 FSC1D/4tWSbGlETnupVv1g5f7dcxAo6pe+7KmDoMWtTyEzSJJR6yhRMCQdERJxSgzos5OfDJFCH
 D+db7k9DyqKgSixarV13SVDyv6vZunvykdQfdb5m4H/r1nvMgMwAoDmNytKaRXqTpIn1U+kq0j2
 Dhja03t0Szk44xRnmq8OZ9PsMpbTqzmC9Nmemmo+jm+0X25c+mJAcP/nLPoORhTqU4xFU2admlw
 EehgBN+1OlQCvTCfPkq5DeF+GOBG0Gpdr1FXAKnjC97l3eNkTwbFgkXxWw+JxBsEMu1kgbnJZ8A
 K55BrjcWAfZTV/fq2RujrmgVk9M0TXgfN7Cc/67+f1zwOi9qsvIcsB7hRYHOngUBCL1Rh9tfnU0
 80eVbu/A7EwrCuJ+hEaOn9GEy1AH/Ucwl81Wx+Ej2mAmrSfV4qurX3xighvjYOBKYo9DKUpf6Js
 Bdw+fU6Kt/c0MY/LKdWdlA2ChcNdVlxxur5+FJGyxbMomwaDtQRADe1+QvXeS7d7YYwm8zuk9Es
 tkmdcMS6ZRy9AXi0reLkHSfupnJAlmCSG9NKkS2P29EtS0VuIZWNdKc0LcOCQgzpCNcV/Sj5HWI
 C9wad5wZSkCGZoZZp3OB8T30sZr+yLWdwXpE77Wgvl280vsK2VS1cMttKnkQAeItNVt0HUQ8mJz
 4VR/EXtAOq/mAbg==
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
index 07f8caed5198..51dca62b2bce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3885,6 +3885,13 @@ nfsd4_cb_getattr_done(struct nfsd4_callback *cb, struct rpc_task *task)
 
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
@@ -4132,6 +4139,7 @@ static void nfs4_cb_getattr(struct nfs4_cb_fattr *ncf)
 
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

