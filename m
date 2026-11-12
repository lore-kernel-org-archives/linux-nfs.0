Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456199;
	b=Ccq+gyPyEjbdQKtvLj+8qGciAX8rcBiM4f/8dQ6M/b2vbuU7ADKrk36D9A/oGmnOQ22X
	 634QNilsf1rsknMOk66M9HAgITjTsDSMq6axzAAbU49RjKNKYJgtYa+Ax74L3MavsmBIE
	 xqtK+vTtkq4833caRzFvii3/IApqervcGtLU+Cz9HAn3JtkEcHOe9GlFm9adrZ2se8zcP
	 XfR9QW7CfyQuVlysW6mkhyG8TB8h4WB+39BGpRlP7hvGmBObma91HJ9C3Cli3g7kpOItI
	 p8xTh2SrWua6XPeyAssjIZvGyubhE3LfIreOIX0FLzuV4c0b143OObypWaAIlOr/7fA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456199;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=vAmBbl7y3+0vszpC7NISqKzYEAyqcXpf8J2UpgCfaS4=;
	b=RX3Py4HOzvCVNCxuUvPRDAqDBjYzPzP5KKiYnLzW8gzNGyU2KJLhSj5AIk7IxWGA1YDY
	 s32EpdN8igk7hWfqMhe5n3tCL9TmFr7527Q5MDyM5me35RKwE8IxKb9u+ulJGq2LglX8r
	 GtIzp6DgchonBbO0WgEM9/tqm6jhu7yvMulZEVW1aa6lkcXsMHFS8DHQdKDnSlsBwGwDY
	 imyrTDG3BNPYdOzuQObKUp0g8WjUJmWoMqe+B+ikNhNq4M4LN/vLAl8icVLKisbUjpk2x
	 mlQ+Z5rmC2cQExPJTn8anj40+jn/vJITxeuCWc9mrphfd02yLUFFaRdPHpfxFOD4fUQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BQLnhOyc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id EB30060A5BEB;
	Thu, 12 Nov 2026 04:03:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BQLnhOyc
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id D7DB01F00A05;
	Thu, 12 Nov 2026 04:03:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456198;
	bh=vAmBbl7y3+0vszpC7NISqKzYEAyqcXpf8J2UpgCfaS4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BQLnhOycQhF7tDbiFeh2T7Wry+wOBuzza3/3y86KSqOFPmZhYDfFSSxOEplDDs4eA
	 0t+bvoCdhkvxyMqzC9g7svnN8QXOIVHuMBgyYzvfRu0Sx7NhVaUzGpCOFBPg9IXAfK
	 GRAwwHMXCmzY+6UT2dim6yMiH5Za1ukCfyRFvOQwIu7b3W1mAuryDcb8Dg8MI0gKui
	 J1wQt0z9mQ+29PcZXEsJfPOHBQcusJCQcbj4fijZUrXL0yQQb5ygpkaGA3QMKoo/oj
	 oSX+Tg/TdaAzObKCn3Sxwbwt30fYU5PNQVZKw+StxpvjNtjKklt85CJbqxnO4I5CBP
	 autlx9MYAIqyQ==
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
	Sumit Garg <sumit.garg@oss.qualcomm.com>
Subject: [PATCH v6 08/13] KEYS: trusted: TEE: Disable sysfs bind attributes
Date: Thu, 12 Nov 2026 06:02:37 +0200
Message-ID: <20261112040242.247168-9-jarkko@kernel.org>
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

Suppress sysfs bind and unbind attributes on trusted_key_driver so that
userspace cannot unbind the driver and unregister key_type_trusted while
the trusted module remains loaded.

Reviewed-by: Sumit Garg <sumit.garg@oss.qualcomm.com>
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

