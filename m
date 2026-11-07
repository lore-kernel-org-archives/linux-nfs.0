Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794071770;
	b=aJdfYONAJ3wROPcY37uSP0Zjvp2NxjQZ6aEqvO/tmsQWRsKrcV3fpm+Z5Egcu6Ca93i1
	 z5EvgQWP3ObWMo//NIJ5Fujer15xmranA9hHARjldMzuxyAxSEOjpQg6aE8urrgfE20Gs
	 FzJpJwx3+t1LJV2PJTt5oZ+aj3F7Egn8hgurRkziGZvtcJ5u+q+FV1lNla2fH73CSdEtb
	 ymwnJKfxbzKR3VsbXuofaaCKRLzp9avLeOxFcpDlJ7miFQacP8nPcA0yqylj/h7e+O3cT
	 C1AfwxDaY6DB2o/E5ET184iO7U8S5ooRJGrup+AWMhxjSDdmHzrFVWd11dEcQRnqMmg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794071770;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:Cc:References:Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=GF0VNIBACEThthZfLlmyD17qs+vnUlg/+DboLoTRmA8=;
	b=xbFiakX6tbNNLLPy1TsCYjqrqYSzvaPRdqHHSsHXZLSCpQBExMaTpiOEizYwh5GGOGN5
	 N4XDFfBLv4uthU+e51BfTIhjOSxkxQmQeWXjJHNhjKbfy7Q00z21SmQelLhWEY5wyCHlI
	 0GDcQtos4wKtfEmkOoGqzeeRyfAoDLv8HXCTflX+kyYxX4cErgI4jr5uRwxnZ1d1laUqB
	 RHk5VKhFt+wbnZhFfI/hWKzfe3mO0zfuLig8gw1hZ9zf+UfA674pVcQJYhISKEVYl+2L1
	 +9qjzuPFC5S4hqgMKBeR+OUdgb5xN8oeR/Bf0W+emjE9eqvWiw1AT6DsVqXXPSLky5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=iStUTfAs;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=DKjIh+Am;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37C1F606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 17:16:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 37C1F606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=iStUTfAs;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=DKjIh+Am
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794071769;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=GF0VNIBACEThthZfLlmyD17qs+vnUlg/+DboLoTRmA8=;
	b=iStUTfAsoZUgsPPWgnO05nEiS/x6RE5mEKl5fA5r0LsxV32vCTC3GjBZGpZWCwqjC3/h1F
	AZoivhSNaDW0GQ1tvfxJHniGDptYYRQ5FDO2uABtdaz8T/cG13h3fnXMqwpyYAcbstM7CQ
	hQCJomRIpLQXn0DJ/+H72QFiZvl5EaU=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-648-tatYcCV4PsGbLWopPRpKdQ-1; Sat, 07 Nov 2026 12:16:08 -0500
X-MC-Unique: tatYcCV4PsGbLWopPRpKdQ-1
X-Mimecast-MFC-AGG-ID: tatYcCV4PsGbLWopPRpKdQ_1794071767
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-91ea3a6c1a0so32337606d6.2
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 09:16:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794071767; x=1794676567; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=GF0VNIBACEThthZfLlmyD17qs+vnUlg/+DboLoTRmA8=;
        b=DKjIh+Am3iuXIBzT+9fHQxnqrRx33unInkvVRqSaIciu23Ul9mTBgfTijDe7W7qEnk
         DImZwLI7MeiC2WiEmy7eGmY25X0vvI1YAGmgVYxAKcfG7BNFMVIyCyD0wDN78Ji69P4g
         nk/GxHZLAjXFoE/oM+MWCDkoz6n7NfmNcxcxHtaw9sgbrimtHszfpw8ZL3/8f3rXM0HF
         6Uy4CYp8K+IZI8+v9MzjM0ZYmxjCJgWteWyzoIXmgZ5FWPV6QuB1b0DdbnEjorcJbHN9
         LpXHqQs61lCJdtF7jTn5FQBwqLUwouN7tgqJIcVaLBV2MwyAbIFYDliodXZYcSuFV+uB
         BtYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794071767; x=1794676567;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GF0VNIBACEThthZfLlmyD17qs+vnUlg/+DboLoTRmA8=;
        b=0d9bMM8DCaKQd4EeOz3E7g3Oqh7m9c7ebXewyxq0Wxoo2FDQnINRAud/UKxGwutibL
         oiWuwrP4726MXDMqYQjatyA4Gr+PGwwIRJjdQ/sAP1NLMsLDZl5Lb+s3d0OBkp8K3PK1
         IoIqtY64xTHR05PidHkd6YkLZ/HTG4hkdf9NyYZNswor4+I3baEQOYLR9xHqRi5GG4tN
         TBLWdWis3ZLqsKoX3NOOVrb1x/zhB7d8KoKl9BA71karmScMKIQY+MUSOXCxNIKhs3rw
         w7k2qXu17m1ryJLudMURjBb1h9UURHkiXGYLd7S7i3dxlRBXlspVJOGUQQUEIvM62Z8M
         Z5eQ==
X-Forwarded-Encrypted: i=1; AL+hErFZ3VYzazJpQzDc1x0X34lSkynxNyNSKY6OJVkfaP+J3CCKvbsx9yY1YDUkJRyo+azEAR2pgSB5Q9Q=@vger.kernel.org
X-Gm-Message-State: APuU4Z846EF+Bbzb8s1ExerwERSsj6T3HbdVuLK2eN5GymzV52bCR+D0
	uSC+Ca1E3eeVH9vt0QC2n1Od5fE1cDQWr3bxshJ3xmjujfi1JtCGHQp8OtRfx1NcffvqjFEnDCD
	Zd3EiWa0E4mzFSMAZ/RYmBEqUThZRvuD4LrCSmH/ZvuABinS2tFFvOjmvvE+GzQ==
X-Gm-Gg: AYBFou3T6sK10kTvIysTGBao9u8qMlcljg1xzqmu6uFXhspBVw06gFuoBl2YWt4DyOo
	oS2f0Ptia4WhIv1TgYsWZUe7Ns5+sZEvpgmgG3WPrIwS9MLPpuuyE73VpXfP7nhFeva20uzQUcP
	o551zZmmhaV3Dynpps1N+gZiRs9KRvbH8pOiCM3UsS0cn1/i2URz7806e8rdO68YTa4AO4pE6hF
	Mw9nhCRcdsoo9qazreWwVFowfE29tRT0cMUiUhfsCrWlucjvlwg8XmYY9E3B+W6bmiyLxJECs67
	JJVl3Sn+tOziS1e5A/HobFo9r3hVlnBCWRkLNYhFrP625XkFGGKxH+Y8OWP9F525h4MUhkkKPDF
	6PmLzrWfAKypU2bOTuMvbpEDM08U+JpEwP1vBr+bUCnKkDA==
X-Received: by 2002:a05:6214:8111:b0:91e:c00c:b7b with SMTP id 6a1803df08f44-91ec00c13d8mr21617476d6.48.1794071767115;
        Sat, 07 Nov 2026 09:16:07 -0800 (PST)
X-Received: by 2002:a05:6214:8111:b0:91e:c00c:b7b with SMTP id 6a1803df08f44-91ec00c13d8mr21617006d6.48.1794071766347;
        Sat, 07 Nov 2026 09:16:06 -0800 (PST)
Received: from [172.31.1.12] ([70.105.246.93])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ea6a2c4b8sm48325826d6.15.2026.11.07.09.16.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Nov 2026 09:16:05 -0800 (PST)
Message-ID: <4ae40b88-5b53-4a2a-8eba-64427fce6077@redhat.com>
Date: Sat, 7 Nov 2026 12:16:03 -0500
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
Subject: Re: [nfs-utils PATCH] configure: use AS_IF when PKG_CHECK_MODULES is
 used
To: =?UTF-8?Q?Sven_P=C3=BCschel?= <s.pueschel@pengutronix.de>,
 linux-nfs@vger.kernel.org
Cc: kernel@pengutronix.de
References: <20261014-fixconfigureasif-v1-1-0d2013f719e4@pengutronix.de>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261014-fixconfigureasif-v1-1-0d2013f719e4@pengutronix.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 10/14/26 9:17 AM, Sven Püschel wrote:
> Use AS_IF when PKG_CHECK_MODULES is used to avoid it's required macros
> being expanded inside the test. Otherwise these required macros are not
> available to subsequent PKG_CHECK_MODULES invocations, if the first
> invocation is disabled, which therefore fails to find the package.
> 
> Without this running `./configure --disable-nfsrahead` fails:
> 
>     checking for libnl-3.0 >= 3.1... no
>     configure: error: in '[redacted]/nfs-utils':
>     configure: error: A pkg-config implementation could not be found or
>     is too old.  Make sure it is in your PATH or set the PKG_CONFIG
>     environment variable to the full path to pkg-config.
> 
> Signed-off-by: Sven Püschel <s.pueschel@pengutronix.de>
> ---
> Noticed while updating the version in PTXDist, which disables most
> options in it's host package of nfs-utils.
> ---
>   configure.ac | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
Committed... (tag: nfsutils-3-1-2.rc1)

steved.>
> diff --git a/configure.ac b/configure.ac
> index 71ec1841..de6e63a4 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -242,10 +242,10 @@ AC_ARG_ENABLE(nfsrahead,
>   	enable_nfsrahead=$enableval,
>   	enable_nfsrahead="yes")
>   	AM_CONDITIONAL(CONFIG_NFSRAHEAD, [test "$enable_nfsrahead" = "yes" ])
> -	if test "$enable_nfsrahead" = yes; then
> +	AS_IF([test "$enable_nfsrahead" = yes], [
>   		dnl Check for -lmount
>   		PKG_CHECK_MODULES([LIBMOUNT], [mount])
> -	fi
> +	])
>   
>   AC_ARG_ENABLE(nfsdcltrack,
>   	[AS_HELP_STRING([--enable-nfsdcltrack],[enable NFSv4 clientid tracking programs @<:@default=no@:>@])],
> @@ -276,11 +276,11 @@ AC_ARG_ENABLE(nfsdctl,
>   	enable_nfsdctl=$enableval,
>   	enable_nfsdctl="yes")
>   	AM_CONDITIONAL(CONFIG_NFSDCTL, [test "$enable_nfsdctl" = "yes" ])
> -	if test "$enable_nfsdctl" = yes; then
> +	AS_IF([test "$enable_nfsdctl" = yes], [
>   		AC_DEFINE([HAVE_NFSD_NETLINK], 1,
>   	  		[Define to 1 if nfsd generic netlink support is available])
>   		PKG_CHECK_MODULES(LIBREADLINE, readline)
> -	fi
> +	])
>   
>   AC_ARG_ENABLE(nfsv4server,
>   	[AS_HELP_STRING([--enable-nfsv4server],[enable support for NFSv4 only server  @<:@default=no@:>@])],
> 
> ---
> base-commit: 5090e0bb662c53b4552b28b121ac2c2c434adb2e
> change-id: 20261014-fixconfigureasif-7e597385f2d9
> 
> Best regards,
> --
> Sven Püschel <s.pueschel@pengutronix.de>

