Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E54C73DD86C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:14:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789568079; cv=none; b=iFIlDLXFSQ0uIixwurK7bCFp0w+khp45yyYBBSdetX6R0t/LKWEZZv+iXxuYo3YXm1KmVGroswy9e3S/UvSQeTioejyrtIMJyKFKP1rAuUCNPC75wvAlckkW0y7kVhcOR+hh5iS38bKez+lia0eM+Raih0C7UPsZZxrHzu5uCp4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789568079; c=relaxed/simple;
	bh=Alre1HBcjz9YrMXvQ8x35dK+9Y0vZr8UrYcK8TXiplE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Qt+HPYWLx+RoxO6F1gw6UF75A0LNRnZXBReeKEPqtBurZUCNa4y9V/IxR+W5D+oyRJYrpuKOSCABW5FtmFbo+zOr3DYlMzujflrts1WaXECyWekPHH4xVpA+7lKZWEaA3r6kqUVFqC36B5X43NBudfnQFSx2OxAIOl8CHJXHN/o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ILG+0iAt; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=atsUz9wS; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ILG+0iAt";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="atsUz9wS"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789568077;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=lJllEd2R8t27X/lkB494X+Y8gDlf8tAMCuG+5upBSOQ=;
	b=ILG+0iAtjLdwPTwvbHMfRGLmywfNl0MXjSLt5cZ9CNWvkWL9BgvY6FgXYhB3d6WmqfreSa
	7PtWrfRbhRZSzLru6WDSLC7sa1u94QUabNbgWkCjoGP9xpRTZ0ktv2cAjJgjhQHn3RD2OB
	kB/CJsqPlDC5N4q1HpFgJo2jLRc4ClQ=
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com
 [209.85.208.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-561-4R9scvmNN4ev87s6iIAQwg-1; Wed, 16 Sep 2026 10:14:32 -0400
X-MC-Unique: 4R9scvmNN4ev87s6iIAQwg-1
X-Mimecast-MFC-AGG-ID: 4R9scvmNN4ev87s6iIAQwg_1789568071
Received: by mail-lj1-f200.google.com with SMTP id 38308e7fff4ca-3a3130365d5so30585091fa.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:14:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789568070; x=1790172870; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=lJllEd2R8t27X/lkB494X+Y8gDlf8tAMCuG+5upBSOQ=;
        b=atsUz9wSvz8so/EgCDirh3wn7mrisRE9nNnXJM3SSSwVNtw+gQel0rp/zzOp5LrNPi
         M9WQ6ZjmtZMVXtCWTFfD4pAzmOrJFSxLw3pfR7Gm7FNInBdb0DNXkp/rpVKM1T4gs/sP
         WtHZwjN0hiVWdKOmz+bJ1/0Rjb2ZwD9hUlSfWm59chh+OnVHjF/gexcUrVmJighYn1Qh
         NE0ijhLeuMliWP0gS15sURk6JKpJKuF6aEfXnHysPwHMew4kRIeWOcfR3WhtW+u1vrZM
         veY7cnWjar8rnMp5pxE1zxgEVo7Yrwi9o2Vg1WvbQ0y4Yt00VJBZs7yedeFC0WyW/Aer
         tZnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789568070; x=1790172870;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lJllEd2R8t27X/lkB494X+Y8gDlf8tAMCuG+5upBSOQ=;
        b=xao06FPFuZ+zU587RQjESWnPK5xfFnfikCAIk/MzVlcK4uQw6yh2KvGtiI7N+6Nomw
         g9/luymYH8vVxkawzwUAvetm/tjFE7EmbY7/Q7lvg7rUQoJpLKkwlwp2KtzcFuqZYAc/
         NulhDXApaME+ADW6AGdRPwxOieACBHFgmrICACkp8bBlbKh+4LbVUmbdu5CUj57ZYQA8
         imKUeJIvHLF+FDRwtLF2aQ2Bjv7Dw7BRNeCOB9CN34pZEFKX37zwYFqOUXMh2ZLaIDCc
         ZwOrHzrdDdAACqImgmszSDXVZj7dozjJCsc5m6IE+nXWZwFxh9md2ds+rxCkvpagBsb6
         A+0g==
X-Gm-Message-State: AFuF++no2t4c3+l9VQG61HPLnEUXRUGn3aDo5pTkIFdzrPDF136dX1yT
	mUaWlmnx0EI2V7DpJJu+oBa958463gCZbdqK88gPrnOpTbYXDWecN99e/psEK4VfJ4yaMrl8Xip
	1ZBaeRlr8g/JGdambnAIB8mYVEa4cwH541p3/wLJgkqzt3qPfFeWCKC6buk6gttMPfrDKcQ==
X-Gm-Gg: AYBFou0o+dIpwhflxmJMjopNBq/YQuBPNYq4pHMZ0EUJs5dxy+h1TdOJqVdIqxOfayl
	FhqkPe5261m/nuMeEMdMBafL1CKcVLrP4IbyaW08YYAagK8of0rXFET+SL1G4SyZo8EHPdDFGFl
	NodSpVWC2xj2BAbTSXko42FGEeBKrP/ysSob8XPx1nCmqxPX67UTGtt0qx4mIJNDkRogm/X9Dg5
	Aa0xzpOIrvGt1PsUhv1exapJ0dr3Xs4kLBTBtAUSueNhqd0dpyqOe1UAen9anghXwrpsOyAuSXa
	+UJugaExNoGt69otjqypA3b2dqXXteIfg/AKhDfgxrPafX+WWx8qvfIVrRzQZp02ib0i+j+w5Ig
	=
X-Received: by 2002:a05:6512:2398:b0:5ae:b887:bb33 with SMTP id 2adb3069b0e04-5b8b660cd0emr851226e87.1.1789568070630;
        Wed, 16 Sep 2026 07:14:30 -0700 (PDT)
X-Received: by 2002:a05:6512:2398:b0:5ae:b887:bb33 with SMTP id 2adb3069b0e04-5b8b660cd0emr851217e87.1.1789568070208;
        Wed, 16 Sep 2026 07:14:30 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5b8b57cc67bsm941549e87.31.2026.09.16.07.14.28
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:14:29 -0700 (PDT)
Message-ID: <a7ea0d24-4bcd-47fa-8ea2-c5fbc5ab5890@redhat.com>
Date: Wed, 16 Sep 2026 10:14:27 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] fsidd: replace assertions with explicit
 malformed-input handling
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903174847.1213636-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903174847.1213636-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:48 PM, Scott Mayhew wrote:
> fsidd relies on assert() to ensure that an argument is present after the
> command prefix while parsing commands received over the local socket.
> Malformed input can cause fsidd to abort.  Replace the assertions with
> explicit malformed-input handling and return an error to the client.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   support/reexport/fsidd.c | 19 +++++++++++++++----
>   1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
> index 51750ea3..f5c397aa 100644
> --- a/support/reexport/fsidd.c
> +++ b/support/reexport/fsidd.c
> @@ -48,7 +48,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
>   		char *answer = NULL;
>   		bool found;
>   
> -		assert(req_path < buf + n );
> +		if (req_path >= buf + n) {
> +			char answer[] = "- Command failed: Bad input";
> +			(void)send(cl, answer, strlen(answer), 0);
> +			return;
> +		}
>   
>   		printf("client asks for %s\n", req_path);
>   
> @@ -70,8 +74,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
>   		char *answer = NULL;
>   		bool found;
>   
> -		assert(req_path < buf + n );
> -
> +		if (req_path >= buf + n) {
> +			char answer[] = "- Command failed: Bad input";
> +			(void)send(cl, answer, strlen(answer), 0);
> +			return;
> +		}
>   
>   		if (dbbackend->fsidnum_by_path(req_path, &fsidnum, true, &found)) {
>   			if (found) {
> @@ -94,7 +101,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
>   		uint32_t fsidnum;
>   		bool found;
>   
> -		assert(req_fsidnum < buf + n );
> +		if (req_fsidnum >= buf + n) {
> +			char answer[] = "- Command failed: Bad input";
> +			(void)send(cl, answer, strlen(answer), 0);
> +			return;
> +		}
>   
>   		errno = 0;
>   		fsidnum = strtoul(req_fsidnum, &endp, 10);

