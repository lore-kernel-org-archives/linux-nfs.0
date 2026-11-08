Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176875;
	b=swDhdZFJxH9Xlnp7JNBp2WNn9LcvGl9nT41F5MG6IYhvCHDFDB02+on2T0ZOVlh3e0oW
	 7S3ifJ9U+kiUkjL0Lah/1iObirGDjSuS4b1JS10sbC/nWg1w8Aii1Z9W7d6/AQtUQ6bvx
	 I0bQppD68SJsNCuLeJ85PNscNsGgD8bCHhj1ZZrjDLoxc4pi+Hv18Xyv+F4FtGK6CSqXw
	 zpCYZddHaICtmep/6u2tEH6c1ICpmRe78fQ1RevIDq7FoEJHxWoKUveMfOvG5L9559UO/
	 o9lHjjMc2prY7HfYB1poX5UiLqemHIpyJRBVVJzdyPg4VD2sqxhhN5KPbXPZnhw4T/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176875;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=c8QBGr1yE6MKO7128lCzkFcPbJ/myyIRf4OSZLFtjRI=;
	b=d1jCqkLXBNHQTvbYNpxo3BuwvSPbG6dxb0JMDJ+HfDEqSsKijfoUT28BOn7B07SwiYra
	 CdJUEQ1/552DOozbWf+SIVZFuKN99eGMHH0sQ51kG24gMZWi5wAl+w1NMh3pyO1fDnGmi
	 BLGx85O5EsgLKuX4wpGZ6IohmAtrJvz5m9vWXzkKmwCHSaHlTkhW0dY1FXff22Tf5HIr2
	 JkYylSbbCqTY7/mVIEr8TZDh3eapTs/lcUQbAOP92Vz1Vvd77q4Pt2vZFIAbbI+r7Rg7V
	 dRXpBPmz9lMxx+FxQf3nTzXBh2HgW3q0Ds0b1rcRXkNcdYaSDkGXtefMQgBc1bovhlQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Jdu3+wtZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id BB731606D839;
	Sun,  8 Nov 2026 22:27:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Jdu3+wtZ
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 8AACE1F008A2;
	Sun,  8 Nov 2026 22:27:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176874;
	bh=c8QBGr1yE6MKO7128lCzkFcPbJ/myyIRf4OSZLFtjRI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jdu3+wtZipXmwcBOiBA0negJi0bvNfj6sWJuAU8IG3LBGMZcIeTCsnrygWQ2gQTca
	 iTO8jh6JqkRJmbDfM9m6ROf2oGmhtxfcchWvUJkZwsruDnUUP4pSQ3IkPtXZtc5nkX
	 iij8W9RHfRoRMWrmCfXGfKIaNYLcbawuRM9N8fFsIA6uEGMKZvj7nyrIOYLtjVK4Yh
	 MR/iMeEkYTmisfC/prps3ury+HfxF2zPZG8wCODyYgimSe9w+g6nr7gpxw+MTG4FwN
	 Wp2HuscCErLIpL6ju6u+dMmpEPmnrBZ9Ri1sleIVr4sU+qztV4Qebz9eknS+HJ9YKv
	 FD4MPCPoSjv3Q==
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
Subject: [PATCH v5 07/12] KEYS: trusted: TEE: Disable sysfs bind attributes
Date: Mon,  9 Nov 2026 00:27:13 +0200
Message-ID: <20261108222719.304712-8-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261108222719.304712-1-jarkko@kernel.org>
References: <20261108222719.304712-1-jarkko@kernel.org>
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
index ad9c7baddcef..87ea549f7f0b 100644
--- a/security/keys/trusted-keys/trusted_tee.c
+++ b/security/keys/trusted-keys/trusted_tee.c
@@ -307,7 +307,8 @@ static struct tee_client_driver trusted_key_driver = {
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

