Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552578;
	b=B0la0eDSlEDsRd6PENdzSYjdGSOdnZdoQZmjaLFz/j7HQiZZZiVnZvmjyuOJesQylbYc
	 OFbPrcTgc6njHasCwRgTpc9/jQESSVa5yo6OEJXpJFGrI6Wo5RAyzZj7IHJI8IqpRW2JN
	 +aj77Z9RPRefP0MKxrABWxnrbmQFCoJC69xYTmwH8/06SIjIyeYlOYp6UeGIFJzbjGf37
	 qvMCyUp9HNJZH9GzCkWs/v0WQz/iZgDeJZmfEZgaX2ei3Bc7bv/6eM++7Lw9BNdfg/joZ
	 RH3FWGDQJa5nnxzNn+nNCRO3ow2bMzZVZ6f1Ki+dxe+Nbcnr6JPurd1bF1e1SxyGfcQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552578;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=zex3zkPBhFWKfPKx8to+rRp0ONmQ0UbhV0TLwAUCCQA=;
	b=zhmxpROUDFizLoNtXFkB2kRep8HJe2xveFyj8MBIH51TSkguKSu9LXZhbd5UUd9/g+/g
	 4Vr8RuzGZhBMCWBzA81xIKBELaKVbYv0CH07ekiW0EVs33Pjr6QQVWGfvkDWYxBemHug1
	 6KxySeqByzF5HHGsXFRLTSAVfX8k1SMflNcU1NsZR5ZROLjJLgSqO9USj94cDgyCVOgfO
	 prN9sNP8WCM61LphFYe+j4qfsg3isJAAvWjZ0iH30R1QyNp9q2rWpZMzFS5sbHS82Hmgu
	 SMg6awyPXcMoQrscEctDrmeoqHznN6Wwc3M+x93i+MbiQusjj3w6f/yd4A199y11R/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=FGzibVGE;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48EAB606A912;
	Wed, 21 Oct 2026 03:16:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 48EAB606A912
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=FGzibVGE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552576; bh=IORN8HpiFolYxgOFw1dmhLuz4Wix28EOhU1Si/uNADU=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=FGzibVGEM6vyViUIFazPySG2uG8tsGK/AjhYNaRdZIMeE0UoLWBLHPBrYjE/m+AsS
	 fIqlFoy1cyvxvUPqjBlKGxJ0bArq93kq+/ydOLzasGfHT8XdawR7br3nGdhE5Q8bud
	 mN/SGgjIywc2/P1AJpAs4gnVJm9uAkt77egEdLAZA5kPW6rkAmSdlmPzRlUAx30Ycy
	 +LV/g2TewIqtqenS7Z7DLWu3p+Qjw/rT3Yo6/4z7uEiAVzRCsbgZZdHq2llO7uLIT8
	 RV86bA6fRuEVrgBqpAZewvfa2fIXylkY+PbFD0pufO1e028btbYqkF1zHK4vTtGyBV
	 3jnT7USvzsPvA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 7895E8A0938;
	Wed, 21 Oct 2026 05:16:15 +0200 (CEST)
Message-ID: <b6c3e5df169940a45831966c180f27889958e1a7.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 16/41] ecryptfs: hash daemons by kuid_hash()
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
Date: Wed, 21 Oct 2026 05:15:36 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The daemon hash uses from_kuid(&init_user_ns, euid), which puts all UUID
and GUID users into one bucket. Lookups compare the kuid, so this only
costs time; use kuid_hash().

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/ecryptfs/messaging.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ecryptfs/messaging.c b/fs/ecryptfs/messaging.c
index 73c7b8215e..4e2524f786 100644
--- a/fs/ecryptfs/messaging.c
+++ b/fs/ecryptfs/messaging.c
@@ -21,7 +21,7 @@ static struct hlist_head *ecryptfs_daemon_hash;
 DEFINE_MUTEX(ecryptfs_daemon_hash_mux);
 static int ecryptfs_hash_bits;
 #define ecryptfs_current_euid_hash(uid) \
-	hash_long((unsigned long)from_kuid(&init_user_ns, current_euid()), ecryptfs_hash_bits)
+	hash_long((unsigned long)kuid_hash(current_euid()), ecryptfs_hash_bits)
 
 static u32 ecryptfs_msg_counter;
 static struct ecryptfs_msg_ctx *ecryptfs_msg_ctx_arr;
-- 
2.56.0

