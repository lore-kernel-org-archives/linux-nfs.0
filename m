Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552649;
	b=14o+IYlccJBrW5vRrBPokgbQmEqr0GEz7olOIxRqzbNbJuZNKjfxiooBQiFzvGjAHnZn
	 OEykgpk9HU35Hpwnh4l/U4SlEYoGUi8vbBtYopNvYLlLMKPR9QZ2DeMq3/zfpvKyVVwSC
	 U11qgAaT8gJXoe7AyaeniCtLJcmWd46zLrzFz4pzAG5qzL8MnGZZfMaWNUM/LZ8sVWyFv
	 PBFO7TiSpBNy9+zuUtpWQS1iOZZxz5BGHgX0xxFeXwHn5fOIORIwACGQIrWfs/8xGhT87
	 MYQLSZXg5wU8R4LVxSILs8uM6kVM6582SBR5onkvYPikT7ESZiYT0d5aNUWPOnXM0wQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552649;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=oRt9qfEi+p8qUULjCKJqlBA1X8SXZXrIxCFrVnW5VVU=;
	b=yHrSOHZtMFQeIuLIH3enQSykIGyNP8SjhaQcE24Z/9s2ki3RFG32ZM8z6q5jLTiYhO2u
	 j/HDwkvPi/GRZktZo9zn5dv3cngNWPNHXIoI7z4i84z040RXqWTljG3JyQDSNQ/aif/wx
	 anpwqALbSjjSt1qkrrJcfbeQiFValvIJ61rV/e7PMGoug8fYPYBXAxfAW3LTKb/U2u9ic
	 XWvwiQYmMtSqDvk8/rRm19lFc04qsHsrTdXiiUnn41po3v640sTU+tD3hq+jK9KoNO6c3
	 2qM3OSA7NfpPIHrHKpIVXhLR0gG9YNAXIpE5AjBEY99flyeC0BQOXwMpsBqi8gPDdxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=R785T3m5;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FC01607989B;
	Wed, 21 Oct 2026 03:17:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4FC01607989B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=R785T3m5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552647; bh=By5SErF411UlG+UD7wAO5DvMmpoYoPV1ixNvax7vY5k=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=R785T3m5bgtSyo9fxe7Yl7YsVN5IjxC8VRMfBOP34MmJEb54/VI8Wrg5YhXPcEnvy
	 UXZeBelZjOmKSqHbJn6lIGTEv0sRKYs+lIok5vbyAiRucG0H/cR8mOC4GCNRWMwJGL
	 CGiHcQcxk7RnMrUloMLC7tUfwx4d8VO6WmKYxKBI9sf4ZLvlpLHgKU3xVlM1FNbrWz
	 K549N0QRaJLSlafOVuDqi7z7jIWbNpkUfreoPdEX2OfiagwTq8uVxC3i+oGyeTPhJ/
	 b3/B63cjG/oxqWVAeDs4Gggk17kQgThfuOF+28PlHClj/csNRzhBwi8cr/uMcpxh5e
	 qVGkAhAGHTBkA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 024278A0904;
	Wed, 21 Oct 2026 05:17:26 +0200 (CEST)
Message-ID: <8bb654a6a07fa2c000a965f72629138eec3f87b1.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 37/41] ovl: allow UUID and GUID owners when the upper
 layer does
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:57 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Changes to an overlay land in its upper layer, so whether the overlay
can store UUID and GUID owners is the upper layer's business: take
SB_I_UID_R over from it. Copy-up of such an owner from a lower layer
into an upper layer without the flag keeps failing with -EOVERFLOW.

This is what a live system with a tmpfs over a read-only image needs
to give files to UUID and GUID users.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/overlayfs/super.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index bd0a3f9039..df1e451019 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -1455,6 +1455,9 @@ static int ovl_fill_super_creds(struct fs_context *fc, struct super_block *sb)
 
 		sb->s_stack_depth = upper_sb->s_stack_depth;
 		sb->s_time_gran = upper_sb->s_time_gran;
+		/* changes land in the upper layer: its kinds of owner */
+		if (upper_sb->s_iflags & SB_I_UID_R)
+			sb->s_iflags |= SB_I_UID_R;
 	}
 	oe = ovl_get_lowerstack(sb, ctx, ofs, layers);
 	err = PTR_ERR(oe);
-- 
2.56.0

