Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E8983FAE19
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 20:18:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786479515; cv=none; b=JcqlV0xaazFgiXSpHKtVlBXrxFoRX2/VMWfDbzmgy0ZtXDOTLKEdTbDg8KfMRngH+AV1Kxv46w9fiz1Z/NCzR+U5PSo9l2CEPH2ds4VI4z3rK1wVFGfAgAE14GKac4BB965Bt2VbilnDk5/C7vCBEWAV94sWruiLQmXmyHb+vEo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786479515; c=relaxed/simple;
	bh=ccUlQITujjKDxvsizPgp3QY5vJYvUp9kjFimThDnMxk=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=oYSYbOdC5Z/IGt8FW+CynGgiUHsmzY6o6kSBcJHBLTAH6agL88hNBa2ruXI3Ay/9/FAPvXwFmEpYyHylQd+n2f+3z5I7Ne3BBbIVCtKJFcgh/0rLXuI45cLxQznWM4lTxeCvDFBtV7WBZNxs2or5T9X56tZASFWjQeU2G5n2zck=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Pa7YLGEj; arc=none smtp.client-ip=209.85.221.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pa7YLGEj"
Received: by mail-wr1-f54.google.com with SMTP id ffacd0b85a97d-47fde295992so213352f8f.0
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 13:18:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786479511; x=1787084311; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JFLe6tkLYuEC2gnEl/GsgjOSVqwPRw7abghLXfye9/g=;
        b=Pa7YLGEjq+OIlzTFZMUQczrnv8nhodyrexeB8TosOw5rd2s7hrHMHVv2IxRnKOxePx
         iHhHvEtRUoR06HeffIfbA0Ffu7+N9K4t0D/dC6xnu+gHofT7gtQJ5iVnjqtTZJ3lNEGE
         2n/+ciBMi4W3n3MVJz6jXrIBlQubrTfFR7rXzRp9Plqdd9Kk/ub2nnX5WyOzstA/t1YI
         kR0GvxM1Z/phs/XDzVJEs81p4NjrhUei7611y8D/QTZk1Z+g9SNQ4U+zVR+J8pIS23NP
         SsT8q8ZWd+UJOgKSnCoe38k2JzvrEemASF53MWxAqvL51fYBLWe6KY4pZYDHyWaGdCIq
         Wqzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786479511; x=1787084311;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JFLe6tkLYuEC2gnEl/GsgjOSVqwPRw7abghLXfye9/g=;
        b=ctuq0ICvaYA19mV4sXgfySb3NCRVoyRc/fECMw7EkIN90uWfBSY4xKmH33XoNRyw4m
         kdwm04r1zyWy1o9a5DkWUkPdEdx+C2vPLhQw/WhmOwiIGw3zeeTfHbAqVJwh04er4Lg3
         s2loZ0Awhyz7dW+Oseimb2rsWdG4chPH4U6vhkiXwT+X4V5bgPb0Sr/9XzI4Bz/g2H01
         o1gKNCwc/VrQRTrEv24zaC6VsIZf9rEn8xjLZmsa/xnbivmDSNN6pHyHoRoUjyNkBl/S
         3GpNzT+FZRJd5IHZ6UZ32apmMqNnW8FQ+Nsz7mAcGxoqqizA/HDVVvTQCRcyHzsfBm77
         GjgQ==
X-Forwarded-Encrypted: i=1; AHgh+RoCVhjUs/NTaJUfTlb83yhFHkxqZyqq60IUu8Q8mTrvxOlWfWLr327bXxfyz2aCSgQdMtgIt2t06wE=@vger.kernel.org
X-Gm-Message-State: AOJu0YzOQDsdDB07Ye1YxWMfUC2tWc6PqbPyepNGaPDJxRS6dyyXgZJO
	W7a5JkH64CRL3HfxF6mvclwRYxMOKAsG/rbgEGpgu2orQ6G4nX7JoG2t
X-Gm-Gg: AR+sD10YukZNiKN2vGuGmKOM2/FuucVNId0rf8seAQTWWRPcWQX+SGolUqgt7bfVjUs
	slVqIC655+BN32muF6Tekiq88Y3YORYgIUjpcKN40H3fRI0GlOH6HnjWXTdyLVxuUsgshwOkPVz
	Vyk/x85RpBwkwou2bHHH7CX5lIuuCKOIgpBC1NkbkbKO5+JI1ibSTNpXwrbTPYchaEWvcxZA1dI
	SUpmYxffmC2VXlQtilOJU9wLwvjypKeGtzaAbBE8WqiJL9uvIyGkyRETBCzXpHNK9rL9WiL1oZG
	QQQ4B4RrDNNZro7mszWwSlZr7vDLjq/hUmjWtoH2O5Ox4FnrHwzUjwsvsiWHBGs1Fj2gQqFg/sM
	zeWk6srB15TZX5bCApzN6N/NEOgvG6L34lqmS7q3pOS7/YS3U9rwBUzorbgutn7SYi17qakMx0a
	LN3ytG/Ax30zz3/ul5CjoPOPjqOuAS6roxqO/lw672Nv5pQ42WqNzBayETIoOZE6jnZBdwtDbBI
	R6F8YE23L23XQ==
X-Received: by 2002:a05:6000:430d:b0:47f:e7f9:5251 with SMTP id ffacd0b85a97d-4814ffe28b1mr3367485f8f.3.1786479511163;
        Tue, 11 Aug 2026 13:18:31 -0700 (PDT)
Received: from [192.168.2.14] (85-70-151-113.rcd.o2.cz. [85.70.151.113])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48150bf5c5fsm976683f8f.3.2026.08.11.13.18.28
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 11 Aug 2026 13:18:30 -0700 (PDT)
Message-ID: <8654c2d4-8d9d-43f5-9256-adf2915209e9@gmail.com>
Date: Tue, 11 Aug 2026 22:18:27 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 13/13] dm crypt: wipe key material before kdump
To: =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 keyrings@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 linux-integrity@vger.kernel.org, linux-afs@lists.infradead.org,
 netdev@vger.kernel.org, linux-fscrypt@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, dm-devel@lists.linux.dev,
 Andrew Morton <akpm@linux-foundation.org>, Baoquan He
 <baoquan.he@linux.dev>, Mike Rapoport <rppt@kernel.org>,
 Pasha Tatashin <pasha.tatashin@soleen.com>,
 Pratyush Yadav <pratyush@kernel.org>, Dave Young <ruirui.yang@linux.dev>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>,
 Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>, Lukas Wunner <lukas@wunner.de>,
 Ignat Korchagin <ignat@linux.win>, Herbert Xu <herbert@gondor.apana.org.au>,
 "David S. Miller" <davem@davemloft.net>, Keith Busch <kbusch@kernel.org>,
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@HansenPartnership.com>,
 Marc Dionne <marc.dionne@auristor.com>, Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, Eric Biggers <ebiggers@kernel.org>,
 "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
 Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
 Mikulas Patocka <mpatocka@redhat.com>,
 Benjamin Marzinski <bmarzins@redhat.com>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
 <20260811-crash-zeroize-rework-v2-13-9561d13c2340@jaseg.de>
Content-Language: en-US
From: Milan Broz <gmazyland@gmail.com>
Autocrypt: addr=gmazyland@gmail.com; keydata=
 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
In-Reply-To: <20260811-crash-zeroize-rework-v2-13-9561d13c2340@jaseg.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 8/11/26 7:53 PM, Jan Sebastian GÃ¶tte wrote:
> Wipe volume key/iv copies kept by dm-crypt with
> CONFIG_CRASH_WIPE_SECRETS. The backend tfms are already handled
> separately.
> 
> Add a list tracking struct crypt_config instances when
> CONFIG_CRASH_WIPE_SECRETS is set. Structs are tracked here to avoid
> having to enumerate them through some roundabout way before kdump, when
> we can't safely take locks anymore.

Well, dm-crypt has crypt_wipe_key(), which can be called through a device-mapper message.
It also sets keys to zero in the crypto API.

Why do we need yet another way to wipe keys here, reimplementing everything twice?

I can imagine an emergency wrapper callback that will suspend dm-crypt and call existing code.

> Use custom wipe handlers even for things like ivs that have existing
> wipe functions elsewhere because we need to use crash_wipe_memzero
> instead of memzero_explicit. The crash_wipe helper memzero_explicit's
> the target buffers and flushes data caches. On ARM64, missing that cache
> flush could lead to the zeros not being written to DRAM before the kdump
> code turns off the data caches moments later.

Please no. It looks to me like you are trying to fix this on the wrong layer.
This way everyone will need their own memzero...

Dunno, but I really do not like dm-crypt becoming completely bloated with code
that has nothing to do with the original purpose of this driver.

Milan


> 
> Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
> ---
>   drivers/md/dm-crypt.c | 151 ++++++++++++++++++++++++++++++++++++++++++++------
>   1 file changed, 134 insertions(+), 17 deletions(-)
> 
