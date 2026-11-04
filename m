Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793793377;
	b=p5v9vPtPUrUFqF/gbLUSgA7xxy1DulZrDm9G1HZ1bUiqLYUzGkRKmXunYK+ULSSLnruh
	 XcTrTqqvUC53tXiFqM8K21xzOHHTq+pRRgIUAH2sucucShzEUmJ9dK1nA0FAVLHkKwV4k
	 WRkhWJ7GUZGqVk1E9CC9ISagOMrg6ptTyELNPIMzHouEuqAnMTK5i09iRafIZ3CusvTbi
	 5LRQqjjQNgkfaefGTC6xlFT7SCn4S/oLxVoinOz0zMHHnekgdk/bFfETvUV3nj6UNui9y
	 e2Th6Fht076EFCx5Uni96h1hrCXBb8ljB2wUMWSc+iNotVqUf8BzaFhgRhkvE45guTA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793793377;
	h=Received:DKIM-Signature:Received:From:Subject:Date:Message-Id:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:X-B4-Tracking:
	 X-Change-ID:To:Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:
	 X-Endpoint-Received:X-Original-From:Reply-To;
	bh=jyG/aG3AxvPO1fkCw9kea5Bx4LNY/1DvuFEFZf9uADY=;
	b=NtkEskS7lEm5QcfjJIbq3MGT5W6wTXk3C8hegIpNLQ0bWWQf/6kmvul69MoBEC0+4h+D
	 /oH84Cc8gkJeTlJ7uGq5vjD4bN2KQcOG7GFDLj73Ab6aa0SpwMyrjLdeKPYneqDouUGHL
	 7mY0P0BmPnH2tX9ssiUX468jJ/PJKCIt+TSBzLsINgf/ZYoYnzjUlzGUhRvK2+LtF/hbX
	 5AHIq5be+XkZLlwHPXYB51ssU4JjNtrCbqPVMESMjCbmj8lWxBHQ+9WsI6GxCktiVoSsS
	 2hyr9+WP/Kr8fK4CdLYnnF1WBPzMWY0+shkhrijQXDCBjeVxY1c3qFKbskKaWmqs3MA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bIhjDTGJ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0385C606A31B;
	Wed,  4 Nov 2026 11:56:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bIhjDTGJ
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793793376;
	b=I6nqSZulCbApW0p27y4m2hv6B3FdRyOo3VB8sAJzkqhJ98yUNycPzlEMo1ebRvqtUg9Q
	 dqD/FF51YlzCgrjLShhIQxw+j7jn71Vbd0xa9zUHUptnca7DKdavJebWbzzfItVGdoFLg
	 a/XFFeg8GxiQ64pFW6NJyHBYywHoa+qmunlIkroPdz6QSJSeyYsjTFiZ3toqEyqmLxhh4
	 syJGzcjttZSUdIgeycFWn3bL9f07InUA+yfqC5yQ99hP0db5uYD++Q7BK1ikkv6A7FHtu
	 Bu66QnYNL7uSNTPsVj2+bbFrPQtETt2WMJ25RVi9GGHL5cg8aT2ZDP0u8o4H4GhnPpw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793793376;
	h=DKIM-Signature:Received:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=jyG/aG3AxvPO1fkCw9kea5Bx4LNY/1DvuFEFZf9uADY=;
	b=PXqEiKds9lX24ItxiH4/ZXcXAghAmUu39q1J2RQ9T8xpRQDorToHpxjuVd2rc2trooLq
	 FmkrG8CRVKPCUsHhY1Mt4vkL5dFkB8HmCZotsPZgL7btVQQwEZOZTWK/37848hnJlufmY
	 eI4wJ1CIaGa0w68v4Crw4CLvvzZmjqQ+Ol1/d04k7Fr48UFJHDMKv1bl9vYR2yd4VOTpB
	 56olS3JddSutdpjExwc0TI0hDkP57zR5mYUZ9j/Fq+NQ9f72aMm71NdxbsHXeNkpSnSaQ
	 tGt3UzvVQ3VLo1+0XiHbIzmy3+NUf9fFDloLFE7jaAM39+P17zabXG2pd41vFIsyKjQ==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 461271F000C1;
	Wed,  4 Nov 2026 11:56:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793793376;
	bh=jyG/aG3AxvPO1fkCw9kea5Bx4LNY/1DvuFEFZf9uADY=;
	h=From:Subject:Date:To:Cc:Reply-To;
	b=bIhjDTGJcYkKS3zO+f0/1IVJmLp3OhAmEWA3MKy7jm+B1wcLup2d65WEk8CG34oA6
	 xiQnRARya+0R9Ag0RePCTdHT0XGdXupvN/AiXdq2RKxgmMlSMkgnU1/XuGIh4ZFQhz
	 xhVvfaj36owC2ijqaX6nD9qZnOZC/9ZCI+4DwnDtw7L21ZfeeXasKQKLznRdlisoar
	 AMynMpM0DADeDfRiyAbrE5zzqZYVddEOBuQB5gOH1leE3xpfXF0M7/Vd80bGF3G9Pi
	 wDbuVaoj4vPbNUsKDwbOtlNQrfYwl+PpNj8hBtksHpHFQNM1AJ3lJ3nck+rzK5sFbO
	 sL+h8mp+2z0OA==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 95B2846E02;
	Wed,  4 Nov 2026 11:56:15 +0000 (UTC)
From: orkunsari via B4 Relay <devnull+sariorkunemin.gmail.com@kernel.org>
Subject: [PATCH 0/2] nfsd: fix two mount-crossing regressions from the v7.4
 merge window
Date: Wed, 04 Nov 2026 14:56:14 +0300
Message-Id: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yXMTQqEMAxA4atI1gZsEf+uIi60TTWCVRodBop3t
 84sv8V7EYQCk0CXRQj0YeHdJ6g8A7OMfiZkmwy60JVSRYneiUUTdhHc/InKNaWt21o3VQspOgI
 5/v6G/fC3XNNK5nwvcN8P5yNQGXIAAAA=
X-Change-ID: 20261104-nfsd-cross-mnt-1f84d7972869
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 orkunsari <sariorkunemin@gmail.com>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793793374; l=1188;
 i=sariorkunemin@gmail.com; s=20261103; h=from:subject:message-id;
 bh=QUJUQXa5hExsDV/MhlbVSo+ywaTLPPSuOAFTqzJnnt0=;
 b=CgeTVhR+6frjNyCzeLzIPupeBtoQebyGkzSAuTI+npHVgN9XLA8+DUVJGp6yROp0bHdiXPQzL
 8zWm8qAndLUAxr9nmZMlkeEIuV6uflMXh7Xu7KbK4ukzxdDKv6d31zO
X-Developer-Key: i=sariorkunemin@gmail.com; a=ed25519;
 pk=MJ3Y3somkGDQVAXOSR189QAqWOcfzYCRkL1cSQgJXnE=
X-Endpoint-Received: by B4 Relay for sariorkunemin@gmail.com/20261103 with
 auth_id=1408
X-Original-From: orkunsari <sariorkunemin@gmail.com>
Reply-To: sariorkunemin@gmail.com

Two fixes for code merged for v7.4-rc1; released kernels are not
affected.

Patch 1 fixes the NFSv2/v3 CREATE paths, which pass the dentry returned
by nfsd_cross_mnt() to end_creating() and so unlock the wrong directory
when the target file has something mounted on it.

Patch 2 makes nfsd_cross_mnt() check access to the export being entered
rather than the one being left, and restores the check after ".." in
nfsd_lookup(). SECINFO keeps its previous behaviour and does not return
NFS4ERR_WRONGSEC.

Both were found by AI-assisted code review (Claude Code). The fixes are
build-tested with W=1 only; no reproducer was run.

---
orkunsari (2):
      nfsd: unlock the locked parent after crossing a mount in CREATE
      nfsd: check access to the export being entered when crossing mounts

 fs/nfsd/nfs3proc.c | 14 +++++++++++---
 fs/nfsd/nfsproc.c  | 14 +++++++++++---
 fs/nfsd/vfs.c      | 46 +++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 61 insertions(+), 13 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261104-nfsd-cross-mnt-1f84d7972869

Best regards,
--  
orkunsari <sariorkunemin@gmail.com>


