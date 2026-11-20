Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192823;
	b=fRATkE4U1x8eOjnt0Q9VXNFPBUSs8Bko5ubvug4iUZLA0+yr8GiwepHlGXviFpgEAS6R
	 HDIiLJhfPjpBbzyjJQrJ789Zj+jL3yxAE+kPwJaeez5rCdVdiSOrumMiOikJA3R86xkUL
	 4jDKMTGsoWCbd5ONRhXoG7HJlzVd+eostkfOYknQ07PEtSYAB1IzkQShVIw3kiv9dkB+S
	 nGb0BLQx79uGv2sygEZi5xsB3V1gtoNBk7ud9MDB87RUWwBrQGdP1mVDaLNsPlp9Ir04Q
	 lBQ5x1cPXR1pT4cHl3X143VezMedufnz/yanwskn/ixCq/cnoCKy4WEFUPauvxQPEoQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192823;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=uJ9PUjQTyNLerfbjbDF9xrOo+Au3nndS+Tr2BXyZ0Rg=;
	b=MIc/2cLPh0WAhq9XS/H4CzW3TLpWsuoKRWt1saI0RGEq1D0C6V3ZnUfXXBi2Q8trCKp5
	 8i4V/CnzGYasf7yEaVzOIsygFCK+pqLSe27lXBVv/1QB+Lwgg+MXjAHZcnGbfuf2xcxF2
	 mDzhYVumacUwL1ACJOXcdpwTiGVhBJf0L2YLEJk/szlizxhiVC9MpSeXMaacGY017/kIP
	 LVNGuLpeRzscjwhGxWa1c8dHRmiuDrGtalEhAThf8a/Av7aUKPsvwNgOrqESbdgvzrfuP
	 llSJ5umTYDUT0EFzMkfxHtR25Ndzmysf90saRmvzrx21lI2c1F5QcysEn1Nr1xN6kjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hStD21Uz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 082BD60A2618;
	Fri, 20 Nov 2026 16:40:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hStD21Uz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B85D1F000C6;
	Fri, 20 Nov 2026 16:40:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192822;
	bh=uJ9PUjQTyNLerfbjbDF9xrOo+Au3nndS+Tr2BXyZ0Rg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hStD21UzPaNZ0L+lDW6/9HpaxCZxx+59o0UzoLjXdo6rty5KL7o4kS3shZqEeCKbz
	 rngOUbghnsExQjcyPuBmY94hxNCQ3e3epUp8GZOpcMDwg5RrVebH/rp2Ocpvc6Dt3H
	 k1pfPhJUUNkiY40t/F+emGO4VMFkP5ntXBE0aF44EiSNJgoJ9QwKEe5ZviyrBYyNC6
	 jqBZnLt3AI/SVgjNRIOz4kVvZdlaQ4JVL13u8fkMl2y7ulDVxG9qqcgOJheB1FXcwT
	 shmQW5lYy94I2vyod3ks8muGuM3MPjkRn9PtIJD2K8tCRxgahGsByrAqxwywdVamqE
	 +zp6DkCA0Modg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:10 -0800
Subject: [PATCH 04/11] nfsd: don't grant write delegations to NFSv4.0
 clients on CLAIM_PREVIOUS
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
Message-Id: <20261120-delegts-fixes-v1-4-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1098; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/i+KFplRxr1dqqGVT0pFXvB82vxa3dBHlgxQtuevueI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfxV6ZbgcWZR1Z/IgTpGQl0kLgkO6Ho7TS1o
 lgjBV3U0gqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38QAKCRAADmhBGVaC
 FXbuD/wN3x2IbE0AAnmRmyFD5EjWzQcu7pv4yKmbgrcO01xxIFjM4YqLG/FZiKKvztizX0Fs4w4
 iu3xoK8K8fQlhLBkLEImXze6dblOAs7vaiIT1z4PgIXW2Y4AgUxIwA9Lrir0Wb/Iyin0tYRCEuZ
 SeevuGKK1OHJP7b1i8xyTMOEYJFmfpkBj5iF6YBbs3hso4Q3MrJRo3xF7MMub0xrBWogXXiPvg3
 48ks0wJzyKk33wpvk9WktlXI7DXtLrtV19rR8H/J9fvHoSlUfrCnE+zxa2uq8Pmty9IX20/KcCq
 MYdKmGIMle+/xysRtjPzhbQkvTfCQQy7jPL1KKdrXLPFk3yBWN8sCrr3orkUEmvCZ42W5rqfZW0
 sRv+P+JaeFDP1nTRKGURAyuxD+3+7roe/f1sPYXjZqJrPE926ybSskMtQMzGie2RrWEwqg5tF3R
 iEYbHQ7N6+sGwZQLLcyWChSg00YLVNBEjAUuBjnrfjRsLrlXGoLnbIMjT2MJX6y8lZnseObU4uE
 3EZZ0voeA0tfdcwBllHp5cc2Ypfwe2z0v1gBpX8IYlpemMbC8A2lB23ihVTEUxrvD7eI8WYuC/J
 7oCe4xxuPFNYaDBZHw8oD7L+PfLUElyNJ5jXXQoc+1xEjPf9LyqCvZXsjzIP23sKCapGogIgsFO
 aX9L8al+Chv8ZAw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_open_delegation() refuses delegations for NFSv4.0 write opens on
CLAIM_NULL and CLAIM_FH, as its comment explains, but CLAIM_PREVIOUS
skips the check. An NFSv4.0 client reclaiming a write open during grace
can therefore get a write delegation, and a GETATTR it sends before
DELEGRETURN in the same compound can never be answered.

Apply the same check to CLAIM_PREVIOUS.

Fixes: 1d3dd1d56ce8 ("NFSD: Enable write delegation support")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 490fefaef52a..64bf2e96dc7b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7532,6 +7532,9 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	open->op_recall = false;
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_PREVIOUS:
+			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE &&
+					!clp->cl_minorversion)
+				goto out_no_deleg;
 			if (!cb_up)
 				open->op_recall = true;
 			break;

-- 
2.56.1

