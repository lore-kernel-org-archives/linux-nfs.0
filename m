Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552572;
	b=RFxasV+pvufpiYWbohdoxp4txfXa8EYgSxN1ms9JdlGRWdoylLCGcozlzmqQzKxtTrvB
	 fS3UoIS5U6fYhdPyBtBEdT1xgHabLc+EcyjXaxh6Eo5OnxHpD/+2kFHk7WEG6LpIRo/wD
	 U0F45QK1FLGX8xrUQE9ashP9VcfBU4ktwzOYRrCDwp9YM3Jxr9pWyARFpgPCbCvt/BZOz
	 mSwhTTSQevwMjV2UzkZj+DmoaW/H6MUFf/cOznV3aZ+lZcU7NNYhi658H3yaRQs96k/hS
	 Sw8mT8RPhryq5QsApaUYMp8X+C/vdsLc2ABxcl/q7/oyxpmhMLumKf2XyKW2e6Nf4Lg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552572;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=UPUH03U6Oabgaw9Qqnvvk6Mc/Q2z5xz5SUzWvs/+Al4=;
	b=EwnNVHk+gjoAaryj6uywwvhSlHQlclFkFc2IvxODpfQ1c3rZFCWt5DV2jW6Ya3WyN+y8
	 x0sJA1KqPjjblWiSmFoV9YKUtKicBExSpJpzD4AicCXbwMbTqqZgPsX/B0LpRNhFdESKh
	 yiFOLLafjj4ak50EL3pBDfdQD35q0CFqItmF8KGD6cTM6yY0dgd9HEY3P0rdSVnDeYtYJ
	 QO6pJ52uTs8FUEa0eAvb9L1tYzYJbcusEkr8Xo7IpkAm82AMHwJwyAmVwzaruBjUkak/r
	 KRaGzlMoOkQ1EJl1t1Cr4cp7NklyfrAAz6nV/mK9jJSVJyNhc1Zh2MS48iuercCOJ+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C7mvnSm6;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 682B2606B558;
	Wed, 21 Oct 2026 03:16:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 682B2606B558
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C7mvnSm6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552569; bh=gzbOefoC556RIfcul7jBVCLRyUZiYNXLUGDOS94vR1g=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=C7mvnSm6jg0A+SyE9a9O+BkYpGvEjGYeBIZ7edK6j03DBVQg9JU91qj9+ToeAtI6R
	 vYkPrhPVxZnZWd3UA0A3iD2k91OvNQpHOc7WhcszRclmL7btxh/pZbHxietrULDbtA
	 i96s50gIcWKD2ep6y7Z4tD36cndcFk5LrGhxBuCUN/07qXmfZSNDjnVqW3E8MfGX2U
	 jcyxBqeHSEVCQHAMRmVd+cihxhXVdXpgNtr0RGeQqZ821zUy7JdPIXz9hfPVqe72FA
	 akg7FQWtu4IUGDvDnk1Z3n198NlnOawpQQL1NgC2KGHY6HI34hFnv9iv7LMQ++uc5L
	 vjcPugG1tY97g==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 98C978A08F4;
	Wed, 21 Oct 2026 05:16:08 +0200 (CEST)
Message-ID: <88afe10ca34a89b9a0776752d6583cda3cdf747c.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 14/41] nfsd: don't hand out uid 0 for read layouts of
 UUID-owned files
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
Date: Wed, 21 Oct 2026 05:15:34 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Read-only flexfile layout segments use the owner's uid plus one, so the
client gets no write access on the data server. For a UUID or GUID
owner from_kuid() is -1 and the "plus one" makes it 0, root. Use the
overflow uid for them instead.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/nfsd/flexfilelayout.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index 6d531285ab..f459d2c1c1 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -51,7 +51,11 @@ nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode,
 
 	/* Do not allow a IOMODE_READ segment to have write pemissions */
 	if (seg->iomode == IOMODE_READ) {
-		u = from_kuid(&init_user_ns, inode->i_uid) + 1;
+		/* any uid but the owner's; a UUID or GUID has no "+ 1" */
+		if (uid_is_legacy(inode->i_uid))
+			u = from_kuid(&init_user_ns, inode->i_uid) + 1;
+		else
+			u = overflowuid;
 		fl->uid = make_kuid(&init_user_ns, u);
 	} else
 		fl->uid = inode->i_uid;
-- 
2.56.0

