Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840024;
	b=m0FkGyR9hRzJHhABbkPh7P9bkYSv2x3gByT9w9wpb6DTtMaLcGZl2j0hzyA2gfUCI3YM
	 +IpevdNukS1QrshP17lZEmkmxOWl/c3PydryAaw4cJcKO0muPguKT0TsEEFDeKhaY+/dH
	 PlsMptQ5LULtOKaWu9F4NiYM7rgg2AOf657nbcVPfkcSLiB61ehS0r8iFdHgmfJ7WTjpn
	 C0sKQKiQ5J2LOeLz4YzNRlRQjUuVycd5U1PNkJKpB6rJnTvABjdyOMbovnxiOeMkxd9zF
	 mq6drRMlWepI8NeoIZGSHCl9NtHXjxJlf3lRJj00+k+/Fh1TknYywweEEGjjBm/P8dQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840024;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Z7jZ+M0oFygNY7P+h2LVhxc/2HWt59gTYhBbgn7xubc=;
	b=F7sJ6idIZEEn933st8768vHBs+zSgY3qyKOYDZJMaScD54Gy+epYTrPt75BawjFn6O3x
	 P6h6N3o9BzamWCtNcblBk1JieKkCuJimz+TETRJxShmy2/WB793WwNvDy+UWYH4SJMZV4
	 G81RmEF41hSPOw6yfLJ5IkYqdfl3gRAhgsVYUzNABw2PhVwHKvQBSviisQdDNAOgAdQoM
	 zmla8ALZwO5GPOdjE53t1uF97b5L4/5eTi4HR+aRXV5klKSNrjAVFhOq79CyGzlqPimeV
	 dPHFjyVrUtio1OmO4GxSdXOaSUjxQKyXH0LGw066GnOzY54u7H6CpiUS07EJ7+dom6Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=exTfoei9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id E2247606EEB0;
	Thu,  5 Nov 2026 00:53:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=exTfoei9
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id C55AE1F00A17;
	Thu,  5 Nov 2026 00:53:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840023;
	bh=Z7jZ+M0oFygNY7P+h2LVhxc/2HWt59gTYhBbgn7xubc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=exTfoei9d7BgOGQb7Hfw71Xw8mCLmhdklyveM/TYAjl9PLLS++Pww2jAq2Ic5m9Pr
	 a7iCjfRw2zIsRM0uYbigGxgJY/QgJEbesmV0/5soZwHwu7l62rIIQPbWOLjQlu95Yu
	 gYYN3X8GDctITK7h7CoiXOF3w5Z2mACGmWz4XRrvEXWAy8bRkfmG837u8O2lFFhZ3p
	 xwuVVUsI6FYQhyT1XSxAfQ2mPMSy6qZcxdALvVH6xolUmhr/jrC+4Gz2wciUyj7h0C
	 aDRcCdRzMZ++9vvSEhKIEs8xntiWyAVi+ymjRrBQqP5YzG5wtO0GDPm43i2f2P7hjw
	 e9E6EWerZm6lw==
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
	samba-technical@lists.samba.org,
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
Subject: [RFC PATCH v3 06/11] KEYS: trusted: TEE: Disable sysfs bind attributes
Date: Thu,  5 Nov 2026 02:53:05 +0200
Message-ID: <20261105005311.804098-7-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
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

