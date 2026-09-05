Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A741B19AD90
	for <linux-nfs@vger.kernel.org>; Sat,  5 Sep 2026 09:51:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788601864; cv=none; b=G3l3VrH7PBVspiWj86qXbES0HSD0nwsSWEi+eMQfVzS9Vk9g0egUSBsa06DPeUsdB6dlda541ykVC+ijfoy6yNSowbyO7KC51qkm6xDD0d9GCLu90h+ld5If1T3wuyY3ECxLe7fhGAuaASzICcH3rn5X8Vq8qY/IsH6D7YhVAg8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788601864; c=relaxed/simple;
	bh=DN2yPFSWcEMVlzdvJxHM+5bk+vzr1MDzXVLcKkbGkwk=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=cZ9upJP29GIX+wIXNmZpOZ1ndJOiUOVeb5xiIpOPOH/t4iegt0mROjLBFl3CiifIx0IWLujX/02PMo1dxROgilRXXijwj4ciGnA+ZxPktoiwFtCqS7zYi8XeLJoICrJ4EvyEez+3hh+R7FjGMoBeXUf64GQHrwUntBy9oJOtjE4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Cs3u1a+V; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=jAN/PRVi; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Cs3u1a+V";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="jAN/PRVi"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788601861;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=AN44RWddFKay0gRa8cvRWtXAizMwFJDgvkTOe5+GMRo=;
	b=Cs3u1a+VEGhEmLdEjhEh1NLIYgHOuimPZWa4PnCKmR+dOQu0oaaV3xdeeJ+29f72HtRntD
	fL51Aj5RohkxW0RCTqyiwJ4j+SMgpkvzghnYJzD6h/eBV9Z00rjiaLZbePD2V5GaIN7DtN
	5qwm3PnZqdPsf8ZSSMUOvmzbc4+ox44=
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com
 [209.85.160.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-75-W9YH1q9zOSS9fow4Ts4E6g-1; Sat, 05 Sep 2026 05:50:59 -0400
X-MC-Unique: W9YH1q9zOSS9fow4Ts4E6g-1
X-Mimecast-MFC-AGG-ID: W9YH1q9zOSS9fow4Ts4E6g_1788601859
Received: by mail-qt1-f200.google.com with SMTP id d75a77b69052e-51c1d137a68so58113711cf.3
        for <linux-nfs@vger.kernel.org>; Sat, 05 Sep 2026 02:50:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788601859; x=1789206659; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=AN44RWddFKay0gRa8cvRWtXAizMwFJDgvkTOe5+GMRo=;
        b=jAN/PRViW7m6arCuqmqESTNpZw1oxxX2GILngG4uPCYLLarBqzS47+aEycKxphhw8m
         xqp5pE6F1UIz9uo/EUvJcAXzpfjXt5HnWuJMZiVCnik+1S6FIy1Itg4oUVHjlQFvDCfD
         8uXX4niTVLxrcjD3TxMHeAsj5miP+fhzMgJg0nEqY8EaYjE98Xo+/826bbaOZs+RiQ+E
         BPR/8cgDO5R4lFJaS/inK/dsjHU6USONwFTGh21lqr1hZZ7AhTrAynoxzPjLv8E/sFG7
         u9Hh+dc32hOOolrrZh2FJXa+NiK0hGbRUMyo7C8D9mIIkX/sJBaVvX8fKiPaXXPqB/0Y
         ZTYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788601859; x=1789206659;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AN44RWddFKay0gRa8cvRWtXAizMwFJDgvkTOe5+GMRo=;
        b=UYmMfGAlvbgvRPAWuJexPu6CqeKv1wdMS56LiFpAwTVfxxbmEHeDvXTzkKBMAlr5CZ
         tt1pzsWCwliWO+YkW5T7I10I0mN0ro+S/DV54S0iBTT9sxNO8uzzqVbDeF7ClvfHfKa0
         zEcznLoOgbAvxJlaRmzCUKSe/MqbXEkCXCC8PnnWc2op0kO+Y/pWJ8JI0QEEd1pI7bTL
         oCHYnzMMTG+P9gbUsyJ5fldtfHczYJ2u4FPP4urYP9MbsO2Q02mv7lkCguXqrV0q3X7p
         SYcmqf7752ATq56zBCx0uObo6U6bfC0T9iikQPE0esx3ZKbU1HdFj6JVHYB3n0tF0xmw
         LVng==
X-Gm-Message-State: AFuF++lqhO6BEk6+6tqsmPdPXFluphfwp1EMr/bq5t2RxePHTMCy11kB
	8gNXWBVfVn1H1N1xiqNmiqjf89cA2k41FFoRYuFzP5Oam/aKvwcUDO69or1wmj5kUJgkUf2eg4d
	jmfGC3t5/OxVGxN3YxYONhljiNndXONNLjb9tdyzLku8r44DoLZZ1X5uN8DpV/A==
X-Gm-Gg: AYBFou3mkGsCibIoZI9ur6pVAubjVS7bUocs0j7976Z7GhZuirSW40vsy0HATTMm2UZ
	36yQUVAyIPKPABR2l1+bBw9VPpxtTfqF3vstn95v9dqpp01pl50XoiCg4q5FiXI6Q1GbMd6mPuI
	C7ChNAOQT/FEfl6P+AGky3e+1+06NgCaN1MMiv53xnP14Og2oGaPNd3LPszCfCJmR2zM+1Cizw4
	jBT1noNVn3x1FVtGi9h6CtDMhPc2q/2fufYRJeUjS4Kmh0ox9if1O4Y5eS1j7eXCQCRuiPz/8k1
	o7CVre6PimPzALd0bdoSDGo1Xqk6jXoQ4gLjsSzGUVyx9VDZ+vF3CVdjQV/CgFqBiheyRHP+p98
	=
X-Received: by 2002:a05:622a:652:b0:52f:a2b2:2dcb with SMTP id d75a77b69052e-530547c8236mr127181781cf.18.1788601859160;
        Sat, 05 Sep 2026 02:50:59 -0700 (PDT)
X-Received: by 2002:a05:622a:652:b0:52f:a2b2:2dcb with SMTP id d75a77b69052e-530547c8236mr127181641cf.18.1788601858727;
        Sat, 05 Sep 2026 02:50:58 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.245.121])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-5305413d7f8sm40390481cf.14.2026.09.05.02.50.55
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 05 Sep 2026 02:50:56 -0700 (PDT)
Message-ID: <c0d9ec4d-7f3b-4546-b0da-bafc76f14194@redhat.com>
Date: Sat, 5 Sep 2026 05:50:54 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/1] libtirpc: fix rpc_gss_get_principal_name to allocate
 memory correctly
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260821145813.27891-1-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260821145813.27891-1-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 8/21/26 10:58 AM, Olga Kornievskaia wrote:
> The calculation for `namebuf.length` correctly accounts for the separator
> characters ("/" and "@") via the +1 in `nodelen` and `secdomlen`, but does
> NOT include space for the C string NUL terminator. The subsequent
> `strcpy()` and `strcat()` calls write a NUL terminator that overflows the
> buffer by exactly 1 byte in all cases:
> 
> - **node=NULL, secdomain=NULL:** allocates `strlen(user_name)`, writes
>    `strlen(user_name) + 1` bytes. Overflow: 1 byte.
> - **node="host", secdomain=NULL:** allocates
>    `strlen(user_name) + strlen(node) + 1`, writes
>    `strlen(user_name) + 1 + strlen(node) + 1` bytes. Overflow: 1 byte.
> - **Both non-NULL:** same pattern, always 1 byte short.
> 
> The `namebuf.length` value is intentionally the *payload* length (without
> NUL) for the subsequent `gss_import_name()` call, so the bug is specifically
> in the allocation size, not in the length field itself. The proposed fix
> correctly introduces a separate `alloclen = namebuf.length + 1` for the
> allocation while preserving `namebuf.length` semantics.
> 
> Fixes: dec8d9775ded ("Finish server-side rpc_gss_*() APIs")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Committed... (tag: libtirpc-1-3-8-rc1)

steved.

> ---
>   src/svc_auth_gss.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
> index de2993f..dd7db56 100644
> --- a/src/svc_auth_gss.c
> +++ b/src/svc_auth_gss.c
> @@ -1117,7 +1117,7 @@ rpc_gss_get_principal_name(rpc_gss_principal_t *principal, char *mechanism,
>   {
>   	OM_uint32 maj_stat, min_stat;
>   	rpc_gss_principal_t result;
> -	size_t nodelen, secdomlen;
> +	size_t nodelen, secdomlen, alloclen;
>   	gss_name_t name, mechname;
>   	gss_buffer_desc namebuf;
>   	rpc_gss_OID oid;
> @@ -1135,7 +1135,8 @@ rpc_gss_get_principal_name(rpc_gss_principal_t *principal, char *mechanism,
>   	if (secdomain != NULL)
>   		secdomlen = strlen(secdomain) + 1;
>   	namebuf.length = strlen(user_name) + nodelen + secdomlen;
> -	namebuf.value = calloc(1, namebuf.length);
> +	alloclen = namebuf.length + 1; /* include terminating NULL for C-string ops */
> +	namebuf.value = calloc(1, alloclen);
>   	if (namebuf.value == NULL)
>   		return FALSE;
>   	(void)strcpy(namebuf.value, user_name);

