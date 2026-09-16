Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DCB15013B7
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:11:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789567918; cv=none; b=NyKNlpqAh53Pchajr420SpXXo8d8WB45gmTQRq3KboOinKDw0Vlvvyk3EKQbMb2RrAVuQ3woOvCUgqy1f8aYOE1I5zBm6ayn/MBV+8RjvYhWRsL7u+WBQ8JeOWgv7J1aSX7/6a/lU8sq5Ps83yUgrZs3k9HPx38tB6/MyrMNIjA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789567918; c=relaxed/simple;
	bh=ej0KDC3k0Z95BgBZcDOWVuPpE3tEoq1nJp+1oKvcGFA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=tIvFIcw9/xSAyZQ7VFarCAf9/eRes6BnGMA11Lq6e0ZInxPmyzdNJ9d5U0pzAaHgmH6LMK2H4Pg3BeS2AzMUhm339LzjZrz24N+fDG8Rm5ZJqAUl5HfMcx3866bFa7OB8MY3saaw2stef7Bs4egJUDcbz4VILbdH1NrXBU0kMC0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Vcs9eTzV; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=jT2mjt59; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Vcs9eTzV";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="jT2mjt59"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789567916;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=E4s9Bxx3YsL4QT2ErZUrs6fj3jBjz8TM9MaUljsefe4=;
	b=Vcs9eTzVlZFwl9XBg+kDJadILaj5577Db4NG5XdW+Dsk/VwU2VnY81QCVB090LA0t5vgpn
	rVv3xub7dgEavycT7BfbhQrrVA4k2cqYo+AIKsI1BVgyTRmh7ZpCR6faeDxKJzgtpbE6D8
	coDCGDMzCO6pV+cmgArXbmEI/rK5KMU=
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com
 [209.85.208.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-155-8Of6vtSoN86p0GF2Km4W-A-1; Wed, 16 Sep 2026 10:11:52 -0400
X-MC-Unique: 8Of6vtSoN86p0GF2Km4W-A-1
X-Mimecast-MFC-AGG-ID: 8Of6vtSoN86p0GF2Km4W-A_1789567911
Received: by mail-lj1-f200.google.com with SMTP id 38308e7fff4ca-3a49dcb2b24so15523081fa.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:11:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789567911; x=1790172711; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=E4s9Bxx3YsL4QT2ErZUrs6fj3jBjz8TM9MaUljsefe4=;
        b=jT2mjt59wTEtUoeGvYlHm2iihXZtZCNPc0cRrvPFsvmnumXThhivol6ob7Y9gqR93I
         TYjsD6Uqs6fNP9QX7jIe3BXLv4LIgVyl8DiQkrfPJ04cmysvtsKRK2e85pRExVcZ6IXY
         CDfG6RQq0ZGVCK1l/BC34AHv/cuQLDuS7l74uF8HGIbblYaWNrvCWF1edb5Tka3i5/+M
         tjQJcQSUmbcfxAAf9CMTfuaW8VYQlwTonngUX7fKxVJhV9lg1oLLqXQiCRPEWQEwwTiw
         mveJhkxDjJ+1DS5r9aUjmf8MnbSrySWYs2PzzS93DXDI+cVs4bWoAW4FZqx6+a5wBd4I
         OzyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789567911; x=1790172711;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=E4s9Bxx3YsL4QT2ErZUrs6fj3jBjz8TM9MaUljsefe4=;
        b=LpmI2NHS45FoeF0eRv6/WRjQFi4HbdTBvT/GJHorCQ0sb3XNFGVxc9gN1pY8WctnB6
         Yi8vFDlRqoFkxFEJOQMwBo7+p0Axsy7gvTzCDK8MJyQuBe0bQtDmSdc0fSoQWd0beUGK
         7YgbmgGUH6eBRtv0QHfSDYH09hRN2azqIW0h/HM64l1sFmnqASuRHc4t73Bb4/skN1Z5
         bXWJAu5FGefpvZgkNfBH4B6Bfv0QH9Ab5CGa3XSYY25dxs6Vf2UT+gm02IPnwPoG2zvP
         vg5Ud4885qum728KrnD0suSBiLXuePQyF5b3DNEQzat5CjD5jggMqqcpzh29vm4lmYag
         Cv2g==
X-Gm-Message-State: AFuF++lH8W6wO5QV14IWkvhtKJOm9Tz29UzqJ8eUPUVasR/LnBNCkvyN
	54dBqJrDs8G2K2J97hUYE4yc1SGmF8IZFLQwzS4mXgOUGezbCGl8Y+jZg9Vd3BgU/EfGDmi2CF5
	XjmrUjygFhJPPTywkjpaamsyx7d4ShTSYQhksHiItbr7gt43kG0ZnDIeEhWvrgw==
X-Gm-Gg: AYBFou29F7WWzcBTfP3uaLIOUhb54ugG6Z9EH/MgS+8X3K++6/OgFYSbARj9ksLKawr
	iBDStLWxzQ/URQzwtp9Xo5vNKYSP6Y+tgJQUNYdv0eVJp/WK4vTwVrErkGS96bniLILhzgNBJTC
	6/ciDh7LQzkbo0ccmOawG3AIC3v+PW2dYlByYewH4kjgWVPp1XHoX7hxo2aF29NkYTX4f7Ssn95
	xF5JvEa6T9SucLpQHBlugKDektQmBUKJWNbmCvwDEsFbCHQ+zUEFRPFu7VXAFhDZ8+CWoiAFPQv
	ZKX2eg8bR9jmuuP9KOD8A5Lu8utx5BbyouvITGwXhckzgKs6CgZJ+K5Lf1cCR01Vk7euPGaV1Tg
	=
X-Received: by 2002:a05:651c:a1a1:b0:3a4:82b7:bfcf with SMTP id 38308e7fff4ca-3a5d16818abmr13062231fa.0.1789567910681;
        Wed, 16 Sep 2026 07:11:50 -0700 (PDT)
X-Received: by 2002:a05:651c:a1a1:b0:3a4:82b7:bfcf with SMTP id 38308e7fff4ca-3a5d16818abmr13062151fa.0.1789567910251;
        Wed, 16 Sep 2026 07:11:50 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 38308e7fff4ca-3a5daf95edfsm6930901fa.11.2026.09.16.07.11.48
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:11:49 -0700 (PDT)
Message-ID: <a8dedaab-758f-4ea6-8adf-b2fcfa262e17@redhat.com>
Date: Wed, 16 Sep 2026 10:11:47 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH 2/2] junction: fix use-after-free in
 locations_to_fslocdata()
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903175313.1214070-1-smayhew@redhat.com>
 <20260903175313.1214070-3-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903175313.1214070-3-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:53 PM, Scott Mayhew wrote:
> While parsing a multi-location junction, locations_to_fslocdata() sets
> last_path = root_path and then frees root_path, leaving last_path
> dangling.  On the next iteration, strcmp(rootpath, last_path)
> dereferences freed memory.
> 
> Fix it by transferring ownership of root_path to last_path when they
> should be aliased.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   support/export/cache.c | 6 ++++++
>   1 file changed, 6 insertions(+)
> 
> diff --git a/support/export/cache.c b/support/export/cache.c
> index 059f48a7..9f71c1dd 100644
> --- a/support/export/cache.c
> +++ b/support/export/cache.c
> @@ -2806,19 +2806,25 @@ static bool locations_to_fslocdata(struct nfs_fsloc_set *locations,
>   			}
>   			remaining -= (size_t)len;
>   			ptr += len;
> +			free(last_path);
>   			last_path = rootpath;
> +			rootpath = NULL;
>   		}
>   
>   		seen = true;
>   		free(rootpath);
> +		rootpath = NULL;
>   		free(server);
> +		server = NULL;
>   	}
>   
> +	free(last_path);
>   	xlog(D_CALL, "%s: fslocdata='%s', ttl=%d",
>   		__func__, fslocdata, *ttl);
>   	return seen;
>   
>   out_false:
> +	free(last_path);
>   	free(rootpath);
>   	free(server);
>   	return false;

