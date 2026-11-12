Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456191;
	b=Fop5LnEAYEtlQQB82dMTfbjuG68KWnC77x1KYNrDLSxVIH3797ZCEW8wd1QMWWIlpDcg
	 5iDexXWgkjq0C9SmrkJ8YyApOgDLUjqm/aTpDJ2rHeCWOXOHV5EGU93AFBySs555i/5eb
	 c7NFFeeWdX3NkPKAzzqmw/eaU8Ini9HfLnuHQWbPA4ahZ9G1LZLlMjKJcFRsCctvaM+9k
	 YASERsTU6uwVg5VQATnM411c2Wo20qwhj9QMuHfck5GMMI10Uouk6Q+U+8P05mvOzdLW7
	 kz3xMu8ufBXXufFXcNa99Wg5FihbVGfm54s3pwkx1xCBenOaJtDJFvXBlEX/WUYdkEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456191;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=+12LSUXk7NGhyCeba37j+dP5WKbHsxoYzQf0oAxbPjE=;
	b=YjfP0eblzIOswmVBCXXb8prmiwZJPwnbHzmYoHALkSSYOl15FOgjjpcmYp302FcCZnge
	 qfbxYsifuAvW3YK15SnO+bsMKkjQNKwe3fk/cnWlC67GdtMS5Gu1Hz8tGBp1YnfQ5r9f+
	 3hQnT2N38jLPr5leZjo5Wuzh/nSXMGPP6b7+IUeFd42LrTLGZaCtwp9XImd9i5QFXuF8o
	 nFaaAEruzEDXAqFkgslhE8CjUeTShMl56u4Iq7kSPbGMYjpUOJxRbwfMHM3M9wwg5upk+
	 5PtA7Hj2uZBoNN+qMmpP2UoHBU7aS283EGPnG1PAQy3pjCoJzv7fRAp7xOAnjATvvGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e0WDEJOO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 4D64E606A8A1;
	Thu, 12 Nov 2026 04:03:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e0WDEJOO
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 34A191F00A05;
	Thu, 12 Nov 2026 04:03:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456190;
	bh=+12LSUXk7NGhyCeba37j+dP5WKbHsxoYzQf0oAxbPjE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=e0WDEJOOvMYuKee3jpIkOfuz5p/gYDGo+yN8Nx7f6ofJJDzyhqTmF03OJjzsfbPwM
	 3EXyXzSmvb9OMRMGpPq4g3fMaUvyBAn7JfRw5J3tNtPTC8DVz9rasQ8uMGJXNzdZRZ
	 O9zR8xyR+HpnDKGlsFnHpHrLgpLZ8z/zoMWtxpfdx6tTgHvZNmsBpmHj78bh3mFwd+
	 VMc4G/wQV7bF7llHbMoEp7uJuE09SXgAnGSs+BiT2zhzfujG04SoJMyYQnxdieHuaU
	 bOA36tMVL4gNZGXiINfZKyOTa+aOlBQgt8YJCC7owpCgFtSo10nghUWl2iEv72DALu
	 hqrAwnuhDw9cQ==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>,
	stable@vger.kernel.org
Subject: [PATCH v6 06/13] KEYS: trusted: Update static calls before init
Date: Thu, 12 Nov 2026 06:02:35 +0200
Message-ID: <20261112040242.247168-7-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Given that the static calls are updated only after ->init() returns, an
added trusted key can race with the callback initializations. This can
ultimately lead into null dereference as static_call() is used unchecked.

Address the bug by updating the static calls before invoking ->init(), and
roll back on failure.

Cc: stable@vger.kernel.org # v5.15+
Fixes: 31de287345f4 ("KEYS: trusted: Rollback init_trusted() consistently")
Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 security/keys/trusted-keys/trusted_core.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/security/keys/trusted-keys/trusted_core.c b/security/keys/trusted-keys/trusted_core.c
index 0509d9955f2a..11d7d296d063 100644
--- a/security/keys/trusted-keys/trusted_core.c
+++ b/security/keys/trusted-keys/trusted_core.c
@@ -373,14 +373,19 @@ static int __init init_trusted(void)
 		if (!get_random)
 			get_random = kernel_get_random;
 
+		static_call_update(trusted_key_seal, trusted_key_sources[i].ops->seal);
+		static_call_update(trusted_key_unseal, trusted_key_sources[i].ops->unseal);
+		static_call_update(trusted_key_get_random, get_random);
+		migratable = trusted_key_sources[i].ops->migratable;
+
 		ret = trusted_key_sources[i].ops->init();
 		if (!ret) {
-			static_call_update(trusted_key_seal, trusted_key_sources[i].ops->seal);
-			static_call_update(trusted_key_unseal, trusted_key_sources[i].ops->unseal);
-			static_call_update(trusted_key_get_random, get_random);
-
 			trusted_key_exit = trusted_key_sources[i].ops->exit;
-			migratable = trusted_key_sources[i].ops->migratable;
+		} else {
+			static_call_update(trusted_key_seal, NULL);
+			static_call_update(trusted_key_unseal, NULL);
+			static_call_update(trusted_key_get_random, NULL);
+			migratable = 0;
 		}
 
 		if (!ret || ret != -ENODEV)
-- 
2.47.3

