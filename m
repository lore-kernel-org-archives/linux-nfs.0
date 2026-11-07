Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794057344;
	b=QUHveQ1wZsjB+nUlTNHIotUDabKp1AuhLPI2L8DHQ608VlqpbNyrUylTk+Qt4O/hfLsg
	 Zl5q5Vusv3XqArZqS4Nd91zDZ8JdURPKRqvih3Y9n2YO50QkJpp0KQ9F3VTKUgxvvLdG7
	 0msYxH5H61kmAbhrwH3+9jDAZk4HlDFAX276BPKbGGT3OEibRkdkP7lNF32EOmBKpbyIR
	 wIhHL8NQkUqASQ6A14H4fENX0AEbIS2lKfNAPpg+My2UYGQUKUUUIe5CzUk75JWu20eY/
	 sQoKcStf2nHHSc9LBZRvyq/b79n5O26Qz/8ythptPVMoC49yiM/ySpBwmUpdGYpzaYA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794057344;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Z7jZ+M0oFygNY7P+h2LVhxc/2HWt59gTYhBbgn7xubc=;
	b=I33eHYhUop8hT9e4LP2pnsrpah6rGdnB9ckzf6EeBXPlgVgd7N2VIGRXU2jPj6ls/NYy
	 u1qxkv0mYzXdBR8eYc7nZj/vab03CfIBL7q1lHwu2PXMvzGceDRldVibXO+nsDHggXDI1
	 seYlyAyLnu2hLK9fneITvm21//8u9vUCBy6mHvKfJp/rjF5El0cKm0KZkWnSMZWk1jgGC
	 6qRy9HYbrLelSAfo5DTsK2coRxtfJjJ18F53ncSSDQ8+vfqxMAuz4e5EKJX2CAFvYkYSa
	 +1ip6Dsug6dwlluapKOIj68TMLvSq2V2pnuPr62DsruUX8V6SX86/woq0Q/+X4HjP3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SndqNYPE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 6D7B8606A33F;
	Sat,  7 Nov 2026 13:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SndqNYPE
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 5823A1F0089F;
	Sat,  7 Nov 2026 13:15:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794057344;
	bh=Z7jZ+M0oFygNY7P+h2LVhxc/2HWt59gTYhBbgn7xubc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SndqNYPEBMbv5mvXwMMh4adkF6eqhfdZdnrvHVlExxo4xlSI3wUl1chUkvxd0wgU7
	 CG3lLtqZPtsc5RtUbZBf9kgFRQ2Cb1LQCOxbINUhl2ir7a5nM0WhS5zpSiqZfTdgJp
	 qRUuNAHQsLrVHAd2vyisDCEXxKcbrl69UMZrU1tJHDbFdhKCC2Ql5/49ef3uIZGzIr
	 PLQBQsZPbibzb8weN9yQZCOomvN9Hx8KxhV0J1tWlAK3oocFwUz+pU+xa2JmKne8Jx
	 UCEuNknVe1v4zm/dGZ+qTDfhBae79M7jafoOMpTLfWKuj2nBD3KScI2ymp8xKoKPDw
	 OpOyQb6BTN4Mg==
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
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [PATCH v4 06/11] KEYS: trusted: TEE: Disable sysfs bind attributes
Date: Sat,  7 Nov 2026 15:15:07 +0200
Message-ID: <20261107131512.3603168-7-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261107131512.3603168-1-jarkko@kernel.org>
References: <20261107131512.3603168-1-jarkko@kernel.org>
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

Suppress sysfs bind and unbind attributes on trusted_key_driver so that
userspace cannot unbind the driver and unregister key_type_trusted while
the trusted module remains loaded.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 security/keys/trusted-keys/trusted_tee.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/security/keys/trusted-keys/trusted_tee.c b/security/keys/trusted-keys/trusted_tee.c
index 6e465c8bef5e..227efb668aa9 100644
--- a/security/keys/trusted-keys/trusted_tee.c
+++ b/security/keys/trusted-keys/trusted_tee.c
@@ -263,7 +263,8 @@ static struct tee_client_driver trusted_key_driver = {
 	.remove		= trusted_key_remove,
 	.id_table	= trusted_key_id_table,
 	.driver		= {
-		.name		= DRIVER_NAME,
+		.name			= DRIVER_NAME,
+		.suppress_bind_attrs	= true,
 	},
 };
 
-- 
2.47.3

