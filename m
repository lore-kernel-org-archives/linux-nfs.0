Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795807307;
	b=Z/BQ0cbJQIYGjVAQgXkUnnrCXBfNLWcfKJygVl9TWnKaZKGUygwFquLRyFeCPBT/EHu3
	 mVt/eCriGOwp92nDXOJpVE2iRANGqYOdWNxOE+MIswgE3gVANIoao9AYoSydpdNAb+wjs
	 rr3067Q19QJC4C/tUpev7qTddnWYBwAzCY6WO0q6UcdJ2aLMQY+iGnKWDEVgmhzzKTgSs
	 QCVpJPgqDjgB6lefEdLsUe2DMDpS0L02nTwnCxwb21JJ4H7H9hTTp/8TnEKp+wxLFm9zo
	 5+niUhMELWCVu9b3RMX7JVZ/J7GQozMIEIGNLopkEB3OPEiXR+EuuwsS+Zth0FtYQkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795807307;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=reTqkGZupBkQh73g3yqn1gu6V1fswbd+YX+J5LKpphg=;
	b=3A7v88TpJN+TZgYhhlTB51bZpVM1ZRE234ZlWtqPLlNrduM3dff/WKCaNbfVXp2uA2Tx
	 kCqJTjwLYBCj27JrcSBgR7O8wU885CV5UOWkcpPUwZpEDKXwzsHXnXRphN9y8cxb3NgLd
	 lsXkzka0h/3y+6b1b96xid/PJTQ2mESeW5L2sofnPVQiXb0JKOv0WIxr/epnwvG6i+KWD
	 13fl6i0joEFSsORT5TRsI2PHf2Y9xakI4K2RrfWtxekYkXAas6z2J7cxiK99373VTuHCg
	 CBW49ljjEOPYmGQXV2R/aA9JfMrzoh0Pz2M+Rx6OGvhg2O4WmJfqFcxeNIbAB1fdVhw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fRzEgyqO;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=tkrU4mP8;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C59E606A31C
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 19:21:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C59E606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fRzEgyqO;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=tkrU4mP8
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795807305;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=reTqkGZupBkQh73g3yqn1gu6V1fswbd+YX+J5LKpphg=;
	b=fRzEgyqOO/u0pMr3fX7GTrfINCcVDLkfJ1SL+OH1OpY3aKKYYJGYsm8ax3WQKBU11xE2mO
	Rk41j8BxpNbG0UhqktyT5DeX/iba00hbAL2w9k/0e1qH5IEq3q5pPrkfh2LaCC6oq7j1IA
	Zygf4GN/ydN08jv6H4HFBGbQv200ftQ=
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com
 [209.85.160.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-515-4NJCJJsjP7e3v7IVS5wg4g-1; Fri, 27 Nov 2026 19:21:43 +0000
X-MC-Unique: 4NJCJJsjP7e3v7IVS5wg4g-1
X-Mimecast-MFC-AGG-ID: 4NJCJJsjP7e3v7IVS5wg4g_1795807303
Received: by mail-qt1-f197.google.com with SMTP id d75a77b69052e-5364f562140so154039251cf.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 11:21:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795807303; x=1796412103; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=reTqkGZupBkQh73g3yqn1gu6V1fswbd+YX+J5LKpphg=;
        b=tkrU4mP83B/rSlwpHzHo79BJevwc2EMlWjOqQdZX1VyB42Q2SgKqIFWi35AACW+RUJ
         e3uoLV4cFXPHnvYBrAw9ocJuP/RPb7rO8TsCbNx9pRLYzIvJ/sM9wP7hw2S/qCgoNi86
         67xH/HtPe4IRV1MKFmMx+Gon7+xmqCSaaxq+Kb7YNQoesdV7OgN08cDWN5TyB36JetlC
         KRegGqDvXGoSl8rUV2mqOa1wDEKcK8zXx2XPZwjPC1pUFXnky4Pgupxer+nYdRZ7cgVO
         zMr9t6cWQg40usNtGFuw7Vel4BnW1mjeXYPD3tSZXroTjL8jhm9cE3xWzmlj6O+2eOXY
         qJQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795807303; x=1796412103;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=reTqkGZupBkQh73g3yqn1gu6V1fswbd+YX+J5LKpphg=;
        b=so6KnFyTpHhKGjFEesdeEpNpoWwi8gYxjTZxawArV5UXmqbMbyzDX2qJrYzevG7yyL
         cclopAF4Zz+SISCtwitG2F8aHtT4LJx0Gflq0Ln3FWWUTjcZJwWqfaCOEHnooY71DMvh
         DHvR13fvPqPMMuf+g25QhkiT4HdVFPsCTQVeOQoR/Vtrl4rUecAs8GICbVy8f8CECEu8
         z8kowNWd2A5pUq1HAf2tN+LajIEAlbsmYDUvUisLZshW4OmnF5OImGniiQwtkAVcPXwv
         aRGBJ9y0Gf+Ys0EuO2BCV6xYSEPcAdwx8N0CYemMGK5aJj060qnisVD7W85UxtDtGxFU
         KFNg==
X-Gm-Message-State: APuU4Z+CRV8ULDQ/NH3OaHGAbK1bUTQaqc8oesxJCmb+c2Lt/lJkCXdb
	V4/rFKYQnTn6/OD7hJnjn8cbI8b7RystqfAGP1taqN0BFLh1MS97Dx0PxyglyLITzI7AH7I5HrH
	zmdsUR84QO5jhc4nPuKn4KcSerMwVF3YqUR0PAgKQydeydjS0aQGXIMF2rKiaMYR77jvwog==
X-Gm-Gg: AZFdTZeGaoa1w09Ri0WroZoZGnJz/GT6HU30CAp8zfZS7Nnnq/H4lC6bkrtez9ORacO
	+Ff3WjqMJdlW3EHdYgxcvKxANfoV94QVDhhtllAOWvGHlPRoMeQv196pgtIYMC55K5KYWs0ZAQC
	pe1qYQ5b2phsXBEDRJQczsBQV/nbI9Oe2uQL/nAVcxdbr60H4PcEEE1ixE8KbqdrpfcrJ1f1HPW
	iIFEv0Ufk/aAhvxsE54GFOxtpvxsDFJJdB9AF+32LL+peFMuGFTULEFBhTyGReiL9aqkhR4RYHK
	AOOCArzoUEZBDF4OJkFPPo4h3SjpCMRpTvNEWfUmoIoUL0Qoiy0K6hrxG2u9utRb+eEiToedf85
	1ZFTUYNl6LBGMxuRja9T6LNlRbv8Q2eKTubeCcwJp4tGZSw==
X-Received: by 2002:a05:622a:888a:b0:535:8559:3401 with SMTP id d75a77b69052e-55d76a44096mr454022791cf.28.1795807303274;
        Fri, 27 Nov 2026 11:21:43 -0800 (PST)
X-Received: by 2002:a05:622a:888a:b0:535:8559:3401 with SMTP id d75a77b69052e-55d76a44096mr454022471cf.28.1795807302843;
        Fri, 27 Nov 2026 11:21:42 -0800 (PST)
Received: from [172.20.1.138] ([8.9.41.138])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-55dc8895b8bsm37211011cf.10.2026.11.27.11.21.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 11:21:41 -0800 (PST)
Message-ID: <15377fb2-2e80-4509-833f-d0ebc882c0b2@redhat.com>
Date: Fri, 27 Nov 2026 14:21:40 -0500
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
Subject: Re: [PATCH 1/1] libtirpc: add missing boundary restriction to
 xdr_rpc_gss_unwrap_data
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20261109154641.55252-1-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261109154641.55252-1-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/9/26 10:46 AM, Olga Kornievskaia wrote:
> Add a boundary restriction to the xdr_rpc_gss_buf() call for the RPCSEC_GSS_SVC_PRIVACY case.
> 
> Fixes: 65d27459fe56 ("libtirpc: Bound maxsize in xdr_rpc_gss_unwrap_data() decode calls"
> Signed-off-by: Olga Kornievskaia<okorniev@redhat.com>
> ---
>   src/authgss_prot.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/src/authgss_prot.c b/src/authgss_prot.c
> index c7de1fd..620b294 100644
> --- a/src/authgss_prot.c
> +++ b/src/authgss_prot.c
> @@ -254,7 +254,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>   	}
>   	else if (svc == RPCSEC_GSS_SVC_PRIVACY) {
>   		/* Decode databody_priv. */
> -		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
> +		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, RPCSEC_GSS_MAX_UNWRAP)) {
>   			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_priv failed"));
>   			return (FALSE);
>   		}
> -- 2.52.0
> 
Committed... (tag: libtirpc.1.3.8-rc1)

My apologies for taking so long

steved.
