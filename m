Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3F0A3016F5
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 03:49:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789271353; cv=none; b=CX2exW9WNsoMdVbAQIE8h1iOD210xuzfJEZvdsU9f4PeZcu1xXe9tENG40lkNjbol6I2glodPyvord4uAKewEeEdy4ZNb0RKEuMc8GrWsOUzVRp5jxiVRtQRPnCmHu59sgZOWsBp7bchb/fIqRTI4SwyzZIUqU1SwIIiXnH5Mtc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789271353; c=relaxed/simple;
	bh=Dsa49IJ6ZZtAni3J9Q8UgW6E78Ri1cLTrJVcFmyHlKU=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=KFiXf5euoWO+VWo0tttNzR9CbGEsAtDPLa8ydl99RkJjDoFI+pOyQTOX15fyRxTgTi7zHx+ktK0kX+iSZeV/grAidU3kpGo4HImFeTUysNU9cIxbGiraqR28rEYq4fxy6ZVixPPuAknZc3SAA190oEbKg074HMmhLILgXx6ojtk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=b7GcrJLC; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=UrGX/Prq; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="b7GcrJLC";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="UrGX/Prq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789271350;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=QnILda800/dRn2uMvCGmoMpSL6q7npRsrTcaVIY7w8g=;
	b=b7GcrJLCqoFz3bWopHtyAeyp+3Hf30+8DiLaXM3mZQK5rOTGqJJM2RS5CmftuzSy0TeRif
	D2dKdhwKDD3CcUXHleyabRUhGffnbweUqiU4ZK6dZtu3OhhDEsTPztNJqwu8HNtJ1X/OSr
	oxgfWwhzpBPBWRrS64EkpK70KnuXZsw=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-402-K-1P6o5ZMwyMXHHY7fm2yg-1; Sat, 12 Sep 2026 23:49:09 -0400
X-MC-Unique: K-1P6o5ZMwyMXHHY7fm2yg-1
X-Mimecast-MFC-AGG-ID: K-1P6o5ZMwyMXHHY7fm2yg_1789271349
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-90ce8ad8002so48771046d6.2
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 20:49:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789271349; x=1789876149; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=QnILda800/dRn2uMvCGmoMpSL6q7npRsrTcaVIY7w8g=;
        b=UrGX/Prqa3yQdKOaZ6DcubDX5nu0ZiDCBjUIeusc+OFaWYeZDZ2ML7TSr/toQdoovB
         YMSGfIwr49pb3xGfJ/5Owzb9zB6z3JHRdVqdW/z5FwUCICHaA75e0LrlMh3zH51YQYsl
         AQmhHz2erEPFV0JylllmNYFb8nJJEfgEkolOPrpq21Qom0Iatg/PZLumoaR3UI7WN+v5
         Y3AHeb2v2oR4o1ahR6g8z3vFWIzxAkWrKlgg8ijs5282hqpu6yZkPqlth9lThQ4GVvPR
         B8hjYT7oawHi9BVsM7LlJTFJD4UME1FEF6FfUWHyig+O0oOJVUzXaIoOYuGn/ohIudau
         Dhng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789271349; x=1789876149;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QnILda800/dRn2uMvCGmoMpSL6q7npRsrTcaVIY7w8g=;
        b=cDbYVihZXXVHQLi0Cei0TRoceYqt5a4ZUsmdrlhkpabqbxsDlRAqIMCIZXUZJKlfgn
         XMsgISLsf9iWNGSnGe0dkIQYgYuA9ND3R+QhdsZjl5hojty7vEG1iflAc8cgqmjp2SLj
         i0xn8M80Ch0dOkSO7R8uwraGay+nIsVjf6apC6VjwGdRWkiC9gotaai6T/7jKR8iJHdp
         K1qAaydOJCQvbFKUrnbDTHUFX4DeUkatBT3sNVK35s6agoFHNe0MpY/j9lzXSOqKdU/9
         U1l6t6+NxVoRJY7P968iNP43OV79d+zUt0dUMbkIYUP2SU51P96qvCN7KeYCDO3D6Ssy
         8iaA==
X-Gm-Message-State: AFuF++ngWJ1VYKyVz9T40KNDcO0Mt/0weCWpHh/+p65sqPyQPXfkmSU+
	O9/Gx5MfslD0YEP5lflhb4FKxi6szsvEjfvEv5I3Mp2NZYBUOtB3B7MKptiJ0WrY9PvlcK6x5Os
	ft3aUbw6WekhANCDFMF22ajESHE1hrjdn4iqvx8giLAhfvCDnETOS7A3Aq1QoabYuic+uag==
X-Gm-Gg: AYBFou0PrHZZXB6Q5MKtO+neqvZxsI+uUnVyt3bEa4h+qgji7xFNpXIC25qOfjNm+O6
	VlKOtRdpraEs6HTSEnyqK3LcU4zjFDFIMNgqZwuE2Bh1lvvf+54asDCY7Oe2B1fG7pfSlx1Obco
	1n1rAT4l2c144bDk2v6AUX/5Q0A7h6LGFaLf51TbcMmhaDd7mBCtnOO9TFgCoF8bAJY35OSNlqP
	ymhR89NiTmz+4L4SHyNoTMkmBD9BWmVoL15pHe9Prh24F7lREQWcRIyCBBTtichx5f+kX5oG4jT
	nn0J4V6PLaJfXXT4c1J8htpelENVjs5xaMEiD9PxzMH4VthK49icGxmmYKb8q1pQqGAYOYYrEU8
	=
X-Received: by 2002:a05:6214:2685:b0:912:bed:c74 with SMTP id 6a1803df08f44-9121da7ecd7mr88648536d6.30.1789271347996;
        Sat, 12 Sep 2026 20:49:07 -0700 (PDT)
X-Received: by 2002:a05:6214:2685:b0:912:bed:c74 with SMTP id 6a1803df08f44-9121da7ecd7mr88648376d6.30.1789271347620;
        Sat, 12 Sep 2026 20:49:07 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9120f4d51f4sm60653656d6.46.2026.09.12.20.49.06
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 20:49:07 -0700 (PDT)
Message-ID: <01ccf627-aeb4-4fdc-a624-ccb668d60f7c@redhat.com>
Date: Sat, 12 Sep 2026 23:49:05 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 3/3] libtirpc: Bound maxsize in xdr_rpc_gss_unwrap_data()
 decode calls
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260907011328.21425-1-okorniev@redhat.com>
 <20260907011328.21425-4-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260907011328.21425-4-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/6/26 9:13 PM, Olga Kornievskaia wrote:
> xdr_rpc_gss_unwrap_data() passes (u_int)-1 as maxsize to
> xdr_rpc_gss_buf() for all three decode calls (databody_integ,
> checksum, databody_priv). This disables the length check in
> xdr_bytes(), allowing a fabricated length field in a small RPC
> message to trigger a multi-GB allocation before GSS verification.
> 
> Replace (u_int)-1 with RPCSEC_GSS_MAX_UNWRAP (16 MB). The encode
> path already uses bounded values (wrapbuf.length + RPC_SLACK_SPACE).
> 
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Committed (tag: libtirpc-1-3-8-rc2)

steved.
> ---
>   src/authgss_prot.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/src/authgss_prot.c b/src/authgss_prot.c
> index c2b25db..c7de1fd 100644
> --- a/src/authgss_prot.c
> +++ b/src/authgss_prot.c
> @@ -51,6 +51,9 @@
>   /* additional space needed for encoding */
>   #define RPC_SLACK_SPACE 1024
>   
> +/* upper bound on decoded RPCSEC_GSS wrapped payload (16 MB) */
> +#define RPCSEC_GSS_MAX_UNWRAP (16U * 1024U * 1024U)
> +
>   bool_t
>   xdr_rpc_gss_buf(XDR *xdrs, gss_buffer_t buf, u_int maxsize)
>   {
> @@ -227,12 +230,12 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
>   
>   	if (svc == RPCSEC_GSS_SVC_INTEGRITY) {
>   		/* Decode databody_integ. */
> -		if (!xdr_rpc_gss_buf(xdrs, &databuf, (u_int)-1)) {
> +		if (!xdr_rpc_gss_buf(xdrs, &databuf, RPCSEC_GSS_MAX_UNWRAP)) {
>   			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_integ failed"));
>   			return (FALSE);
>   		}
>   		/* Decode checksum. */
> -		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
> +		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, RPCSEC_GSS_MAX_UNWRAP)) {
>   			gss_release_buffer(&min_stat, &databuf);
>   			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode checksum failed"));
>   			return (FALSE);

