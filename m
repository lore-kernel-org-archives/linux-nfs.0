Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D55F3DB337
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:10:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789567845; cv=none; b=pD9eoMLHITIG5rK2e7nkk/f7krrswchApBTjJMY1p5JoAQu3TSuWIDld2Z2TjaXemGW4tZit+4wt9Bw9icuEeGpsEAEKjIKpbBPmJLlJNsDSM2fSpDZZ/uWnvzRpv6ADEkjkU4AmLV1MOjyPu1EW0Vm6mUI2SeT0g0d8jidJoUc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789567845; c=relaxed/simple;
	bh=tWO/i/+i09amkUFwPA+eX/Zgy+VSzpIruBlOY3acr7w=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=hwGxdEC3eXEifmDaFMC+5wI9FaaM0XjCMqBBw9aybMwm9F9N94f2m111joRlFGTqzJ5EbNtFaEkMVlQYwQ6mAqVhHZhZY/8UU5/0q41hV9O2X41ULG+iO7uR+0X/YcmXbh82m/ZzRLUeNN/Y2jHcL681AEDKzcA2lAe8WC8/PDI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ZiTGZkS6; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=b0YpQK8L; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZiTGZkS6";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="b0YpQK8L"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789567843;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EjDCJB5cp1SMf9kcPGUmyS/Z6HVxiHf7yQiCMJVGnYo=;
	b=ZiTGZkS6yV6rewyuPkrfO/E1frHDd9G+ONPprHmt86K8KxSWZgRe+odPItFFozKfAXsgUk
	CCnCukB1FshyAZz96GO29hL14zpSh5ovJW+Cm1WkVteP2VRolnil+1mSY0r2mII6C5nrNr
	Uh7C8wDd48O5FN1pjcxgqCIWRuVoVBs=
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com
 [209.85.167.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-512-CFLxsi6VOTiiY5GOW5BxPg-1; Wed, 16 Sep 2026 10:10:41 -0400
X-MC-Unique: CFLxsi6VOTiiY5GOW5BxPg-1
X-Mimecast-MFC-AGG-ID: CFLxsi6VOTiiY5GOW5BxPg_1789567840
Received: by mail-lf1-f69.google.com with SMTP id 2adb3069b0e04-5b4ab63ee90so400515e87.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:10:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789567840; x=1790172640; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EjDCJB5cp1SMf9kcPGUmyS/Z6HVxiHf7yQiCMJVGnYo=;
        b=b0YpQK8LcliqA+fNTUbzJifnfhElDOov3d/7G5KPJtBmCWlTw73GVsK1PRONibtlJZ
         EUaaLQlZ1675uYE7eGRP/UAzegUEi3g7yzzH1xYP0GWyoC/kDmu/+Kzt3nNMChl30L9+
         VK44htNg1UFuRWQBH5eNoHmIYzadKNHCFj1YiebiKWZX0oDXljlChocTkUVxdgFbCI0w
         vBezUylnOk25ugIV4qvF567siGp5Un+hIBNqGiA8AAFgOF5v1bkXjiexGDSvdb9eUeHW
         bejXQr6gaDyeVvdIiXAn6rBt16XMDstEaUQc8BYtmRWJJJwx/JRTQjVcwwggqlMoWkMh
         KnFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789567840; x=1790172640;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EjDCJB5cp1SMf9kcPGUmyS/Z6HVxiHf7yQiCMJVGnYo=;
        b=2OypMsz09AckM8nphA5vmAqD+t2pZPDyeWXo9GsGkX/CXckWpoNryhxBdXqmsXde04
         yS930URkdv36T1Ukc8fJl27mjgy5V+zqA3ydfZ1/RO1FGghsZ6JhTifmHXiHOnzr6zUs
         ool0ihgUHhet2tnzO7YAvTzH7Ubp6STuW8NlrzKA3z7oQspYrtvk1jcbjfVxTNx48++W
         yaWDLCO/1/xtlIvNGSdl7OBADrlvGg3ugNKVAW7AC6cDWf52nex2b7noCBobkJKzB+xN
         rJLRxgm6SzI8wJuAvcoXzTy2gTT0HCo1XlPcG/FXlF0iyYT9PHcPoJyXdeCQ7qnyk7vJ
         RVIA==
X-Gm-Message-State: AFuF++mrF+2aAxOdKrgfd0WAP1/jSjD3BTPM8Fr/sx6AablrISuD+62b
	dlLN/r9hSe3WPLWB1p8iaAuizvJBvDHVWzPGaqUGle/FhBXMiwpc7K5sn22y4Mz+1aegqc5AEwn
	nunKgOmtgsV+blNexxovAvptJHGG4zKKoD2c/z3RDm9yRLV9qI9UEKOShVtHEL46uuUboPQ==
X-Gm-Gg: AYBFou0iyeZJXV06h+wQ66/uqz0AOVG0M9ZFglacYdnZyPgOH6m6UjFdNBk4kROAwSR
	1ENg2TQ8YaukQ7iBByjnLgGJ+AbkgXh+AzeK0TdRmN3cBCRcQPyqBCHyuNP0D/Qe9MH0Drnylvi
	Kos2hHgDi7g3wZbLhkMGBMYPvJlxps8tkslFZKTjkRYDQAaT3gVT58gYT/EZPoG+zkThOxWWASS
	R+JRXRW6Ol145HJpDQdIxJJnVwCGu3VD75ELEkZlQKtijlP6etwTswakgQcpvSzgraTUHLL2PNn
	9IAU5i1XOJEy55m3LZlUFuGeCMhi6rseQJZoYXAK/wcDG9XFkVrFAbaR7fInBeAQpi8kkWVXWsk
	=
X-Received: by 2002:a05:6512:3a90:b0:5b6:183c:5c9b with SMTP id 2adb3069b0e04-5b8b665e866mr917743e87.57.1789567839976;
        Wed, 16 Sep 2026 07:10:39 -0700 (PDT)
X-Received: by 2002:a05:6512:3a90:b0:5b6:183c:5c9b with SMTP id 2adb3069b0e04-5b8b665e866mr917733e87.57.1789567839478;
        Wed, 16 Sep 2026 07:10:39 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5b8b57c3b81sm924396e87.20.2026.09.16.07.10.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:10:38 -0700 (PDT)
Message-ID: <11e1e8e5-a092-4db9-902c-fdb595a59d0d@redhat.com>
Date: Wed, 16 Sep 2026 10:10:36 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] blkmapd: reject zero-length signature
 components while decoding block signatures
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903175448.1214235-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903175448.1214235-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:54 PM, Scott Mayhew wrote:
> A zero-length signature can cause blkmapd to map to an unintended
> device.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.> ---
>   utils/blkmapd/device-process.c | 4 ++++
>   1 file changed, 4 insertions(+)
> 
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index f53a6165..a47cc36e 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -81,6 +81,10 @@ static int decode_blk_signature(uint32_t **pp, uint32_t * end,
>   		BLK_READBUF(p, end, 12);
>   		READ64(comp->bs_offset);
>   		READ32(siglen);
> +		if (siglen == 0) {
> +			BL_LOG_ERR("0 length signature component\n");
> +			goto out_err;
> +		}
>   		comp->bs_length = siglen;
>   		BLK_READBUF(p, end, siglen);
>   		/* Note we rely here on fact that sig is used immediately

