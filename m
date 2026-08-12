Received: from flow-a7-smtp.messagingengine.com (flow-a7-smtp.messagingengine.com [103.168.172.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1ACC41379E;
	Wed, 12 Aug 2026 10:08:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786529334; cv=none; b=DvpkIACyyJoTKelXJ9P4iw/1nXcC/ds96T8wBJTEGmEJSUS7P3sYscsL0j4vCy5bfe0JIo6IHRfbDJapsBmMwaK5m7F2kruqwqN4IF+jypIYPyi9701h00MXGp3//dTXApElA3i9luqNdXLQF7jC9WE2aT/ZLdzAu3BJDCep89E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786529334; c=relaxed/simple;
	bh=g+DD3uHXa4UUhT/lPNztmr+/Ptgyo2Iymel1zvvVQDY=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=f1/RAlCN4gAHfLQ1LPMyixT00GxZ818MzyN1/Ka9flSYG01GIcEdiYCyDP0QQY5t1cA9TT2zBCNx2z/RkV9u8/wxx8z+xzhCb189VdNSw46ExaVg9Vf1EU7y8qhZhL5ioGVofX9qn9OCtvXUdSy7D7vw8Fjo1UcTR4FRwYEot3I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=DcXGvPte; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UjdjRg4+; arc=none smtp.client-ip=103.168.172.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="DcXGvPte";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UjdjRg4+"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id BBF2A1380318;
	Wed, 12 Aug 2026 06:08:51 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Wed, 12 Aug 2026 06:08:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786529331;
	 x=1786536531; bh=bW88MBwEWiHxXalK9p7mEtRxunSdhzNV0Ppwj/k9i1k=; b=
	DcXGvPteCscZI/GwRFTH4mv+X4SBB/L2nxEuJXbaNHkr7F0smm74zCR8ytyfyDK2
	deNYonkvGo9MorQPdzMgQpumMiqEhc8kh7MDjUKKqGqjt+dgXudLF2NAd+JuTt7x
	UOp9kU5qnPaxYmSlfLw9SLn1YvREorfEChCB8Vdv59wlD+g3/yCoYgGcpIqSe4Rc
	Qq1tBLIylDAWQwRLdfmoCCE0zKkoMgVOuw4NGvt6C++AcqG/yFKk+wuMQ/frzzUe
	WpyHueUkS66e1tAjVlj6aRNRY0MVy/A61UttJXizY4zHHKHxwuCQ04mYK+JdJibV
	BW5DkvddWVJNd+e4921zzA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786529331; x=
	1786536531; bh=bW88MBwEWiHxXalK9p7mEtRxunSdhzNV0Ppwj/k9i1k=; b=U
	jdjRg4+0h4GBVHbZWuRmenc5MOZBfXytCFvmTozoVejQhqsVKAEMlXEwYPkPtGUf
	ngjYTyAlntHn8cPfnVBmFXK6yymSNOQjVjq/zODcJ/9KAsZQleveajikxRPmdHh+
	f0699mdyLBUNwQDcrQyRiireEzWnN1ycYuWE7UFyW7W5Vk+y62fJjCiUztDkiwHF
	hSPudpSXapetWUF82JoBdX+pfYcfIkKdL7WAcPaR+mxL4Agav8Dq2b1FFMhPkhW0
	HB0CWybFVT+kC+5ykPmgP4BfbRihc8/zeqNji8x9JptmpqNW06HCLUF8eo8SwZoq
	IYnBLOl1NKyId+2gBMSzQ==
X-ME-Sender: <xms:M0Z8agx7iq5l6vNO6xYCruRD2E00yv5vuI2Kb3O7lpjSeZknJuQQxg>
    <xme:M0Z8atE67uJ8acOVlANAZcbJPqLF1EXgJHG8w-W29FC42CpoMUpPc6zJZrUmQ15pJ
    vbAW4CmdwXunbNC3IL4ubajn9C7kB0m_c4Th5Y1NuVPh6cIuhZOS6A>
X-ME-Received: <xmr:M0Z8ao6-Ga9RNzEg3L_Tve-n8wkgt46prWBGzOHpl3dDvS1SWuS8m7L0jyPxpVTOqCKd2Q0SAuTvsdN3islXKgI>
X-ME-Proxy-Cause: dmFkZTFhXuUc5zonLNYLcZR1VVfiawIf/DLo3p0z5ttoTk/im5FO3AIzDhACbr4L+QCnil
    kioW5B72/SP07lPyYbCILOUlCTgqnf/GMHpVt2rW3DvDsF8fWXLyV6Ac927tGENmhoEL+J
    Z6CH2rvUSCSrM3xrC6dBhmoeT9oKOxUe4lTyzrsaEkFV1JXqZigC3Blmzh555hht6TIiKi
    4nTF00vMvYIsG9kgYkE+A7k3OF7cYtOAnFjzfRjDuHBWPJ8P5jOo39HJ5TosgHthcL4QlG
    P7LPfpZKOLHflDDP05PIzu6Ek0lvi9TNUbB3XsXC6/c/eoqN+joQ+KYmRU6qOJdnW6tfk2
    b3LcfBVqFT/qDJEWQC1jHMYXTbxwbN1oIMefnFPjOiXoCu9W7XlYR2+Vi6xD+4IcDtaHDf
    3Pk7JEFjV5aRi/7eHGIdN9qQLITdCzsUHDcCHNYmXmuCjX0de6WRjIKRBxkr9zr/UoSGMy
    BNKaooHXOUsyG6uKaR7kNVptOhuOAnNTQ7wosLA3fxbSinTppxLVYVo701XXDmkSXpvxOt
    2fnf6YwlDC373uXVWWSjQbW5oUSUiaeZBnj2S+q+kGyVEaXlZUP3YiSxUlbXsnbIPZIJSU
    LpZLpLWNEokxMls5XhgH+3e+Mki9vSCEGaM/bL8SmICNy1uQbJHeVjIUfaAg
X-ME-Proxy: <xmx:M0Z8ar5LFW4HLTNx65wrmfFVFhE9YUH4fWdaEbGOL_R2dQ7JIIx9kQ>
    <xmx:M0Z8arveqDruVQu_W3KqNZ2-dNqOPrxild92m5A8icNTm2aZXyRXQQ>
    <xmx:M0Z8aoGd6MFhQRaDPRdZ0DLf5Q5xuyIoonETpFoTn-LlvXMTUatv4g>
    <xmx:M0Z8ag6NID7YDETuV96A4Hm8RKzm3lppAKyjDREHWTD8S7uA_ah42g>
    <xmx:M0Z8ajPt2vz0J2SwGT_bgJZVQ8rEA86QoRBfb4QhSwW7QoKJpm_Hd2Xr>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 12 Aug 2026 06:08:41 -0400 (EDT)
Message-ID: <9765f7ea-36bb-4c7b-a19b-7facec97b762@jaseg.de>
Date: Wed, 12 Aug 2026 12:08:39 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 01/13] kexec: add CRASH_WIPE_SECRETS to wipe secrets
 before kdump
To: Baoquan He <baoquan.he@linux.dev>, =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?=
 <linux@jaseg.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Mike Rapoport <rppt@kernel.org>,
 Pasha Tatashin <pasha.tatashin@soleen.com>,
 Pratyush Yadav <pratyush@kernel.org>, Dave Young <ruirui.yang@linux.dev>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>,
 Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>, Lukas Wunner <lukas@wunner.de>,
 Ignat Korchagin <ignat@linux.win>,
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
Content-Language: en-US
From: =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?= <contact@jaseg.de>
In-Reply-To: <anw9ILJiO5xIjP4f@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 8/12/26 11:30, Baoquan He wrote:
> On 08/11/26 at 07:52pm, Jan Sebastian Götte wrote:
> .....snip...
>> @@ -142,6 +170,7 @@ void __noclone __crash_kexec(struct pt_regs *regs)
>>   			crash_save_vmcoreinfo();
>>   			machine_crash_shutdown(&fixed_regs);
>>   			crash_cma_clear_pending_dma();
>> +			crash_wipe_secrets();
> 
> I remember when crash_cma added this, we argued a lot about the risk,
> finally it's added in with an added note to tell it's an opt-in feature
> and risky. I don't know if it opens a Pandora box, I think anything
> wanted being here need prove anything else has been tried, and the thing
> is very very important. If we don't guard the door well, one day one guy
> cold come and said I need ask Oracle database to do some transactions
> before juming into kdump kernel because the actions will save billions
> of dollar.

I see your point.

> And what does security people say about this wiping? Is it very
> important information and wiping is mandotary? There's no any other way
> to wipe it or pollute it, no way in kdump kernel?

I'm doing both - my kdump kernel does a linear memzero of all of DRAM. 
However, that's too slow - it takes several hundred milliseconds, and I 
want these cryptographic keys gone within no more than 10 ms.

Doing this in the original kernel is cleanest I think, because to do a 
targeted erase in the kdump kernel, that kernel would have to know all 
the original kernel's symbols, and it would have to forensically 
reconstruct it's memory content similar to the crash utility. I think 
that's too complex and error-prone to do in this use case.

I can imagine one alternative way to approach this, tell me what you 
think: Instead of registering wipe handlers that memzero places on 
panic, I could put an optional registry of (addr, len) descriptors into 
crashkernel memory that the original kernel populates with the PAs of 
buffers to clear ahead of time. Then the kdump kernel could do the 
actual memzero. This would remove all code from the actual kdump path 
here. The registry could be made per-core to avoid locks.

> I noticed it's
> happening on en embedded target, is it possible you do this on your
> embedded kernel tree, but not mainline tree?

I could keep it in a vendor tree, but I think the functionality is 
useful beyond my particular use case.
