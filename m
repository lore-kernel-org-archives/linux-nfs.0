Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 654C58632B
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 03:48:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789271315; cv=none; b=u6JaineaNIZwU/oGNN7L/s29UxJEhL5MxX7xpIRnYPxDlJKJ7rIN0jJJEFrOeSdRxZp1pI5j6eojSELeTYADdAaS07I+RNx5QiSl2EBG3kSIjVI2nrZbE/qYnGJ7go/AaFti3YrPZW84k/YfvEuE67J2U3zPLUwkkytnLEZZTzI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789271315; c=relaxed/simple;
	bh=OKZZrLFaJ+P7We9hjk9PGwFlZR9ypZuqOf8vqNhL2W0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=OPGOhb01wuYpKypGnUU1G1rB6Gztc5mjUbltewXb0kpgj19AFVd6v+yadU2TR+Mi35TmHcTBvlaspnGcsArmyZMzps9l0/QEgyNCWqPHjzlDF86lGtwU0p2JNFUqcxU/UMB59iq5tuETWzC5pX4NmJBmcMJNRz5ZilAkKpfjI8g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=GPDUEvoz; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=f0JcKxlC; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="GPDUEvoz";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="f0JcKxlC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789271312;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gX34j7aaTCiCoa/dVbblRTv6w//4QeR1GGOMDblrY+A=;
	b=GPDUEvozO+5+oopcIIUIoErN79y+k2pTSfqC7v9/ctgGzwzjIQJUb0HiThNGXHooBGoLug
	kX1zcwDcFHH8Hhf72TINtXYFxWimP2HcQD1bEXYYuxHVmPpQJeGgCcZs4IiVgjOjy+gWE4
	zGFx3UxVUWRP2rKAquXAp0Y073eVlBw=
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com
 [209.85.160.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-591-24nGoAX4Pumb6nPDrQ6h0A-1; Sat, 12 Sep 2026 23:48:31 -0400
X-MC-Unique: 24nGoAX4Pumb6nPDrQ6h0A-1
X-Mimecast-MFC-AGG-ID: 24nGoAX4Pumb6nPDrQ6h0A_1789271310
Received: by mail-qt1-f199.google.com with SMTP id d75a77b69052e-52fb8f67601so31428101cf.3
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 20:48:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789271310; x=1789876110; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gX34j7aaTCiCoa/dVbblRTv6w//4QeR1GGOMDblrY+A=;
        b=f0JcKxlCWpXExovOtxlTdzPUlrOgcoK34878kA1W8LWDEyuFSfVWBa9QaPnv8GxFps
         znvai9IeWxkclV4i4L7LKeKfgq4SIE9mPcZD1HusbEqdcz8NYB5S15eFYjaYdrHDlcuU
         R8L6akKXECv83drAFgMLeIAh8Jm/D+Qq8SECkZBtryc00fe8y3MZLa/8GRyzagccrJPg
         iAzCHwxqcfzjeB+jAxUQUcWYCk40eus4S9cD7pcAaZnkbebYnP9Izq8g5JhW2pAV9DeY
         2HfJukRT0L8/FmdxIQgdQ0QV4Bzzd3yCvpGQgek670W0OfJX2ILIHX5DFFd17tJutQ/L
         /qDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789271310; x=1789876110;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gX34j7aaTCiCoa/dVbblRTv6w//4QeR1GGOMDblrY+A=;
        b=En6bxhLEXfgOebLCzB9M0Xi50B4Ztk3oh5zJv9/5QmIx21+djn4D5MVcICA4V7XKW0
         DD1yCNGebAZlmmTXnYWD2XN4e/nPXt3NuOPQrOwxV0WmUIZH1+oIOB8ONtoEjjrXvRJz
         S78Zav6A6w+GOWGkhHBmHAfWiHfK/e03QmxWgEHKjWtgnF+V94GRFL35GEfUYvmagDwA
         f4b3afx0Jq3U7x1m9ApltGfZ4AnBtDqCfYM2lAEG15E1LVW5c7dizqYR2CdbdhwXdaaN
         VQvp/Wyp5Fn6U/nNt1JCViitN4ii5LRBvo1k/+WAQHF9/hWnbKy6yD2LKdQIB0pL9dKu
         HdMA==
X-Gm-Message-State: AFuF++nHSVx9m4/NLIKyLGFVqzEJg5ou+TeA2eUAIlwstRQoaAzRsRSR
	KiOBPjfW7q1K7c6/JWLWolZHlRAmZUCFaIL4igjZt/zoOWRm6WNvaBxT69/PCJdB/t2mDxubodK
	phS8toBJJUPWwZc8VWmSJUSfPFy5r4qIaESozS8jVISwng3YZZ6Wp2lkX2P6DRdQNDrniDQ==
X-Gm-Gg: AYBFou3tEYJtPX2p9dQClMfe/TJwEqsEsh3BwAXIJuTX5JeitVVdVZo/IGrFI2dndoH
	zbhiQMmMeEmN3z63xlcyCE+9hu4eqwIG5jErbpmEsL1FRoR03tcVrKnVNI3Ughw9YFNoD8F4p5i
	CybqM5qxt8IT0VnCCF0Uy1SLFP1RgHfEx/4oONAbbjtVRq+1MBwBNzJ9HXLX+AP2ub8Ym9zjOuq
	P7eZQFHsws8qyNsYH2/e6OlTlrHV+DQaOapJmam1zLAoJ3WUa1kailb/+wPfUhXa0iD71NuWle9
	pCr5L0QkDfemToFFGuQDjBvgTHlOHtO6IlKXdJ3BTuFXCxGf5wOnduO0nKZ+Tgj+xHPi1skADZk
	=
X-Received: by 2002:a05:622a:1393:b0:530:f497:fb38 with SMTP id d75a77b69052e-530f49814fcmr52696181cf.29.1789271310298;
        Sat, 12 Sep 2026 20:48:30 -0700 (PDT)
X-Received: by 2002:a05:622a:1393:b0:530:f497:fb38 with SMTP id d75a77b69052e-530f49814fcmr52696021cf.29.1789271309887;
        Sat, 12 Sep 2026 20:48:29 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-530cc781402sm59745181cf.7.2026.09.12.20.48.24
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 20:48:29 -0700 (PDT)
Message-ID: <615d4be5-ff52-4a61-a8c0-f06e4d6e861f@redhat.com>
Date: Sat, 12 Sep 2026 23:48:11 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/3] libtirpc: Fix use-after-free in xdr_pmaplist()
 XDR_FREE path
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260907011328.21425-1-okorniev@redhat.com>
 <20260907011328.21425-2-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260907011328.21425-2-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/6/26 9:13 PM, Olga Kornievskaia wrote:
> The XDR_FREE loop saved a pointer to the pml_next field inside the
> struct being freed (next = &((*rp)->pml_next)), then dereferenced it
> on the next iteration. This reads freed memory.
> 
> Adopt the same pattern xdr_rpcblist_ptr() already uses: save the
> value of the next pointer before freeing, then point rp at a stack
> copy.
> 
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Committed (tag: libtirpc-1-3-8-rc2)

steved.> ---
>   src/pmap_prot2.c | 12 +++++++++---
>   1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/src/pmap_prot2.c b/src/pmap_prot2.c
> index bbac74f..7611bd5 100644
> --- a/src/pmap_prot2.c
> +++ b/src/pmap_prot2.c
> @@ -88,7 +88,8 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
>   	 */
>   	bool_t more_elements;
>   	int freeing;
> -	struct pmaplist **next	= NULL; /* pacify gcc */
> +	struct pmaplist *next = NULL;
> +	struct pmaplist *next_copy;
>   
>   	assert(xdrs != NULL);
>   	assert(rp != NULL);
> @@ -107,11 +108,16 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
>   		 * before we free the current object ...
>   		 */
>   		if (freeing)
> -			next = &((*rp)->pml_next);
> +			next = (*rp)->pml_next;
>   		if (! xdr_reference(xdrs, (caddr_t *)rp,
>   		    (u_int)sizeof(struct pmaplist), (xdrproc_t)xdr_pmap))
>   			return (FALSE);
> -		rp = (freeing) ? next : &((*rp)->pml_next);
> +		if (freeing) {
> +			next_copy = next;
> +			rp = &next_copy;
> +		} else {
> +			rp = &((*rp)->pml_next);
> +		}
>   	}
>   }
>   

