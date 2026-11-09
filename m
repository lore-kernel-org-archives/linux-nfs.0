Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256650;
	b=v0B8sZj2Y8Ikq1WG6yQsDzQf4IXfZK+ZqoQ/Gss6+w+Vo5kJd3EpvdPwSgm29+K2j0Vg
	 RIzmTqk9/CgXI4XgO9bk7kdQ8R07JKM3RujqwLayLIGTG+CeY3vB718EpKn9iOoAbV4s7
	 KHpYM1piSXUUhnaxvWDv57cfRt01eWe/5YE5IX1MfMgBmcgwZZIwh9mOQeoTRRVbKeFFv
	 OEppWYFbuyAV2OnEg3pgyft+HeSb5Ms1R1pNAwf1KH0s6UiREvGkyW0zEirgi0kbyGZL6
	 YwSn1qG3+A/2RGh4TDoPRFWSOZmv2eyCoEpdYcl52FEEblvgfPzq83gaqf8obR3jHWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256650;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=iIuv/2glJbbQLbo0fn63ycmi4cxJog2n4zdCSUKGsXE=;
	b=HCgk3uWt65XlZZxKe19kQRZKZIqO9sFcBLtcY8aDONePwsMEbGVMZSXV5xISHFeuOfLH
	 ZN1rXZr76LJRNonYj4IIJXXKrHBjGTa/hbZ9KH3gNJXE0doqq/rZ7/tOwRKtY1uERs6q6
	 oWVxZA1+oYvC2IPbMGkHScqT3P24DWpaPUbSa0qbnMdp88/vxa+tkCm1d4JUg07tACSb2
	 CfQPJIR5XWpiVrSHP7QJQ077HavA5Pt8RNItP04i/LdC7vCGiku3YTqGKTby4w5MgkMAm
	 O4MamSBBozLeisJNMAdm1K0ipfiv0oFk8b2YtwHUEAInDI1av7t0ROvfMyPneD2+EUg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lquDWrLU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A20FF606A31C;
	Mon,  9 Nov 2026 20:37:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lquDWrLU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 413621F008A2;
	Mon,  9 Nov 2026 20:37:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256650;
	bh=iIuv/2glJbbQLbo0fn63ycmi4cxJog2n4zdCSUKGsXE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lquDWrLU4LxsyxsMLpynItWYAPye5nGS06ySJHGi/own1xLhcHsEqs0ttz7AvDAD/
	 C5WbR4gNRWFBRs5DlIYeS6X/UPlrqmTK1S2bNRZDadz29X2bXwzXK++VL8vUF6cKpn
	 1HTZqsa4vqZD45D0RXQIqbQMIxQd96GVT3hDR3sIgqEGKKvtgU7e8NoScjMZmOnaW1
	 rgu7itigeiRkS9tggfDEL/YoI9Jgqabw+9oEA4LzJ8gxsoW8dUdrY1mNWWoru2oVq5
	 cCEokaAC4K9TFx1+G3wcJsscA99cri/rhXftJGcU9tw0YFtL4A4QNZstTJbh0EsniD
	 GinJgjah3IFQA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:42 -0500
Subject: [PATCH v3 1/8] nfsd: Report vetted delegated timestamps in GETATTR
 replies
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-1-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1494; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=kcKqpTK1SJ44ek8mFa2BspBp0o2r3FYkLGkSPs7s9o4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i77OgarUuU9PWOhffHpEantuZTILKEjdlmiZ
 WEjYDjYyBuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIu+wAKCRAADmhBGVaC
 FYk+D/9SDjm1jCd0+tJ75FYFXhjT3mkET4PRneEtZVsl1IRsGwMXB1XPwWFSz54zz/pevBV2N74
 J00Nd+TR9KQgaPBw6o0Cj5xa/RA9y2mopXUmoCH/mCnAkLs77FnkE6TWGZKQTdWtUzUpQJY/OiU
 kzTwylo1Lq5YkYjmoo/RXjQjpNMv8Y2fjWFd3fgZwg4XJmcibynI4hq2sFUgLdi4l5OmADITfGs
 xG0jOq22yIk53NEySNv+jKK5F+tElq1gk8UNoxDPFtKiBnBSGh1RF4ASYOcq5vy5MueKbtW3cm0
 3+gomG1fYwZ7XJKt8Zp38UH6Ela4Qrv2ak6hoRiIQQPCA2r378Fr6Melz3DJOf0XEaHIlroOvBn
 EXKFUwbFr2Nfbczuv8BjvP8k/zvZiy0Ee0NtdR2kd0z8mMXK/MwWQajpAuntsD+vmLFUkZcam6u
 VYEdJjNsnMx4OtqKoB3Jl8I6C3QYW8PeXXVq5Dv2giJO1MLPM2gJpmfbM6dycZ7YFBxVy2lFOGN
 YJvIn4sosoOYWNUS03IVX6uNQsYgM7C4ira9fz06mkWTJsscu33fnHqwG5Gj8Y8UlnzryPRtnpI
 GdW/Ywax2uycB15/kAvZ90LbOn0LOo+340j0KAaRzzm0spqTPGaHrUNG6G3/6tpfcNPi0Dy56wf
 mBERUiclsuE4jBg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When a CB_GETATTR reply shows the file modified, nfsd4_encode_fattr4()
overrides atime and mtime with the raw time_deleg_access and
time_deleg_modify values from the reply. cb_getattr_update_times() has
already vetted those values per RFC 9754 section 5 and written the
result to the inode, so the override undoes that vetting:

- a time older than the one at delegation grant, which the server
  ignores, is still reported to the querying client
- a time in the future is reported unclamped

vfs_getattr() runs after the update and already returns the vetted
times. Drop the override.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 90b44163f886..434b6cfc5741 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4098,14 +4098,8 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		if (ncf->ncf_file_modified) {
 			++ncf->ncf_initial_cinfo;
 			args.stat.size = ncf->ncf_cur_fsize;
-			if (!timespec64_is_epoch(&ncf->ncf_cb_mtime))
-				args.stat.mtime = ncf->ncf_cb_mtime;
 		}
 		args.change_attr = ncf->ncf_initial_cinfo;
-
-		if (!timespec64_is_epoch(&ncf->ncf_cb_atime))
-			args.stat.atime = ncf->ncf_cb_atime;
-
 		nfs4_put_stid(&dp->dl_stid);
 	} else {
 		args.change_attr = nfsd4_change_attribute(&args.stat);

-- 
2.56.0

