Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794664330;
	b=WO/CemhhTjDpIaoaNY2ZX17FJjxhviuD9pUgk43c4b+numLQbOWEnZIGNMgZ1HJEjSFJ
	 7NiZ5eInHc9QWY6RNHameBDqdVGb1V4/UTWA0pAqvZTWgYt1FsYXtQrgsX6XwGwCUQ+6j
	 eNu5BZ3w/RGpOnUNi+FLxkkIc9JSpbYsF87ZoE3fG4ye9R3VQ5xngzyXjBLBwX08JqXUD
	 6fk36GHxGTAhgeEj5iPS+2gMvfD80KYqz+qmVy5SU0YN8RQxWPlO+SlVXqUv/s1eEFsr+
	 pWVAv9YijG2FH10wOp3ZACIVJRUauavXsfK317rUbBsWxaD3otp/LejFkM6JuBz3GPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794664330;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=tHza3z4s45pIJ2GPKijovhB9sBTc830I4fCUe8B5OBU=;
	b=n770sLUog9QDJoyM7EI10Y/+QIyOeGPoZc9lZUdY6u+6tdozV9gVQnfhB3wrKTp+fhSZ
	 ugabrTXrQxp2/hb9xjg+H8mLlJ0cPyYsaEm+QL7r1rRSRe5FWKAmD0XVJOMrNLBmLh4P5
	 RUq8dZPAiNG2haLLSS1yrfgadA8DvnevHWN44w8za+p9EHt38v4BEevUVcDt/oiY/UTYb
	 GueoYVVH4f/n9TYzQ94dH44AuGTfMVPtcw7xRoJ3Eo/ASeVsS6S0HOJmuZV4EO7nIpRVp
	 tZ7Jg87fVBxlMNTZsKIq4DR4pEHTo3IbNjNFYBmbYketwiDX5XgCOdzY0PdVWnX1ybw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fKxC9SAZ;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=ULamVJcx;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4532606A32D
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 13:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D4532606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fKxC9SAZ;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=ULamVJcx
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794664328;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=tHza3z4s45pIJ2GPKijovhB9sBTc830I4fCUe8B5OBU=;
	b=fKxC9SAZ4rWo3MQDiYe/XeskNv1U0VYyP0znwJdj85ARaAG9VewWDr0ff7DwDDga1ljUJC
	uONG4Ld1645JSkIlrGQUc6GIJPb4c9tuMEPaBuoudQWMxaSwxG3ARn+/RLHwRxBbgn/d6G
	Pqmvx8Y5CTisl9UjGg73uPe2fpEBzQQ=
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com
 [209.85.222.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-660-p8qREBXpMYe131rd85E__Q-1; Sat, 14 Nov 2026 08:52:07 -0500
X-MC-Unique: p8qREBXpMYe131rd85E__Q-1
X-Mimecast-MFC-AGG-ID: p8qREBXpMYe131rd85E__Q_1794664327
Received: by mail-qk1-f198.google.com with SMTP id af79cd13be357-93f37c94ceeso587785685a.1
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 05:52:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794664326; x=1795269126; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=tHza3z4s45pIJ2GPKijovhB9sBTc830I4fCUe8B5OBU=;
        b=ULamVJcxyriGxgX1D5N2gZuPBE+Jp5cruuIUqeK/VScTohIx8mT3lEJIE+7ddQJzp7
         /+ZP0/xbhArIfS6I6BbMUV/5bKHxAK9CzfbjhfFNQHYi95UM8KbcM1yneBCZbGqyEC1M
         BECwQ4nc8kav0BYJfS20nuljYenKNESBd+JrvNwvBkHIN07NflHVjL6W7vd4Is0op0KE
         BALCiP1r1wiVPGBHLDw91YcxnZzVS2jDEoO6KiroHm6SCB19p+0DDMGzJifM++gjGSMg
         t7RfONn5mMhXh9zcqqb4IjUtDurEFlr57ckf06EiUrxWEV0JsohHWMHZ2aJQZcM4y8IY
         MuzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794664326; x=1795269126;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tHza3z4s45pIJ2GPKijovhB9sBTc830I4fCUe8B5OBU=;
        b=1C0pqGfEyuUQsztgZCEWunmBh0/4vpHvdyO0w1uvEiqWjGqmTztcVeyW/542RQhPU1
         q3ggSwwiWLn1LXOs6ZkUP89d5WYm6/i14BFtKq2DmZ0/0pv+jW2p1R+5cDIGYfyayUIk
         D2TgUJSphXCdC8FYtvrQAxh1fGgNV0WxxvRXCERX68pttSA8TdARDpnZsz81SHBjmQNH
         YNKGknBqxRXEhqWERqhIRUavtVrDDVnPC3iI+/lJDkKv7u7+xKq5fbHNA9baBKz794CA
         s338e88elpYqM0bm3+cDhU642T7nZ59x5etnuqduUdPx8WHneLZMeBEHkuFUAbJP4wjL
         p+DQ==
X-Gm-Message-State: APuU4Z922qxXHxlI6owqM1lWY4h2OvOYZb87uDvQPBzPFKdE4U4I5Rvx
	RwJpVz9guwGJMLXG+c6p6RgfXQ6VkjL6zEKFd3Rz9INA4QjiJWH/kW5YFfB1h3e6r+A08ZvyfGy
	tVfDV//b+rpd1tHmDyVtLbwIjexEbxSt9j06btSMEfIvWi9DR+AZ03K0IsKK5TQ==
X-Gm-Gg: AYBFou2e50SttkggUwtDP1IboeJfD7s1RA7ts91zsTGdH+6syBAF8JZbvX90bL0hGQO
	tfGqiAQfNRcWejyGHBa2LlnNOel0BSVNCyEjLJITwQhwkV2ZfvPlrrk8LnbCBXwbwrjyVirPem4
	92I9VqxPfafmYmE4u0FyqLHtpM6UoIR3rA0nUvtqHVDz+J1gU4lwTe9VjWs/LvcNpYW1KATwhf6
	DMsfd96gCprwM9h0JhPTWTU6WGB8ct86H3qDacxFj3g2v9i8VodIf9VHEXa8I77Qzx65QoLP1xg
	26iPvS7X/y9E1WBsXKvwTPSWP7YhBy+5iI4WctxUdnBu+wRlKw+oH6WdLr6vjaLFw63XSlIWcg5
	ZpgZ3l4jM7Wu1o+8OsFxcxt4qFN544inEEzWIiskc6L1eYC9a
X-Received: by 2002:a05:620a:440f:b0:93f:3193:ac09 with SMTP id af79cd13be357-9493301ea95mr1456540985a.15.1794664326616;
        Sat, 14 Nov 2026 05:52:06 -0800 (PST)
X-Received: by 2002:a05:620a:440f:b0:93f:3193:ac09 with SMTP id af79cd13be357-9493301ea95mr1456538885a.15.1794664326209;
        Sat, 14 Nov 2026 05:52:06 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9494c836156sm411016985a.19.2026.11.14.05.52.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 14 Nov 2026 05:52:05 -0800 (PST)
Message-ID: <ae6e8d5e-a7a8-49a0-8f46-65e3ece39a24@redhat.com>
Date: Sat, 14 Nov 2026 08:52:04 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH nfs-utils v2 0/4] exports: add support for new read_io=
 and write_io= export options
To: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
References: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 10/29/26 8:10 AM, Jeff Layton wrote:
> This is the companion patch series to [1]. Chuck suggested we change the
> export options to read_io= and write_io=. That's the only real change
> in this version.
> 
> The last patch in this adds a new nfsd-iomode-advisor script that
> watches various stats on the server and advises the admin what mode to
> use.
> 
> I consider the advisor optional as it was largely vibe-coded. I'm not
> sure I'd trust its advice that far, but it's probably better than
> guessing. I did test it on a range of different machine types and it
> seemed to do the right thing.
> 
> [1]: https://lore.kernel.org/linux-nfs/20261029-export-iomode-v2-6-fe8ec6251a36@kernel.org/
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v2:
> - Rename riomode=/wiomode= to read_io=/write_io= to match the kernel series.
> - Link to v1: https://lore.kernel.org/r/20261027-master-v1-0-6f1f7a35a83b@kernel.org
> 
> ---
> Jeff Layton (4):
>        exportfs/mountd/exportd: track the svc_export policy highest attribute
>        exports: Add read_io= and write_io= export options
>        exportfs: Display and document read_io= and write_io=
>        nfsd-iomode-advisor: recommend read_io= and write_io= for an export
> 
>   configure.ac                                      |    3 +-
>   support/export/cache.c                            |   59 +-
>   support/export/export_policy.c                    |   29 +-
>   support/export/v4root.c                           |    2 +
>   support/include/exportfs.h                        |    3 +
>   support/include/nfsd_netlink.h                    |   12 +
>   support/include/nfslib.h                          |   14 +
>   support/nfs/exports.c                             |   51 +
>   tools/Makefile.am                                 |    2 +-
>   tools/nfsd-iomode-advisor/Makefile.am             |   14 +
>   tools/nfsd-iomode-advisor/nfsd-iomode-advisor.man |  232 ++++
>   tools/nfsd-iomode-advisor/nfsd-iomode-advisor.py  | 1198 +++++++++++++++++++++
>   utils/exportfs/exportfs.c                         |   34 +
>   utils/exportfs/exports.man                        |   22 +
>   14 files changed, 1671 insertions(+), 4 deletions(-)
> ---
> base-commit: 0ed4324cbbb8020039d338d597c1422a980f7085
> change-id: 20261014-master-b5afd69e3772
> 
> Best regards,
Committed... (tag: nfs-utils-3-1-2.rc3)

steved

