Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 483F43D9556
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 22:59:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217175; cv=none; b=r6cXkB+M1WxrYUz3V0bbYOtDZ8dOIjEZul9Sg79EL2mj792QHsdTrrvrIVX1mKMyzHfdle188B7E/G1UsURY5iA3rTT+uL4P+vGk/s8371t/nt6lTtLhltCYvF8zFLyRWr7cfEnruknn0GisJ8mY7KfFk5O6+lZJUbd+XhO4SK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217175; c=relaxed/simple;
	bh=9w2fJMFJfoMKZHr3yUEMJiUqkNOTUPGngPWS5P6a/8U=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=b5n9ScCDfOcKzRoeLFScM/uidS3f9cVN+XDpIkzqVuHwWVeyjeCEFDSa+NO+tjiORsz5N/azVPTg5ab/5/VkPOEsN5Hur5tvDnqvhIdQWgCn3RCbSLPWzvP/KwoCU6HkT5lZ1ffAkEMN3t5UW75yfM4C7aLSRnuy5Aebiwqxcrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=MUj8qOnz; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=P21yFFV8; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="MUj8qOnz";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="P21yFFV8"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217169;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=uK4TTkBG9dUIPsUOqB9N1xZ2lSliw1R9iyocIf27jkE=;
	b=MUj8qOnzbMZkye6K1j+sGnqL49MMN0vQ2j1/peMVBC+1+gDT/jc3jLHozoe0h7cT/fzCvZ
	/MlBWqu9MUulTZrVUt5ajzRmEjwxu134mQJEqH22ylPOi3UDpIcZoAL1zSaiV76LhMl+sy
	W+UT9BuhXV6Is6ERetEp4fR8nmV6Bz4=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-486-803ys_6gOcCLxwkhLFzLLw-1; Mon, 31 Aug 2026 18:59:28 -0400
X-MC-Unique: 803ys_6gOcCLxwkhLFzLLw-1
X-Mimecast-MFC-AGG-ID: 803ys_6gOcCLxwkhLFzLLw_1788217167
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-8f39a46efd9so6396476d6.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 15:59:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788217167; x=1788821967; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uK4TTkBG9dUIPsUOqB9N1xZ2lSliw1R9iyocIf27jkE=;
        b=P21yFFV8QnFHo56ymdMf5WTs3MURnf4Q+SEFO29u1vxQXalh3dVLIRvxq47r0TaoGA
         1d+VE0b4dGBZRj+up8I3JR3xM6AZDWB4pIItf+PIeL9JOvqvhuAc3sURPYPAWmpb4lRp
         dHwi88VOrS/sTbAFl+FXzT4ZfTHB4N92hkKjTjtJyRb9wI2CUTAgi2cI5XlxQcSO1zqZ
         c8HZNN7bNvGPRtqguClnYqc8vwB4YCyfTg2It80lPPjGxMGN6iA6503bmNoB8UsypwGB
         P/eo8d16fXWrrNxIUu8Id1TPjShX3BK8PsM9JiaY/5RdRX3uZ/Sn9aRtq+eUbfLoevTQ
         fbiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788217167; x=1788821967;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uK4TTkBG9dUIPsUOqB9N1xZ2lSliw1R9iyocIf27jkE=;
        b=kPfOlPlVseTpYUn6KPBhtwVLGLBsbAUF5O4UGKusUdGSmopkPdoESdzZlz5Vv5Kw4+
         WxrXF3JHNQ0pAC80dWY8b2QU6B0Vx4v+GFgPbdpvuahNWcyISeMDTn6JgjA80j39hNdz
         MHJvlN9WIPUD05+p2LEPjisWg4ruZpeN3AGvgB9+u5JMoweJaFLVRpTJhQZx29FxFlsf
         pnS5L8uLIAG2Oscdz2ar9ElVL618+jeJMqCizsS/UC9pwZVXkUWEOc8sMqkPIasoi9Fr
         R4nH31yypYpa26X/jC476RHXlYATjlGZXKLcPH4YaSxG6GZDBgaF8eXifWAvM6HFlusM
         ycqQ==
X-Gm-Message-State: AFuF++l8jDoMwFi/VN719fVMLXZOoZqXZLtjICxPoBvf2WyH4X1+D0wy
	oSNEVwaVK8hKJRYgbXQ8ResH7TaATd2ZGqlqS8Ml4qYzcSPvskPWPwg03pnfUKLZqVWFrxt9cwo
	7yxE7s8uDWVHRm+YSV//eMcx9kYfwSk/sLPx/LqW7saCMMmy6kXViqVx7O/gILQ==
X-Gm-Gg: AYBFou2AQ7pezdZpuyTmeBL1AlIBfK0eSrSjSatsxywUJOpawH5zMfv2hrLhbOL00RN
	p1i4Fw9rWL9nGSlIIkLTfzdpHXAZplDUuXyV1zgLvuquKi97tQsU+x/p9PWT7K2TWYRdtrGNnZh
	CFw2b1KiXnTSriTfl3JDHN7dbZrMw80cmQnWU87VxPsRVjkjVDgWyIF2nujRabNtc/K5tPDeYpZ
	vciaxVb9WAVvsgPDXTcd7mWJjobRUBTIb/0joDSIU/GIuAkuheNxk6y64NxNxs62W6+Gv1TnJv0
	fNfKu/4p9X7tYCPQ3/kZsEpK7w34EzzaGUhHSuKFP1mGNMsX7VVJUZZnqY1luCLs0KFyMvaXmDU
	r3fbMpiAJmggFCYVLKb7hb79Ip9VvldFL1blkoxx0WybZs1EN
X-Received: by 2002:a05:6214:5d87:b0:90a:7f98:15f3 with SMTP id 6a1803df08f44-90e956e7aefmr21568716d6.2.1788217167417;
        Mon, 31 Aug 2026 15:59:27 -0700 (PDT)
X-Received: by 2002:a05:6214:5d87:b0:90a:7f98:15f3 with SMTP id 6a1803df08f44-90e956e7aefmr21568266d6.2.1788217166911;
        Mon, 31 Aug 2026 15:59:26 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90ce4464bc8sm95051806d6.19.2026.08.31.15.59.25
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 31 Aug 2026 15:59:26 -0700 (PDT)
Message-ID: <f95be37f-9d8b-4341-a34f-908077824b29@redhat.com>
Date: Mon, 31 Aug 2026 17:59:25 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/1] nfs-utils: mount: fix snprintf return value handling
 in error formatting
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260825185323.27151-1-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260825185323.27151-1-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/25/26 2:53 PM, Olga Kornievskaia wrote:
> snprintf() returns the number of bytes that would have been written
> if sufficient space were available, not the number actually written.
> When the formatted string exceeds PATH_MAX (e.g. due to a long
> progname), the return value exceeds the buffer size. Using that
> unclamped value as an index into errbuf produces an out-of-bounds
> pointer, and subsequent snprintf() calls write past the buffer.
> 
> Add errbuf_clamp() to bound the position to the valid range before
> it is used as a buffer index. Apply it in rpc_mount_errors(),
> sys_mount_errors(), and rpc_strerror().
> 
> Fixes: 6e54f6179cb9 ("text-based mount.nfs: Add text-based error reporting function")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc2)

steved.
> ---
>   utils/mount/error.c | 24 ++++++++++++++++++++++--
>   1 file changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index d6cbdea1..4dace8f5 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -54,6 +54,21 @@ extern char *progname;
>   static char errbuf[PATH_MAX];
>   static char *erreob = &errbuf[PATH_MAX];
>   
> +/*
> + * Clamp a buffer position to the valid range for errbuf.
> + * snprintf() returns the number of bytes that would have been written,
> + * which can exceed the buffer size on truncation.  Using that unclamped
> + * value as an index into errbuf produces an out-of-bounds pointer.
> + */
> +static int errbuf_clamp(int pos)
> +{
> +	if (pos < 0)
> +		return 0;
> +	if (pos >= PATH_MAX)
> +		return PATH_MAX - 1;
> +	return pos;
> +}
> +
>   /* Convert RPC errors into strings */
>   static int rpc_strerror(int spos)
>   {
> @@ -62,6 +77,8 @@ static int rpc_strerror(int spos)
>   	char *ptr, *estr = clnt_sperrno(cf_stat);
>   	char *tmp;
>   
> +	spos = errbuf_clamp(spos);
> +
>   	if (estr) {
>   		if ((ptr = strchr(estr, ':')))
>   			estr = ++ptr;
> @@ -72,9 +89,9 @@ static int rpc_strerror(int spos)
>   					_("System Error: %s"),
>   						strerror(cf_errno));
>   		else {
> -			if (cf_errno)
> +			if (cf_errno)
>   				pos = snprintf(tmp, (erreob - tmp),
> -					_("RPC Error:%s; errno = %s"),
> +					_("RPC Error:%s; errno = %s"),
>   					estr, strerror(cf_errno));
>   			else
>   				pos = snprintf(tmp, (erreob - tmp),
> @@ -109,6 +126,7 @@ void rpc_mount_errors(char *server, int will_retry, int bg)
>   				_("%s: mount to NFS server '%s' failed: "),
>   					progname, server);
>   
> +	pos = errbuf_clamp(pos);
>   	tmp = &errbuf[pos];
>   	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
>   		if (will_retry)
> @@ -119,6 +137,7 @@ void rpc_mount_errors(char *server, int will_retry, int bg)
>   					_("timed out, giving up"));
>   	} else {
>   		pos += rpc_strerror(pos);
> +		pos = errbuf_clamp(pos);
>   		tmp = &errbuf[pos];
>   		if (bg) {
>   			if (will_retry)
> @@ -164,6 +183,7 @@ void sys_mount_errors(char *server, int error, int will_retry, int bg)
>   				_("%s: mount to NFS server '%s' failed: "),
>   					progname, server);
>   
> +	pos = errbuf_clamp(pos);
>   	tmp = &errbuf[pos];
>   	if (error == ETIMEDOUT) {
>   		if (will_retry)

