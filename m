Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438760;
	b=ZMTA3xsGYcgCfXtX1gX8uLu0jp9UvPC8f5A1MCD1wjE/aZJbUZ1LTgPrp1fM2i5BLOwA
	 WP7OalyaCVPNdJbzHDGrChieKdIzsPWwQFGwMmDhuKyqKC0BHP6hxtxIxu4AbRSQx9sUi
	 swTECFaBgFBr2PXBbLIarDXeR4Bd4pQg1ihyLbkp0nDGZQPK8OF9pmNuPyrlc9PMBvqLC
	 T1k2FOMujvsWPlQ+beiixB3EPvmHToqDDgoAdEZ1ZHwbd+VHBnpRL6VkFndtsYQm7s68q
	 KcnxwDvG571mnHfBPPCTbILaY/HNIP1isYrgzWdXG1RUkn/p851Ldun5nB+DxS5wkHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438760;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=lYQA8E21CXNoACqY3lzoydj31liD9iNcGJEwrNiDKQ0=;
	b=0er7l5imI9ZwzOpeAGtmZXnbaola18xRoyTV12c+HJi8D23NFCjv6nAjTnt8rbSzboQU
	 lBbZGKxlk1/0E1YtZpTXFWbRgc97JApq6eUcxXBNq82QQt61uVWQYhY2sB3KXHeZt9uok
	 VPcSebD5vzP/b/pVgRbVEH35PEuYpEAfVkRPnPprEeuP16eh6we9CBILWw1zBj/nC1Wyu
	 T4+MkAYFKNDlUoFNHt8oPc3abBQTuP7GCG1VO7ZpDxZLSH7n/FkFJYpvRsCdv4MbJG4ZZ
	 eFFuX5OiZoAfhXanuDEquN4NYBiN7yPABTSpnIlw00JxzFYy1v6HGBPwKtpa8D7gZGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=epCkC5MM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 738CD606A31A;
	Mon, 23 Nov 2026 12:59:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=epCkC5MM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 128031F000C4;
	Mon, 23 Nov 2026 12:59:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438759;
	bh=lYQA8E21CXNoACqY3lzoydj31liD9iNcGJEwrNiDKQ0=;
	h=From:Subject:Date:To:Cc;
	b=epCkC5MMbjtixUP4V/w/sc9WCFuRhgrZVAt+G9cwFooT6Vg/XOCSgpARLNwgtAwrF
	 DgmGX9jYbn1eiLT85LEyICiiu3DhOeub2VVKiOAyZ+Dx1ZbCqiDPi+gqu5tno1kE9l
	 OAJIr3MBZrfc4e/C3nKZSfLgHZ39Be/hfmiivV5nxsXRFkY10U9MEMc+cA3bqAZsb/
	 iIgC7WKzCTM+mIUEP/RTKpEl3bTZdH/zWzqwcQVhZTVRx3EIHuiogzxOFygqQ8bAkJ
	 pF/uvWMT0Ax21ovhjKYkToAf5kMwOT6KrziQivXYDvU1hTCM065nH2nxUY5mASVD0+
	 mPf/do/QGrMtQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 00/11] nfsd: various delegated timestamp fixes
Date: Mon, 23 Nov 2026 04:59:03 -0800
Message-Id: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
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
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WMQQ7CIBBFr9LMWgwMpgVX3sN0oWVKiQ00Q9NoG
 u4udu/y/Z/3dsjEgTJcmx2YtpBDihXw1MAwPaInEVxlQImtUiiFo5n8msUY3pRFZ43WylnlzAj
 VWZiOoyr3vvIU8pr4c+Q39Vv/lTYlpBiMferOobu0eHsRR5rPiT30pZQvVkI+a6sAAAA=
X-Change-ID: 20261120-delegts-fixes-798331d91d8f
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2453; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=6IoWgSowCubT4ptIkKjepnjnghVREhQV94yxV9vBB1I=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDifOiZVoNajWVQnDSnydShiPfUFxTtY+coTy
 B5Ndblu6kKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4nwAKCRAADmhBGVaC
 FV5READQuq1TPrCfHMzvtxxFvBY22EPXQKYS7oZPP2mOXKPN1eziYYodPuxjsOkjmrPt6RvGSea
 JkcLly70xFEIAC5Ezk6224wLAIW1WfiAt9QOcwSOoQEaebOyrtals8GFLPLhwjoxyeaG48+AIKD
 niQx0uhWRLcv/Vw3tv/pRPBwgTSf+1ReBcmqXVVGUDzEHW9Y8Llk6zz7egoC9ExKX4cLbITiksv
 RpFiUzQqWfPHSIeVszBz9OezUb3FbCw9Sgd/NVFEr/xa8MO45baJtP+ZzCeKXjEIwtMPe3LFojW
 +CogvNd5SKzgJ0NduPRRTVY4fhl26RiV4aja63HdpzvZ/jbGqFCyoUAWapBiemif5ZTzECg2dbE
 txwEA1OslVAZaoDxZ1v3foKP1kbzjNzJgG6o5JlBuhrrYBqLhstDx7YUabExP87YS1eqMGrJZXG
 ej9JV/3WrIXj6lu75zdj0n2fH3e/A7IONI4vGekqgE9xF5lyn74ckHkEaZhRK9FSJJegvJvZPgM
 15iYS6QzrKqcqL3Avwq765NaLViK2ibyzT+q0JbASFrIxlRUyBdMjnxX0dCq0qtJ1Zy5f/wAQ/7
 s0BNscCddS4+MIO51OtLzd/R8tX2CRS9PKWorSVzGA5Ak8yufl98v9YGt8F/zADG4TvG8u/xRCq
 isTbbCWsPnUgWpw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes up some bugs that Sashiko pointed out, as well as a
nit that Aurélien pointed out.

While I was reworking NFSD's delegated timestamp support, LLM review
found several bugs in the existing code. This series fixes them.

The timestamp rework is still a work in progress. These fixes can go in
ahead of it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- nfsd_setattr(): sanitize a fresh copy of the attributes under
  inode_lock on each attempt, since the setid bits a chown must clear
  depend on the current mode
- cb_getattr_update_times(): pin fi_deleg_file for the mount's write
  access, and skip the update once the delegation is unhashed
- nfsd4_deleg_set_times(): set dl_setattr only after notify_change()
  succeeds
- add the missing Signed-off-by to the nfsd_setattr() inode_lock patch
- reword changelogs and comments
- don't use ! operator on cl_minorversion
- Link to v1: https://lore.kernel.org/r/20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org

---
Jeff Layton (11):
      nfsd: don't hold inode_lock while waiting for a delegation in nfsd_setattr()
      nfsd: take freeze protection before updating delegation timestamps
      nfsd: count a delegation in cl_delegs_in_recall only once
      nfsd: don't grant write delegations to NFSv4.0 clients on CLAIM_PREVIOUS
      nfsd: set ctime when a SETATTR with delegated times changes other attributes
      nfsd: pin the client while a GETATTR holds a conflicting delegation
      nfsd: recall when a CB_GETATTR reply omits the size
      nfsd: apply delegated times in a separate times-only setattr
      nfsd: grant a plain read delegation when timestamps are wanted on a read open
      nfsd: check fi_had_conflict under deleg_lock before hashing a delegation
      nfsd: take the write delegation grant stat before hashing

 fs/nfsd/nfs4callback.c |   1 +
 fs/nfsd/nfs4proc.c     | 171 ++++++++++++++++++++----------
 fs/nfsd/nfs4state.c    | 281 ++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4xdr.c      |  56 +++++-----
 fs/nfsd/state.h        |   2 +
 fs/nfsd/vfs.c          |  62 ++++++-----
 fs/nfsd/vfs.h          |   1 +
 fs/nfsd/xdr4.h         |   3 +
 8 files changed, 405 insertions(+), 172 deletions(-)
---
base-commit: 194069b5ff38d82d302c33a4dd280d948c96cfe6
change-id: 20261120-delegts-fixes-798331d91d8f

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

