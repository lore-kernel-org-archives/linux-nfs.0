Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E8C33BE17F
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280669; cv=none; b=LJo2cpdOTj3tJd0BHDPWvpZkI08CGid7ryQOus+IEbRXtJH8HFxsTu2P2EORjqe6NKhUlrtAN74uwA+yNOCpvwWs6MKVmcXNKOHO8gmavBKZ6s4LLf7pbKntblAepHIkLTJE/V4n2QrrbEqh8pDgcn1ll0xuYVHBpqXAb979WZY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280669; c=relaxed/simple;
	bh=x+SiEbaSOQK1Q2XS1vOljd65NgCyEZt7dIMc+5s38UQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AFRD/ePgByM0AQBv9Q2gEuhK2OJMcDPvg/a1NbtKYgleQo054RZAaahU3F/YkofVleoHaA4QcATa4Qj1fXoWqxzUMjVXuKSmfhS7V522An9zPbgrA9wwfZXzwGoQFFpZdQN21XYLPiFkmdJ4SrpyPn8v1pQlHAkVB5dCWq1JsdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bOg38Udi; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=QLipBfmJ; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bOg38Udi";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="QLipBfmJ"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.phl.internal (Postfix) with ESMTP id 9EC79EC00F4;
	Fri, 17 Jul 2026 05:31:07 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Fri, 17 Jul 2026 05:31:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280667;
	 x=1784367067; bh=SbBQK6cYjstdW/ttdwKi9dQ7z6gOS+bACEIlfxQCuiY=; b=
	bOg38Udikhcy3d0tHlMvrk9vO0CeeGAU/N8XILxJTYTmRzy3d0aoFLGjcOxXWhmC
	lkcYWAI4PBwXBBzkAR16C7FRbKD3hNbx7BSCTiW4tuntzAMX0x7MqF4IS2mrK+zS
	/bB1opdUm6Hp5fQ3lsdFyIx+F3Kvwc0RmPKSveNTcM3nsPASZqkBvjDh+HH96cex
	oVGAdTUWY958r4RBcuJnnfyIMsump9SYCInu42uAvNO0ZuCev51YKL+BClmfB/db
	XSdIfw2pACP0Ggz0bTlCFiwWvMAPr4t8rDO8k0jD5NTQy/SxJeudp9nFLaU3oPZx
	W48JiRnrDEDOqeuQORWDZA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280667; x=1784367067; bh=S
	bBQK6cYjstdW/ttdwKi9dQ7z6gOS+bACEIlfxQCuiY=; b=QLipBfmJh3xprnilZ
	BctZxEnMaVLv84IHZdc//yTaokVJB4OLHAhA+JHvi6i8K4KgzxBRPxT7gJyWc3jG
	5f3a5+rapb3/t/Se6cbW0vDjqVNdUVkKd04yBSOP/+ZLnuVc3QMfwekukz12HKVK
	RkFCm0iNj+dc8OM9AHVVP2uiG6zO3WuHGw/oKCLPXj3v0pq/b4XXaiorfMH8WGM4
	qnGeqjdVKCHE3ersnzNGiZ94yVlyA2Ou5WVIthaENbLIb2cXsAYiolDa3V6759O/
	c769RrbgnUeohX3NJxWEpoiBnBbHDEtlrn5b5gM2Zc7aGcCXumdJWBzH6CGhmzHb
	xpFTw==
X-ME-Sender: <xms:W_ZZapHA0MLBBlGXFKjWw3cAS5zjnc2V6yxhcSA4UT_P5nUnq65zVQ>
    <xme:W_ZZaiCFAbvXhBLsviEAKKpVhpaS4fOi9EBoEC7LrP6pu7fQRub9VnpLik6-eg9rj
    AO5a8nE5Zox9znQBNaU07jE4bj9YTLNXzLCWohdHBaDeGA5Mg>
X-ME-Received: <xmr:W_ZZak_Jg79vDW-3ztOIQ7a6_5QMv-8En8m2A9smZiSK7Zn4df0jaMqEcvLhbM8VMmSRENnLVE6AQiQTATY2wWd86gcOwBM>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaagger
    YSLm1GUuJLTDyvg++cijxLbs+Q0NxNMANruKvX24VnBdv4rQFCJRQW1FXxCYSILl2P31CS
    2ouCCyBtvRHDZCxlghJeqKAPEmUo6KQbKSMecrkJgK7vTIEhPBfJ8cvPCjgqFVle3seRSN
    aqTBY2vn+h1gOyuDKsAucvY7wU6BpU7QOMnnejd/7NTlvbPBl6khf+rJjNBA9J61GBpQXn
    YnvIlIFfU0ZRHa9HOeNbPHRn4CsJ6D4C5C1t8LsypUYgZWyYBfld9cYd+ghA+kmUJApnu6
    piRUr/WZWKJgoQ7ajpKr3a8SuoeXW22CZvghxIsxEmb9f2pIgf9dotinQfag
X-ME-Proxy: <xmx:W_ZZamAgu-wkLfvBMlq3pgWXESJbF5JGQ9c1NZz8igr38hAbu8KkcA>
    <xmx:W_ZZahTYuGlBQeXpAj-IGGqC7pZYALqg5PNnUBdlZ6dLQxh97OlfJQ>
    <xmx:W_ZZalsXdi8ikN4CQmsRKDCdzJ12T91jL5qaeiyflGassVazWxCp0g>
    <xmx:W_ZZal0qMM5P-3lomo9mNYJz2Xw7S2Bxn_MygDUtFyXIx1sfXYrPyQ>
    <xmx:W_ZZaumQRwlegEL0BCSo-Q8UhF9I1XvVqtTitV_ubDjVQCHQ_C8H-MDA>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:05 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 12/18] nfsd: reduce range of directory lock in nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:28:00 +1000
Message-ID: <20260717093001.1972119-13-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

We only need to hold the lock taken by start_creating() until the create
has been attempted.  Holding for longer can serve no purpose.

The lock is currently held across the setattr call.  This might be the
intent but it serves no purpose.  Holding the lock prevents the name
from being removed or renamed, but it doesn't prevent a GETATTR or a
racing SETATTR or an OPEN.

Calling end_creating() puts the reference to 'child', but we can still
use the reference that was stored in open->op_filp.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0b3b358679f3..c04a021d9719 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -366,7 +366,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (d_really_is_positive(child)) {
 		/*
 		 * open the file so that we consistently have a valid
-		 * op_filp.
+		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
 		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
 				    .dentry = child,
@@ -400,9 +400,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (status == nfs_ok)
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	end_creating(child);
 	if (status != nfs_ok)
 		goto out;
 
+	child = open->op_filp->f_path.dentry;
+
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
 		goto out;
@@ -452,7 +455,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (attrs.na_paclerr)
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
-	end_creating(child);
 	if (!want_write_err)
 		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
-- 
2.50.0.107.gf914562f5916.dirty

