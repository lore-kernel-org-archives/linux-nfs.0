Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552653;
	b=PjmE3nMKeeC0Hhpz4ZUmhmg6ZYl46fHXhyitaEPmAmQAVkf1KuMPctHKUkjQlCz9encZ
	 ckNuWwX24238M8jKc8v1RLCGiZvZvSnXt3n/XnJ6Q7tNcflrAlvV5E5aF/7brHDKD5S1x
	 dky/BaFG49HJttIaLJ/B968aeLJEsc6rfoFyFQtlT9tujdv/KLYR82z7jQdR1icBRTCPg
	 8tUB/kn8PhLD3oaCK8id9uXXbLCqqp72pvfkhmUvfsPnzdL693KeTiuC/6PGjZKdQ7RAv
	 4DnpxSJSOaG/vGLza29flxLERnc8ECtzhYnJ6O+6qm/qCrOrBp30tUiT2Ft7YBavtig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552653;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=3m01pLNDTW9aw9k0lEKmb3B4hZCMEg4WI0a06fRx8PE=;
	b=iPNoFpscZwT4+Z4IjG7s+Lhm5WpEe0oujhHdIsBkoV4o2K00Xo5eA3+n9PhOzR6JBIA9
	 OB1xtnq3Z7Y0HwxSo57sfOMbFDmWGLwlaH/CBl3tpKt5WcfKBCA9TaWyBRufg8IUDhKgM
	 476nkt79cZ0Y+XZoikO4XsZauhANXU5VfcmYuTgo94j2V9dam8VanANU/q9YsZQHbxXai
	 0N1MlXqpZVsrGb0QrYvuAWXSZ1fXcJW9Ic5OnyPIeZ/by+Hasg3XrjfbbG/7plCbKRvdU
	 nbaFOxvQy0sej5sobXvd4BmunvtfSWqiuJc/mISPrN74vkc5YqXvQwLeykqFQPgbNIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=k2jP8E1J;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C75D8607A41C;
	Wed, 21 Oct 2026 03:17:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C75D8607A41C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=k2jP8E1J
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552650; bh=BGBE1F78F9m6wB+fKLmjZdC/MpiTTSaq0q8LTJ1vf6k=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=k2jP8E1J0U1dFSue1OTXG+4lHVU/E9/zexo0IbPd048+BJwSLrlmsvOdsS/wmksHH
	 5qyVEvTa/J52NDiGIeDzBmhSBdsTfdVm6Tn+oygZ5EngesJuDF4D12REJyzuqx1lSv
	 MBLC3GP+KV2YmYuYTZolCeV468jBsEgPVfkbp+O0Ug9X+rYBnUrar32JVCqsRA5Tv0
	 IZsKHGN6ab1X3g0qQzjSdIk1WO9gB8Lf/mAmX3KcGvI9YmOSqMwUqz2pEkOYOUtGP/
	 EJ8enWVLKA/4PmEX8EqepxxVG6yN3HfAsxu3O2xduxOblYrjtl+xaHV9b5SXELEcDF
	 nWEOHo1UYaBHQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 19A918A090C;
	Wed, 21 Oct 2026 05:17:30 +0200 (CEST)
Message-ID: <0c3bae750fb443d5207a30a2e32a47a724bca5cb.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 38/41] devpts: allow UUID and GUID owners
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
Date: Wed, 21 Oct 2026 05:15:58 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Terminals are given to the user of a login session: sshd and login
chown the slave to the user, and a pty opened by a UUID or GUID user
gets that user as its owner. devpts keeps owners in its inodes only,
so like tmpfs and ramfs it can hold any kind of owner: set SB_I_UID_R.

Without it, sshd's chown() of the pty of a UUID user fails with
-EOVERFLOW and the session is closed.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/devpts/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 9844dcf354..1bdda468d7 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -363,6 +363,8 @@ static int devpts_fill_super(struct super_block *s, struct fs_context *fc)
 	struct inode *inode;
 
 	s->s_iflags &= ~SB_I_NODEV;
+	/* owners live in memory only, a UUID or GUID one as well */
+	s->s_iflags |= SB_I_UID_R;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
 	s->s_magic = DEVPTS_SUPER_MAGIC;
-- 
2.56.0

