Received: from flow-b4-smtp.messagingengine.com (flow-b4-smtp.messagingengine.com [202.12.124.139])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A88F43876CC;
	Tue, 11 Aug 2026 19:38:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.139
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477116; cv=none; b=V1f5iaIKUFOUgKXRPUB+BiUFqgo+LxT/vS9s38coMeB4PCQ5pEUaK6VYNVG9++H9XwgOCFjZINDRaBSLod73TGuLyg9RsKsAvnYi5uxbWb6pnj9q+6Vr/C39b88KNRjCckXg+kOhojyQiRgq3oLkYlR3s56Q6Ip5+T8CXGn9EVk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477116; c=relaxed/simple;
	bh=KtT7T2Cl0Bd6AZKXsqdksNyHtnQ0lBNVEOMRPG5JkaQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=T0Ho9OzS6DIve6em4uaGCYe++khchMWZlNeH3oOvt40ADKFWrdgoJcStMo/cOjR8uaZhYgznwK7e3hKe9dmrmlPPdlw/7wV2x6txcUPR1ttTiBKHCsp3/zdN/eG8gF9Cj/nn1rkdi9VupbKZkmuxIqc6/GGSXeHRlDe5uHYIVMM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=keVFG8pp; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kVEP8+AW; arc=none smtp.client-ip=202.12.124.139
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="keVFG8pp";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kVEP8+AW"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailflow.stl.internal (Postfix) with ESMTP id 57A4B130049E;
	Tue, 11 Aug 2026 15:38:32 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Tue, 11 Aug 2026 15:38:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786477112;
	 x=1786484312; bh=ACCE0ULeByOYA7YhgUX1DRUvF3xjVfa2RU3k/FuhH8g=; b=
	keVFG8ppzrE7UbbLjDHiHSJtI9Dx+qC2GlT9JBlIpkopIeTpIFALoZj3OtkLvdfN
	dfL2TBMn3a8uaRV/m816Rf06e3mr0hroGzSdd+B5ec8J0g2eXeGeXjAuwNMSLkNY
	QIjP2XadwJIHsrJ/wbPmwKdH35yPb1NnCPs66i2bSRa4Uq99sf8Nuw0Mf6pCfK+J
	kThrNnZcp1NSqIPErfXOc0RfhaVu59cUmelnkBO3KSzIXrXopIKIgEgDldYVzvNI
	welmLWkOkfy/F4HepsMn0mcxgLK91+D5vUgKj8fPfntYtmvq7Qhm1HYOa6KmzjUl
	6UkxnbzI2bD68I7n+GzHEg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786477112; x=
	1786484312; bh=ACCE0ULeByOYA7YhgUX1DRUvF3xjVfa2RU3k/FuhH8g=; b=k
	VEP8+AWcOEN0Mp8eXvv+rwkUV7PDWhxr0tETvHConAUEJWsr5f8F6/s0efBUcZ+t
	+tKA/3QG8yfvjLoGuQ6/Misma2xkaBu88+TWXveDjIS3BEt7BxwsiXHU0cozOXqR
	FG3TNEhUFL1/1aVP9JL7O6hqjhW3wkdWINPBSoZp1gTB42ghiPvu1HXAlOxieyJc
	B5nrDMw0Q2ZQEKk5fID63UCSF/YVDhETlOCv3eVsPxfm2H2kGwpyif3PZ+VFZXAK
	7csxHjdbjst4EPf3kEKw164Lo1wXGh4eu544U4PqHAfbOSwnSwjdebJ2kwl+NidD
	vDFxPVxM+qN6NWXI1f83A==
X-ME-Sender: <xms:NXp7am3-JJHEDtakJK9cAwxYvmI-jjPH2GCQRBduEHk2S38me8JTOQ>
    <xme:NXp7avov-avCmDj8oLbuR8A5eYaVWYCcUyJXQ22XIB5_lUbdCTR9RmC5ytOyYdN1w
    7mGQ0P5p7r1wS-EMaHeIKH490Nwj2DOR79-a-fRez07FIS_Xc0a>
X-ME-Received: <xmr:NXp7arqerxAnts3xbAyAAikoad2gB26eLQppY9rMC6Cwoki__UgeviPCfAfNuPIOwBcPWUsCfXfuh8u4c2cAyIE>
X-ME-Proxy-Cause: dmFkZTFMHFIUIFNvfOCiTcNbNas89HIxDpu9vnd9/UyYgPH+U8B/ewhZbOiCiNis/URMGi
    +GT3IjL+W7d23Jp2vVIoo0Dbticg5NyiB4xdyohEAzMY0lTBOp6JwJcW/q1E+SUSRo1/Az
    Amazx7B1t7Blz7aJHJrO+95WGbidE49E7NYEFoPjlZ9V6JiRV3Zj99ZPpw65cgBRTJN3ty
    V/otn2YNr7GDO5K1Y3PMGh6dJY1GfVQQ3Nadzvp6cPmJMPN1NICOE+yG1W3AymuWe2qnWi
    fcMMX1Ez44JzFnr50gj0OpqfOcphWiK5daA6xFPWxoB/nhcjlc+u9hcZFFOQ40nBAzjsnK
    NMSjsTAO0vS1FK0Nr7jBjGyYa27zDR8eNYzNfRC9pXsGY1rmnGcC+AIF1Zb/D/6KLKa9Ou
    KKiKG/B9ngGjM2/SC/ymMZ66VQj0q2OuI7Rvit9fFSdQI6+bU9vCZMe1Mp6T2VQcXOYvOw
    3ZVzBxjUPfcm392xJSNo3VbfDVgmBsZBqpFK3IPQn8t47FgUF5IyQdJVItFen8viK6s5Mi
    SEmladhakf8mkcxN38BHlSQJK3l1sP+qkjxo+US0nY0YwThgQliMkpmx6ze9nRadCGZU2R
    pFDTS02lG661OsONPL4SRaIr3QDOgPy97mTuAyYveBqhiYE7Jf2293Ztmz/w
X-ME-Proxy: <xmx:NXp7agecPCXtitwtn-MKPhHK6ycgOCvoVLPCy0jV8P3xwJrr1XpGnQ>
    <xmx:NXp7at1-8sj_G9Pne2cEf1vpSgTqhA2o4Ge-0aRba0lPolsRGpaEJA>
    <xmx:NXp7ajopnqavo_iqjEeHVPULvVuOnZ9VXmNSk83PNejxnKRLeZCFXQ>
    <xmx:NXp7akX6WQfEGCSrvykRgTkoakw86_WE-9CjQg8gLIhQb09ObgHPHg>
    <xmx:OHp7as81X0aOqOxljXrCGrq-RZMo05SALg18SFfIAdpgXoxGsje0SZ8t>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 15:38:22 -0400 (EDT)
Message-ID: <d242ab53-a39e-421d-ac39-4bee49be6ac0@jaseg.de>
Date: Tue, 11 Aug 2026 21:38:20 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 00/13] CRASH_WIPE_SECRETS: Wipe secrets before kdump
 (was: CRASH_ZEROIZE)
To: Eric Biggers <ebiggers@kernel.org>, =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?=
 <linux@jaseg.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Baoquan He <baoquan.he@linux.dev>, Mike Rapoport <rppt@kernel.org>,
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
 "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
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
 <20260811182012.GB2895176@google.com>
Content-Language: en-US
From: =?UTF-8?Q?Jan_Sebastian_G=C3=B6tte?= <contact@jaseg.de>
In-Reply-To: <20260811182012.GB2895176@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 8/11/26 20:20, Eric Biggers wrote:
> On Tue, Aug 11, 2026 at 07:52:49PM +0200, Jan Sebastian Götte wrote:
>> I'm using linux on an embedded target in a Hardware Security Module-like
>> application. One requirement is that I want the system to be able to
>> quickly erase its memory when it detects physical tampering. I'm
>> approaching that by using kdump to load into a small payload that
>> instead of dumping RAM, erases RAM from start to end. However, writing
>> all of RAM, especially on an embedded target, is rather slow. For this
>> reason, I propose the mechanism in this patch series:
>>
>> Add CONFIG_CRASH_ZEROIZE (default off), which when enabled makes various
>> subsystems handling secret data do a quick, targeted wipe of these
>> secrets before kdump. This behavior might also be interesting in cases
>> where you run a normal kdump kernel but you still want to keep things
>> like fde crypto keys out of these dumps.
>>
>> CONFIG_CRASH_ZEROIZE is a best effort, defense in depth solution. There
>> are circumstances, such as when a panic is triggered after memory
>> corruption, or when a panic interrupts some operation that mutates data
>> structures under locks, when the kernel cannot safely wipe some memory
>> areas. The handlers proposed in this series will just print a warning
>> and skip the affected areas in this case.
>>
>> This series introduces handlers for the major locations I found where
>> having this sort of thing makes sense. Notable omissions right now are
>> the Ceph and CIFS subsystems. I have WIP patches for these, but since I
>> can't easily test them right now, I omitted them from this patch set for
>> now. Currently included locations are:
>>
>> * various key types in security/keys
>> * rxrpc
>> * fscrypt
>> * dm-crypt
>> * crypto tfm instances
>> * secretmem (which I'm going to start using in my application)
>>
>> I've verified this patch series on an ARM64 target using the helper code
>> at https://codeberg.org/yasec/crash-wipe-test . This code stuffs the
>> affected kernel subsystems with keys and secret data, then crashes the
>> system, takes a RAM dump and verifies the dump is clean of secrets. Note
>> that the helper code is partially LLM-generated, so read with care. It
>> passes a positive control test with the config option disabled.
>>
>> The patch series applies on top of linux-next but should work on 7.0.0,
>> too. I've tested the patches on a Arduino uno Q (Qualcomm QRB2210,
>> ARM64) embedded target.
> 
> Can we not?  It's already hard enough to zeroize keys and data at the
> normal end of their lifetime in the kernel: that's something that is
> always a struggle, with fix patches regularly going by for many years
> and many subsystems never fixed at all.  If we can barely even do that,
> we aren't going to be able to correctly and completely implement and
> maintain separate zeroization code for every kernel subsystem that runs
> only on kernel panics and has special constraints, like not being able
> to take locks.

These crash wipe code paths are less critical than places where you'd 
use memzero_explicit or kfree_sensitive. They are "only" a defense in 
depth / hardening measure. For most of these, if the crash happens at 
the exact time when data structures are being modified or when things 
are being intialized/deinitialized, they can skip things so they can 
never be 100% reliable anyway.

It's not realistic to clean *all* sensitive data in the first place, 
since that would include plaintext as well, which would mean cleaning 
the entire page cache which would be too complex, take too long, and 
destroy forensic evidence that people might want to keep intact for 
regular kdump uses.

> This is never going to be done either, with the scope always wanting to
> grow to include other keys and data.  You may think this series covers
> "almost everything" but it's actually not even close.

I'm sure there's always more. In my particular application, I'm using 
this not for complete coverage (for that I have another full memory wipe 
afterwards), but for speed - I want the obviously sensitive stuff like 
keys gone as fast as possible, with the full wipe cleaning up whatever 
the fast wipe here missed.

> Could you perhaps narrow the scope to one or two things that actually
> are useful and can reasonably be supported for the application?  For
> example, secretmem seems to be the only thing you mentioned that you're
> actually planning to use.

I'm open to whittling down the scope of this series. In my use case I 
need at least secretmem as well as dm-crypt, which then pulls in the 
crypto tfm stuff. Personally, I could live without the other bits, I 
just thought they'd be easy enough to include.

- Jan
