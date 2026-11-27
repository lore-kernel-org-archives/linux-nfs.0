Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795762083;
	b=atQoG1+KpbEiMPiufEJ6/ZIje0wKCXjTpECmz1IZm22DrJ0QkyYnB76Fq7CDca1016fG
	 Os9ZdBncyWH2vHfAX6eO66+/A3umokVYbKMjE4KvXj7WpaLe95ehwnHnOgPLG2xlTReD5
	 gqZ87uR+wtSVfPm3PHxxgpk+OcT4p8Xl3sUDTZi81iIIx1xvQNAvZhmAXIEpQlpKhkaqU
	 85iYRmU5R+E3kLsza6ENWKaRDx0H2J/0L0Qlo3YrGf7/LR79LlkOskmkX1BgwDYzWFCbO
	 kA7tQFgw7XQKA3GCyXgq+nU4Be6NK9B/mCpYL7vwbp2yNvieVYyWhRz/LVlOGx801bg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795762083;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:X-B4-Tracking:
	 X-Change-ID:To:Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:
	 X-Endpoint-Received:X-Original-From:Reply-To;
	bh=CMItyFoT+rDhhLVa0sseqDBi3d3c7yvIez9SsDmmVxA=;
	b=mB67KvU7YE+J3+iICzhNOYdIS0vcMFDArb+PkNbt6gcKdN4QM129OPNGb2C4CLJ1c3/L
	 Yp6PMi4etKk1w2nmcrjRw3DkWY9KmjC61r6vsb44eZk/hBbsNl9q+En0V3/Wi9U6zt7V4
	 TYGfm6uN2oCqsBIKVCizoBD55x3vtGLVIK04LIfOv716bV5FzSOCBAECYGFjUvKC3C4xQ
	 eteXeI53l99QdmUVz0MEt9NQ7GXT4OsIfNmr2y6Oin8uOceAb9s48HHXFIt8gfyk0oNR1
	 2xfX9po+ipo67+/RKYk/EUun/utQFP12LE/GldCtnVAbkWahTj8w3Ajmq8NsaDJ4jfQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g8yfJsOU;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8ADF606A31C;
	Fri, 27 Nov 2026 06:48:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g8yfJsOU
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1795762083;
	b=GXxUEoFxZ5TEglydaC1B39H15+hI3SbhTVBrLBQEHekgxlGTwPzi8eWiDb1tDog3PAML
	 8WZL6fc548FWo9jfz4RbjLIHaei1RMxwgvrG7OyvoKTvv04DXFHNiBUslP/ycWmUXg0y9
	 yyISIHQi//OhoQ2KXb/0Tpcxx/EpV9KznRnzdOUmdq3IusTjoeYH1dtlAbB8STfbCjSMn
	 58QIA6Oamy1wu2oZov1VJI7MMKeXYPN3Wg/WIVpquTv7FCsUm7YxWDGnKeKn0zTjd9NDg
	 iYy5rKsSseAiHyalHKs4iLLK/NJwCy+k2PidbRQxUfWdf/t/+tPKR0YXSSzIs4nAxiQ==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1795762083;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=CMItyFoT+rDhhLVa0sseqDBi3d3c7yvIez9SsDmmVxA=;
	b=Vha76TFYC+rQCZREnOM1Ux5j7ZGQoINIVxzklsmZP8A9+xeQz3fO+MRLTbKlE1zDrlUa
	 mmq659S39Ia1Z07KkdIcCelq20nkUcHzGBLu/6Mj1ZtJsvwSOyX09nn/NyXUg8P43ThSE
	 cyqNuWtM9FK51Gwx0tC029WOekNntwNJo6x7d6CmqtJRwdmesB7Ky7QgGfYKdbcLyUd54
	 sjCctrpr3BrShI0soSes0L0fkOmFjJpF7Mwgwy3GaeacvjpgM63TChxovtemT/VhQ5XU3
	 LKDDQt0LTcrCJPdtauCtLcYGIceRi2SpQhS1LB9GCFUq+KGvmtlC+ORInUw8VJc54Vg==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 1E8AE1F00899;
	Fri, 27 Nov 2026 06:47:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795762083;
	bh=CMItyFoT+rDhhLVa0sseqDBi3d3c7yvIez9SsDmmVxA=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=g8yfJsOU0vyz/tQCr5wMg1YdutAmVOxlyZgcAPXX2hwgvpoCtjf1tbZMxYrKZyZWM
	 6yeenYIv2pe0Yx/Efas0yH4jVs20n6TFy6lgdZ5nAuvXxIwCw5zDV1rwux3h0eOsHU
	 5AP/13UtFsCQdK4yZr0CVszKVkgb+uGonWCjp3kjdpzQnNVqsjggvfeF2BYWengieg
	 jg5wOUjZrdxOctDljHtbs4Y/Vu4n+C8ku56XwdwwbZoFUWOfeioSmnpeF4FNaLvWqI
	 a2CSoOaijNn9W9NrQaidDQnorFLNYo6Ba8Kj9roskrFAhM/T4lqfdKFHl0efWBKBCj
	 fd40NMcZvYHAA==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 9CCBD4B5E9;
	Fri, 27 Nov 2026 06:47:47 +0000 (UTC)
From: Dickson Wu via B4 Relay <devnull+dickson.wu.certik.com@kernel.org>
Date: Fri, 27 Nov 2026 06:32:42 +0000
Subject: [PATCH 6.6.y] nfsd: fix possible badness in FREE_STATEID
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
Message-Id: <20261127-so5-nfsd-66-v1-1-2ae77e2e4983@certik.com>
X-B4-Tracking: v=1; b=H4sIAAkkCWsC/02NSw7CMAxEr1J5jUsTUUO5CmKRj0ODUILigkBV7
 04DG5bzNPNmBuESWeDYzFD4GSXmtAa1acCNJl0Yo18z6E6TUnqPkntMQTwSYa/tcHC7QEPnYV3
 cC4f4+tpOQC21bzj/sDzsld1UTbVojTDaYpIbKxJOfsr5hpVv/x5gWT692TfdogAAAA==
X-Change-ID: 20261127-so5-nfsd-66-52b98c4f690d
To: stable@vger.kernel.org
Cc: Olga Kornievskaia <okorniev@redhat.com>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795761161; l=2166;
 i=dickson.wu@certik.com; s=dickson-b4; h=from:subject:message-id;
 bh=jwP/hO3okQ18uwZiBI2Bo8/D+D1SaDtOva3Z/IN1YhA=;
 b=9bTRfHpYoDSJjOyWaPD0dwexwSfC4PlGG26jRbGgfENMnoridzZCe0h7+2kksymHRDJvcx09h
 TaSlYwhEBbsCrcVlHQWAJeLG74lolKxLzaSh4g2O9U6elnyR4jPFcDw
X-Developer-Key: i=dickson.wu@certik.com; a=ed25519;
 pk=fxH7FS4FdojeJSGLJzgKdfO51Rvr4EW30yinj2mc1vg=
X-Endpoint-Received: by B4 Relay for dickson.wu@certik.com/dickson-b4 with
 auth_id=1647
X-Original-From: Dickson Wu <dickson.wu@certik.com>
Reply-To: dickson.wu@certik.com

From: Olga Kornievskaia <okorniev@redhat.com>

commit c88c150a467fcb670a1608e2272beeee3e86df6e upstream.

When multiple FREE_STATEIDs are sent for the same delegation stateid,
it can lead to a possible either use-after-free or counter refcount
underflow errors.

In nfsd4_free_stateid() under the client lock we find a delegation
stateid, however the code drops the lock before calling nfs4_put_stid(),
that allows another FREE_STATE to find the stateid again. The first one
will proceed to then free the stateid which leads to either
use-after-free or decrementing already zeroed counter.

Fixes: 3f29cc82a84c ("nfsd: split sc_status out of sc_type")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Dickson Wu <dickson.wu@certik.com>
---
6.12.y and newer already have this fix.

Tested on v6.6.163:
- x86_64 allmodconfig W=1 build of fs/nfsd/nfs4state.o, base vs
  patched, no new warnings
- under QEMU/KVM, base and patched: mounted a loopback NFSv4.1 export
  and ran open, lock, write, read, close and unlink. FREE_STATEID on a
  revoked delegation wasn't exercised.

The backport and the test runs were prepared with AI coding tools
(OpenAI Codex agents, with review by Claude). I went over the result
before signing off.

fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1087ce23d499..73145f485995 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7037,6 +7037,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (s->sc_type) {
 	case SC_TYPE_DELEG:
 		if (s->sc_status & SC_STATUS_REVOKED) {
+			s->sc_status |= SC_STATUS_CLOSED;
 			spin_unlock(&s->sc_lock);
 			dp = delegstateid(s);
 			list_del_init(&dp->dl_recall_lru);

---
base-commit: e2bb30811e063ce0db964484357973b855b06572
change-id: 20261127-so5-nfsd-66-52b98c4f690d

Best regards,
--  
Dickson Wu <dickson.wu@certik.com>


