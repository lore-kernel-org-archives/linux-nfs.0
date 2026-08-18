Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E2533B9D95;
	Tue, 18 Aug 2026 09:03:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787043814; cv=none; b=RQp1z+84goryEOkNPklXK/X3aThlt5joJjTroNTIdFFbXayTc/fRFRzqzuIAfFavz0VMKbxN9NEcqgUVr18mPND7MYAJpKT6BUmGouymDeD9wpplnh6jrM9W/3BiHSLL609leErehN+Lsn/0FXLHTPiHPJ9wjY9D6gG+1EkZY+w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787043814; c=relaxed/simple;
	bh=WO3NGxY4syeZ2ZD3BmzUXP3M7Bt0QwU8LVneEp3Vn2Q=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=cz+F5X1e+4l3SWhl6sK/5X+hcxIza7yu0U35SROpWcS5TbbOrJPsQwsre52fnk/yUALu3VcQQfvt4d9MZEGu2pw0eRlVlVNRPzY/ixCoApLAyPv2N7b6o8syx2i5tzaRhI39sJaoMZkXFGwdZ/YZSyzb+BolexK8CQXknUMsKkQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=WPZZoKGM; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=NYaRi+TS; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="WPZZoKGM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="NYaRi+TS"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.phl.internal (Postfix) with ESMTP id 5C82F1380244;
	Tue, 18 Aug 2026 05:03:31 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 18 Aug 2026 05:03:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1787043811;
	 x=1787051011; bh=ZX1CnQZZsg94K1w9ifnkc6/NmgcRySaktgXNfBgb7AQ=; b=
	WPZZoKGM/D3I5ywu6hWxeUzIxxVJ8JaogWauiMKsZIA9L+2KD8F1opSZimhHAVKL
	5a0sb6E7AE1N+ZTNYCeJQBZ+m2FEM4CV7GMsqbHBUWfOHXeEjAaQ1OAiBbBbW59J
	b1PhzIsGrQ2x+2Dni2rvrHfHUrqMx08mPCwM/2bfa9SldiuOZjcpcWOlGE1HpOcd
	G0YIdXoV0HVGd4L+mxlNmNNDIhof5BifyFVcHuhiep66N7ofIvUZTm6prDYrlyWK
	zAEmkzqJ+outKDKC0CHUxyq53gCJ6k58wqWemTPbG92+4A3wfTcxtWmA675wMRHC
	QYOZU0KDnVhgr69AP0V0Bg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787043811; x=
	1787051011; bh=ZX1CnQZZsg94K1w9ifnkc6/NmgcRySaktgXNfBgb7AQ=; b=N
	YaRi+TSIddvpqgRTVgxa6VkeBfERJbKBvbyZhIzfXNJys/mMTEU1csXrJL5DGzbN
	PCKZKgL431iiunzQQDBvFuzWW69BqYCSsFA5vAr0RhpoL1B1z9aPTFCNw7/QA19A
	saZ0S0t62u9ilibZlZt1i/7WvU/qVXs+q65oY7JWrtfuouhLYcwOK4sxpw9so70V
	0/BgQw+DhldDFVQAVyvQgDYSDnmVHgBz/o60QfvZIbIrNu09JczWI0nsBqGFZNEN
	5UPYGIzCosYhlot0IWvFxAqjKXNQIIe5Nc3jckxMBZ736pOuOvMzIar47qPI4WKI
	FVKhOCCNDBW0c2jXhd1ZA==
X-ME-Sender: <xms:4B-EauM8Y-WoFhcHV7CDKlTqAXtB-K4KRmaH8Ji1IGVdeubq9ketyQ>
    <xme:4B-Ealztkx_kES_mWsN78pZXU9JB54Mew-argE8U363HXR6ZZcMDZrZ1r7KLZayGA
    VUMOnw_bfE8_HFBnwIY6yzIzSIEfLRM4kpRnIw3jK-F75RiMw1zRw>
X-ME-Received: <xmr:4B-Ear2lM4JA7KsBrcTQX5tTYYYgKvP9cy4R-UIHarqqQ6wJIAuSBmfYB-cMSSdOV5yu6OXNk-afOhj4igKm>
X-ME-Proxy-Cause: dmFkZTFpA2CAQ9HsB/cHX0jgjtdDSxrlNaH1N5XdMBpyCH9Ywi6Hdh5ucTA96FWQa4HkQJ
    FvEd7sRFuzES1QTCCXc72OlhgrTRDpI/mv/2h44E6mQB5bIPt7uKTuP2q0GgZRoIvFIf7T
    TMZ3/nzGVeOohp8c3ZE54qSC9/YJNe9f6CUcVKmuTPT1A2+XUIsIivDdrhAHumwFv6AQfa
    NNzoFOD5IVmP3t/+TNxvkur2XMEg96QOc5X07R9jGlcw1D3FBObbnwVn6TapmMDjTj8mel
    XF3EW9HqD7I9ZDaJuBDS4ARPRSLFsySvU1MjYl98Znh+hLcqka5PZ2lKMDy4GytU3qjXHP
    98DJem6QpOGqfB3BYBGJDTFsCAtPWcw71a1t0bx+yVXLzQg/zX2eANVIW+Pof9QleQxvN9
    P/N2zoRmGcsxnzVAX9yilz5Hf18JYw9RDeTkD0e4hVVYoyZ9d7hMxsqFj8qpAc09VhOuqd
    r9AoF++WkVV8iSPyIp43mJ0TdeQR0JQhCzxLX9LtVsEaNESQdPbIT8kPTvzqYUZ7lqGq/k
    PEaZa2BEeR2Eln3RH9rkvTn6MqyAurRLUbA+ihdv70Bc4xu6lg5mm9xC/+Pb5HPANA2dOd
    Ytxl5ozIB8gbREK41rFGTIGGQ9URIpBxDMvfEg9AUeTxj19lPYQvx6jTJGSQ
X-ME-Proxy: <xmx:4B-EasH0JHdfdUJp3cw75hmN4JbAktp9qP7MbFjC7JV7n6UctIxhEg>
    <xmx:4B-EagKH8JC384TlH3cR7ulRAHL02wkXnaDo1V9ztrqMfX9MoWhZwg>
    <xmx:4B-EarwND5OYC8e2x_4D5dXRVAx5TKWwG_rdZqfJdmokI7UUzMRH2Q>
    <xmx:4B-Eai1Yt3SDtzatr_bnVyQU5MFRORQZ930EDB5uwIJ17WKuX-K8FQ>
    <xmx:4x-EahEHf5VCv1VRvxU22t6K4tWi1wKnPfuGOHSqlSCXyfMxLQLJcyjV>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 18 Aug 2026 05:03:21 -0400 (EDT)
Message-ID: <9071e03b-a633-43e4-ac77-3b05291c1f66@jaseg.de>
Date: Tue, 18 Aug 2026 11:03:19 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 01/13] kexec: add CRASH_WIPE_SECRETS to wipe secrets
 before kdump
To: Baoquan He <baoquan.he@linux.dev>, Lukas Wunner <lukas@wunner.de>
Cc: =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mike Rapoport <rppt@kernel.org>,
 Pasha Tatashin <pasha.tatashin@soleen.com>,
 Pratyush Yadav <pratyush@kernel.org>, Dave Young <ruirui.yang@linux.dev>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>,
 Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>, Ignat Korchagin <ignat@linux.win>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 "David S. Miller" <davem@davemloft.net>, Keith Busch <kbusch@kernel.org>,
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Marc Dionne <marc.dionne@auristor.com>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
 Jaegeuk Kim <jaegeuk@kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
 Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
 Mikulas Patocka <mpatocka@redhat.com>,
 Benjamin Marzinski <bmarzins@redhat.com>, kexec@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, keyrings@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 linux-integrity@vger.kernel.org, linux-afs@lists.infradead.org,
 netdev@vger.kernel.org, linux-fscrypt@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, dm-devel@lists.linux.dev
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
 <20260811-crash-zeroize-rework-v2-1-9561d13c2340@jaseg.de>
 <anw9ILJiO5xIjP4f@MiWiFi-R3L-srv>
 <9765f7ea-36bb-4c7b-a19b-7facec97b762@jaseg.de> <aoGpcczo5GkBsPwt@wunner.de>
 <aoK6jXA-tF9qfKOZ@MiWiFi-R3L-srv> <aoLFai0gzzH2bGgy@MiWiFi-R3L-srv>
Content-Language: en-US
From: =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?= <contact@jaseg.de>
In-Reply-To: <aoLFai0gzzH2bGgy@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 8/17/26 10:25, Baoquan He wrote:
> On 08/17/26 at 03:38pm, Baoquan He wrote:
>> On 08/16/26 at 02:13pm, Lukas Wunner wrote:
>>> On Wed, Aug 12, 2026 at 12:08:39PM +0200, Jan Sebastian Götte wrote:
>>>> I can imagine one alternative way to approach this, tell me what you think:
>>>> Instead of registering wipe handlers that memzero places on panic, I could
>>>> put an optional registry of (addr, len) descriptors into crashkernel memory
>>>> that the original kernel populates with the PAs of buffers to clear ahead of
>>>> time. Then the kdump kernel could do the actual memzero. This would remove
>>>> all code from the actual kdump path here. The registry could be made
>>>> per-core to avoid locks.
> 
> If this has to be done in kernel, your (addr, len) registry idea is a
> better direction, and we can make it a bit more general.
> 
> Instead of a secrets-only wipe registry, consider a small "crash memory
> region" table with an action per entry:
> 
> enum crash_region_action {
>      CRASH_REG_WIPE,   /* memzero, then dump normally (leave zeros) */
>      CRASH_REG_SKIP,   /* do not include in the vmcore at all */
> };
> 
> struct crash_region {
>      phys_addr_t addr;
>      size_t      len;
>      enum crash_region_action action;
> };
> 
> void crash_reg_add(phys_addr_t addr, size_t len,
>                     enum crash_region_action action);
> void crash_reg_del(phys_addr_t addr, size_t len);
> 
> Two actions because the use cases differ:
> 
> - WIPE is what you need: zero the secret,
> - SKIP covers things people do not want in the dump at all
>     — Registering as SKIP reduce dump size. I have been considering how
>       to shrink vmcore size on some big system with huge memory, the
>       vmcore size usually is several or tens of GB.
> 
> If this is OK to you, you can start a regiestry table
> infrastructure with wiping secrets, we can add SKIP later and plus some
> driver used memory.
> 
> I am not sure if it's satisfactory, but you can give it a shot to show
> what it looks like.
I think that's a good idea. I'll post a patch adding that registry this 
or next week.

Thanks,
Jan

