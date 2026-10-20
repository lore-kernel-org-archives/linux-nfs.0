Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792523395;
	b=Hq3IHiBH/7B1wbGMtnaaNMSKQkoQQtD+0zW+oOc0+Nj1aljbOcAH2PMqtqaQ+E7WwNQX
	 XBRgG9TfcMbUdV0w8PskkptCYiId8Ix5PKxzfqGwUkVqk9Jrj7Y7wEghYDrpKT3sJaUDa
	 zbyUTkX04w+XDsfSyedxyKm98RKVuwYfZjdZoBKFiIL73OqS9azUAVHkwfB9qfMfF27MC
	 1RUKPggYO1KsY/6lTNi1BHRgF3M7D36l0g2eKKLPjmEh30r04p5wO2uOT/Djx8erUH0Sj
	 9Sx+59L4vZdHVsTZn1XqX2ZRaG0d92fM1DI8vSv3d1J47/u1La0tY3wHVAEY4pOtQnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792523395;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ovQlggD95czzIsSuFFFOXTejTXPO0gwu2CoTMYAFg3I=;
	b=YNAS2J0w6cA75OyjiTsRBKDQDXQnPq2IaoobInTO2DzU0XxrAo6EXOZiObUqu84Lmmxk
	 S0GU056rOATBHeNbt8lzKZMA8p7nYp2nj2oI6Gk938WtLvCg99IW3OiCWa92SPvUMVc86
	 ZQpBKYWbbWWO6YAPq3gkwu8M+nb+78Np2h4C8wdB3VsEZts2XZgOYCroKMpbxFdehMXWQ
	 ljEp13pondw7cE8dbzUDfGohHMWRLa5mbCIyVJiXhMm5oc+izpRiuTUUN3XLsIpQldPZV
	 w96/YvXldKTysohIackDs/Bbk3p7ZLl9CF+KbYxaTjGX7sOHl1J8yPXx9r4VhZaz+UA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kI2foLsg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05E03606A31A;
	Tue, 20 Oct 2026 19:09:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kI2foLsg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 56DC31F000CC;
	Tue, 20 Oct 2026 19:09:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792523394;
	bh=ovQlggD95czzIsSuFFFOXTejTXPO0gwu2CoTMYAFg3I=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=kI2foLsgTSi2oRjIn+pQp2BXj5cltiuRUDb0t1B24devT1wip+qLzQ7PGNKkeXfOE
	 1Z7yFYWk/cvjfzl8O5KI64zLictROqeheNNf6I0VjlekIJ/h43CXwSH//4dQwYcxGS
	 JrPGh8o+n4858dEiC7MGOYl74wJIgH37C+ZB7+/KqcKifRa4NkK2ADqTNC2xg9xSDX
	 QAUbm0c6XZd58Is0NAKyY/qIYS87B9ZUv0EpRSLL5L7Nin8wB3lJUFMT+2V8TFgCH5
	 ioma9vkJhTbcVAPHPQMjBdlvnPm27hX8Gy9dL0/gtEs1Gd3jRIN2mXq+uOj5fuBq94
	 h9+b0+w4bBYrQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9A1B9F40066;
	Tue, 20 Oct 2026 15:09:53 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 20 Oct 2026 15:09:53 -0400
X-ME-Sender: <xms:gbzXamUKYcrpjssOOc8DSkfGhDF3WP6CDCm42jwm6Ag_vgpr7Pwb1A>
    <xme:gbzXatb-UmH5Tg9Z1FmjWRODpdsDsGXAocNTRlKA4Mgn2sExwCJ2W-faSAb3NnJk9
    LtDrxQNe1rA0c2DaBEjXF8oaO74NqmpWahY8gLEZzj1waAPOl6aT9As>
X-ME-Proxy-Cause: dmFkZTGKdi/GfMzdxPHGEfvPy1C1gOrwx57H13otpJGvmTnAe20XYgdujii0sMUac7KkMs
    pAFmLHMLuJk8b63/774vYB8yUtnFZCNuxxhZMfMMJ/F0ezeVyJ/O3+82AQmPAUfko69eEy
    hSzRfKmYXuJnYF69XIWfscf4lTCRCwct7WhCfqxjvDEqL4D8UO1lQ/Dd2SGfo2ZKHz4u0A
    DBfl2RVHNlWZPyNmXmLwmLsBUV+b4TGVTMvdFNppJyxguAaigQlcEuxa+U8yymreP00FS3
    L3icWQhoiwgy1iiYPRsIZqYVtSHmqkrKkzwUS06VNSRwLHAQc9LZRpDPYTao+7QlkIx4E7
    IEPiYnAX8QNyXOQyGM5geHPDDdchiLIq88fSBYBCajn/waHMdZVxTNeayoJPEBrBmFvCGu
    Xg3hzfDNvLYPuesntGklFkqXSxew64sW5ZfBU+MMZ4j90R0ZQAeLfvNcTXV/GEAqMu+qR3
    ESp2vCFw5KLX4pYsYVFGyvR1SawUQgfRn02M6hbP36YG7JxEq2wXhu3QlCy6G9hoqpYR39
    9ghgAi5538zAwW0BYtEbFFRM9wmEdAjnD56wgvCYQq5RC76FzqzE3mKs4KuUCauWQzZ0iJ
    L1NCnu1BRYziuEgIZKI1VhyDVBsWV/KNki+DmlnN+O7SLbnwWx6Zd/GorhEQ
X-ME-Proxy: <xmx:gbzXanJisgjiNJBilY8UeCrmHgG-hfDn4Nq1OeNb1iOVLGsUlOYwhw>
    <xmx:gbzXasjtmPfPbqJPsHtRPhjJS2YlkEY2nE2QD3F82GWzx5okwHepRg>
    <xmx:gbzXao-t1RGQPQo8YZTLJ6Xxhw6QP4R5ZiZ5Zf2b8bKp7VuT5xdWRg>
    <xmx:gbzXaooWtJdUWYhyxuqrr07_x_JxRSYZd4DmAXEqqVz3HFpzhsirZA>
    <xmx:gbzXalOey-wvnwk2iTj9kw-EY9uSORXHHrHkQqyv1QHyTcUhAW6Ostxd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6D45F782738; Tue, 20 Oct 2026 15:09:53 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AY0IOz-isJ-R
Date: Tue, 20 Oct 2026 15:09:25 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Donald Hunter" <donald.hunter@gmail.com>,
 "Jakub Kicinski" <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Shuah Khan" <shuah@kernel.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-kselftest@vger.kernel.org
Message-Id: <e776dd28-44c9-42fa-b2c1-fd1491e4c231@slotpi15m67>
In-Reply-To: <20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org>
References: <20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org>
Subject: Re: [PATCH] nfsd: add NFSD_CMD_FILEHANDLE_GET for root filehandle lookup
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Jeff, thanks for the patch. Review findings:

1. The selftest's proc_filehandle() cannot parse the /proc reply.
   write_filehandle() emits the handle via qword_addhex(), which
   prefixes the hex digits with "\x" (net/sunrpc/cache.c), so the
   first hexval() call fails and the function returns -EIO.

2. The new binary is missing from tools/testing/selftests/nfsd/
   .gitignore, unlike the four sibling programs listed there.

3. The yaml doc for maxsize and the kernel-doc claim the handle is
   capped at @maxsize, but the code silently clamps to NFS3_FHSIZE.
   A caller passing 128 gets a 64-byte handle with no error.

4. My sashiko instance here noted that fh_proc_mount() leaves
   self->mnt behind when mount(2) fails after mkdir() succeeds, so
   teardown's rmdir() of the tmpdir fails.

Can you send a v2 that addresses these issues?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
