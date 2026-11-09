Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794209284;
	b=4B842iDKTT8mxjmohdaEhAppYqyzqlLmPDQ5hjHj0rX/C7pMQ3jA2Tt1v/DNRcgJ/iU2
	 yk28XkQOHvJnuRTuY/bdmhl8cYaWYu6D/UvJTiUeZ/ch5Hgp8cNt5Z+rXse5+nXJfvPhe
	 ZixteDBez5dLQQdKkv3/UyjCswFZFOza7UJo6jFQAdoukJsdeByKIAEIkbE8Zocm6vldF
	 eagaMMhS4ertqrwwezkUNd1sLd5e/BdHzuapJRHLN97NzzdSkxJG2t6bN7uZ8ieFHQSxR
	 7yHVk52omRy9vt9HGmLVCEodqkbeAt9v6jgmrFYYUk5L/EG9WJKUEy1jpytrQjvXVbw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794209284;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=T5QgdGNgqnMVUbMTI60seCLCcrDZA8Ko+QKTakRy5p8=;
	b=p0y3F3QYQ+7T+OS/giiXOeQrwj7pSQNyt8fZe+GDFKH47CWFzpOozV1Ur90RSgwRAiO/
	 b8c01e63sWlyPtbUXk/Ckx4knlykX58cKMe45yzc6AZPvvo/HOiAKnAebWKfV4jO4lP0m
	 enG+P2k+bBVNal96g3ryvMjBhATQRjlRLjwMfV0K0PR1q9L1Dj2sCiUA2Rp2ZniDvMMkJ
	 jG088d5gE78F24wC38cqGQnk93o9Z+Ue/ycyioBlyQ34NWV4j0Tard02V5AzHCzJR6K9H
	 Ah7z3wYeDa5fRBGkrgYKxuLmjPYnV0n3UCkxasVgiyxFKF9MeYaYXfhwGNwMa/611XQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=foKZDl0J;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 353F4606A31C;
	Mon,  9 Nov 2026 07:28:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=foKZDl0J
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79B711F008A3;
	Mon,  9 Nov 2026 07:27:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794209283;
	bh=T5QgdGNgqnMVUbMTI60seCLCcrDZA8Ko+QKTakRy5p8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=foKZDl0JS+GLSY7RALXTp0etUmcbkgEl0ar9X+SRbaTdHa8YE0iHdGvFzm6SeA/r1
	 wvZ9cPLNXiNmGfiqlXOJ/lggnzSI7y+Yt/271JaptvzKD+K5OOp3A1fglQT3Bq5rGx
	 NvR3jpFPpeSxFCvfgBCnkRgPfL2HtmjoU3FFyVNmDn7RdFBmZrzXh8JobfVZPnNqKa
	 7GEjwVODoyk/Mbri9tCR/cSztZr9X+cSjg/FsjjrdXNhoEzjAcJpARwcmKIeSM+9a4
	 qasdmnjKY2jmphh7AMkodKEFCArMimB+U1Opsd/btO0L5R0U6upXj9ZVGBN3OKjtfC
	 EBc5InZvQFz0g==
Date: Mon, 9 Nov 2026 12:57:49 +0530
From: Sumit Garg <sumit.garg@kernel.org>
To: Jarkko Sakkinen <jarkko@kernel.org>
Cc: David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>, Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: Re: [PATCH v5 07/12] KEYS: trusted: TEE: Disable sysfs bind
 attributes
Message-ID: <avF19RckYZWu_3FD@sumit-xelite>
References: <20261108222719.304712-1-jarkko@kernel.org>
 <20261108222719.304712-8-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20261108222719.304712-8-jarkko@kernel.org>

On Mon, 09 Nov 2026 at 00:27:13 +0200, Jarkko Sakkinen wrote:
>Suppress sysfs bind and unbind attributes on trusted_key_driver so that
>userspace cannot unbind the driver and unregister key_type_trusted while
>the trusted module remains loaded.
>
>Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
>---
> security/keys/trusted-keys/trusted_tee.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>

Sounds reasonable to me, FWIW:

Reviewed-by: Sumit Garg <sumit.garg@oss.qualcomm.com>

-Sumit

>diff --git a/security/keys/trusted-keys/trusted_tee.c b/security/keys/trusted-keys/trusted_tee.c
>index ad9c7baddcef..87ea549f7f0b 100644
>--- a/security/keys/trusted-keys/trusted_tee.c
>+++ b/security/keys/trusted-keys/trusted_tee.c
>@@ -307,7 +307,8 @@ static struct tee_client_driver trusted_key_driver = {
> 	.remove		= trusted_key_remove,
> 	.id_table	= trusted_key_id_table,
> 	.driver		= {
>-		.name		= DRIVER_NAME,
>+		.name			= DRIVER_NAME,
>+		.suppress_bind_attrs	= true,
> 	},
> };
>
>-- 
>2.47.3
>
