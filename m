Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840696;
	b=kRZOrBMW9JMIAd5IZdjEpQHbEAtCS6EU0Ee84ljwSOeGIA5/ilieJ018NVpb/0ZfUAsT
	 GUzReFzRoGLAG/IRfcdNo8c796iIya4FxXtq8jFh9WP0pwFT/mOBq2b0GGw9nPyGfLHTv
	 VKCIE14Qo525+We32A5jib5gpQDFwJl/mSJGk3zPjNnV6jgIP1xwp6YLod77uDTab0IAG
	 /kckm81mzN7z0WWKf0zQrG5VECM6nsu5otj/NOlKTtTPOPmlDmIjBgkiST8chyQ+kpFPS
	 vOGbeHMwHlV39aC970acA50g9in6ow72QK4s93v+t0339OeppQwUZl8wfn9Gu8JL2aw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840696;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=vbOSiDhOXUNUobJKPavDdEMcKzCZkS+5o8EgPhWPvSM=;
	b=J6lEkPz2XIaZaMQKpmsLgkaQK8BkUIWoHoXfGt1soINL9st1zxJ2feIXFWzC1yRnzQ6s
	 b5JjqH7icHXrZ9lMwhLpfS57ofPq2gLG3lABbtjmxbPY4WNPeS2FBlJ8oAIF39RuTbfyR
	 NWF+DAFW9xSA67Ch00mYpYxmKxRW4BFUgimVpWIvDSBR/qTe+m5opVmUYvq+brK2XMzcl
	 sr8aXRg45R0wAI/BUYdWDCsWHYXRbdonZGGvYaVJp3ZgJG+yujlCf31Y7sD/tpADdWA03
	 4AkZAgI9KwVb2q0C1Hc9xJ0u6Vq8yI1g3EYqILPXfBvWQ13JoPlUxWF9Gq6cv6v8LiA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m0HcvLYM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id A83A2606A333;
	Thu,  5 Nov 2026 01:04:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m0HcvLYM
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 9CBFF1F0093A;
	Thu,  5 Nov 2026 01:04:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840695;
	bh=vbOSiDhOXUNUobJKPavDdEMcKzCZkS+5o8EgPhWPvSM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=m0HcvLYMYkaoJF/gyIeviUk7vKDG8LTeM8GuuNUPrh2+PwPwMJg+KMAmLfie04lgC
	 uWiY1m196LFoEPr4UN4ILRCQTYO2qpihIQA73wRtKJP8bFtmoCsmNsC1vPneuxMySZ
	 Ydury5Fz95YrhAwGRTsW9IaxkAyYp0+eCGdLrKyYlb0kLOIfNmyUFV2qUWZ0rhXkPe
	 0lrkYKGcQE6OgI2K9JypGhcV9aAwBy6qS3gU7t0+e+TarrhTm4FBRyHwvM1/KlS8YK
	 WqqFgSJMDgdhOLXDZOYkDvGyJFfth79kqcDkB0Cg7V9N3Ac8qewmwBukARuOwjjYyP
	 a65Ed+F9uQSLg==
Date: Thu, 5 Nov 2026 03:04:51 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, samba-technical@lists.samba.org,
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
Subject: Re: [RFC PATCH v3 00/11] KEYS: Sanitize the garbage collector
Message-ID: <auvWM6zn1MSP5C5b@kernel.org>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>

On Thu, Nov 05, 2026 at 02:52:59AM +0200, Jarkko Sakkinen wrote:
> 1. Replace key_type_dead retyping with module reference pinning so live
>    keys and restrictions keep their backing key_type module loaded until
>    key_gc_unused_keys() or keyring_destroy() completes.
> 2. Process serial-tree scans and graveyard destruction in fixed 64-key
>    chunks to a bound workqueue execution latency without hurting overall
>    throughput for a significant amount.
> 
> The first part has a user-space visible effect: rmmod returns -EBUSY while
> keys or keyring restrictions still pin the backing module.
> 
> Internal key caches or transport state bottlenecks are addressed by either
> clearing their private caches on last-client teardown or splitting key
> types into dedicated provider modules.

<samba-technical@lists.samba.org>: host
    lists-mx.samba.org[2a01:4f8:192:486::1:0] said: 550-Please subscribe the
    address jarkko@kernel.org to the samba-technical 550-mailing list before
    posting. See <https://lists.samba.org/mailman/listinfo/samba-technical>.
    550-You can also write a mail to samba-technical-owner@lists.samba.org and
    ask 550 to get on the list of accepted non-members to be able to send mail
    here. (in reply to end of DATA command)

This was accidentally pulled by:

	./scripts/get_maintainer.pl \
		--nogit \
		--nogit-fallback \
		--norolestats v3-00?[1-9]-*.patch | \
		awk '{print "Cc: " $0}' | \
		sed -i '/^Subject:/r /dev/stdin' v3-0000-cover-letter.patch

I'll address this in the next version but perhaps that email should be
removed from MAINTAINERS? 

Br, Jarkko
