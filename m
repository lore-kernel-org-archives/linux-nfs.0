Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794071861;
	b=0awn+agZaRw7kvpllfBQMPzQgYk0vu/3osiuK7WHgMQy7z2ykCirjjnsBAUwV79K3BP2
	 npFIRTsRVF6nkY3C6K7mlr6w5CgzmS6YVaDc13SidMPZhhusXkrtCxjNdELzWeg7uh1BL
	 7r+4Lhryl39BcQVbMwgkg3W/Mhe+iz8koZLZ7KvYBOcgwBUn5AuGz9S9NXjcsfF66ty6x
	 bfAih4x6m90FDN1JbPAud/8s/zbguP8m1hOBdIG8i1iZ853Ei5Slaa+SIq8gxZWRK0BhA
	 nuCC5+/+X0zw7CLMW/QmtWAU7B0+VkSjvG/thMcg7+xKSFulVZso1dbrztQM6TaScTA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794071861;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:References:Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=EmODTmdYepMiQcSp2cht9psWVJwSQmAFCmFYw8SfCnA=;
	b=kox+eIyJ2Xzi0oNgZrdwc5vIiNL8aMhyRHhaZaaeoq1SbjUghj0o8lE5H3G13NfEcnJ/
	 CeWnCOJnNON1a9I4GoSGpY69qvSQFWHKZYklqOsxGF9lhStV+BIZtEp23E99lksdy3nFq
	 3g5nGNCgK9MudL5tvwu0qq1ZiHLgpUWHUAIwjdD1B1I5ePD5oEHNLgPF2IOjqwVNKojYT
	 NB+JvZC+pne8pno++oYrKr8VhhNZuEZiGfGr5Beo6rDzMZ2UbeXa0ISrIu1WRaZTSIXSf
	 W3oU7bt3wAqa4e+BNcCk4WorJmVkNMj5jMpD7Zfdb303J2zMHwUh2LUrxh968UlUctQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ABaHttJj;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=C0vbgC4q;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5302606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 17:17:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C5302606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ABaHttJj;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=C0vbgC4q
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794071859;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EmODTmdYepMiQcSp2cht9psWVJwSQmAFCmFYw8SfCnA=;
	b=ABaHttJj9FgIwzIDItRvndEr90wv5XU0Y41kofOCJP3TbTaNOTJib+K03geIoNqMa4j1Ly
	I43J/fBnJThVsvWrMJ+hZZ3vRHwxy02X44K5iwLVnxktf0hmCB7idodALizw3/CcV3ZixC
	+5sYdxFpF8qWbnMjIGsH56QCHcM5YvM=
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com
 [209.85.160.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-279-n3f2jWNrMBWYgzV9nzBDgQ-1; Sat, 07 Nov 2026 12:17:38 -0500
X-MC-Unique: n3f2jWNrMBWYgzV9nzBDgQ-1
X-Mimecast-MFC-AGG-ID: n3f2jWNrMBWYgzV9nzBDgQ_1794071858
Received: by mail-qt1-f197.google.com with SMTP id d75a77b69052e-53664602c7fso32862571cf.1
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 09:17:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794071858; x=1794676658; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=EmODTmdYepMiQcSp2cht9psWVJwSQmAFCmFYw8SfCnA=;
        b=C0vbgC4qemrCAAjVY5FEseykt4/UztDHUxMXRWGeEyqexDaykijOO9nWfOVr+mKZD+
         eAoilKBQeBS0BGxIFxeEQVANdICAmaObmOKxtymSf1D1nLwcdqP98NF70oHxh4vHkOMs
         vjd+DM3v1fcaCveF28AxB8U2tumtVOV7na1I/gBy8bAfkiPwlTnNUm9cp6a5lWGkstHg
         vX/fzrLcFZxSq3IuCxFfkEJey0MJ3xZ9hFyLFjztFkR0rDqryiTNRg5x0KTs8bBxhVri
         /mFpPzPD3q+/wTrzgLgPDIZwyONqXHyamKmRLgLC2fWYRw1J4EwKGfom58ef3CW6fsdm
         n8LQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794071858; x=1794676658;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EmODTmdYepMiQcSp2cht9psWVJwSQmAFCmFYw8SfCnA=;
        b=1PwVcoQxIhv4Z8nQ77QZnJVz6yGOacjdXGErlsF3SKUqSDBW+17QZY3hU7T6SBXIlX
         s9zY6afcy0skjODObM+dBI0+9u1v33VUzaRlPPs5yHgrhMBpVNSCRp586wVYfNz+QXjD
         qDHCX+qm0TyeEK8jdHimdoiI+7sxNQ2M0ph+0OoaNpVWBD/hShyzMe9XWh8zdiNdh6S/
         NTrU2JbcF01LPkFaW3IQprMW0PLm1YACxP36xznC6OKmBHDV27ZCUgS6MFa/efK5OXTZ
         sAzlujhswpB8njG1mXNhwqctQOgNAFyxqpOXbkRXP6pAFrMhbjjRrHoB4kK6MnF8YXSY
         Yw0w==
X-Forwarded-Encrypted: i=1; AKwUvBw4gAa2gF37VdZNtn9XelAbLp90VRqkVJvgPN5+i9GftkIJADau9kbQ9PAh+oRtgTQg+QQSKCJ3rzw=@vger.kernel.org
X-Gm-Message-State: APuU4Z8UidRJwpwi/3VNhY4/AGEsKZMmG3RLdeGpILWK6sJzRBP85lKC
	cZw7+3dSzP06Ly/8f7ih3qMm2NQsurZfYVJw00AWxIOeN8ZQa7QjNBxzqBz76EiyRIdjM7JH0U8
	hEQFKqYuD7ADGUNL0TkBdiEVbMS0dSCCzmAqZM0hGDCVyAr7GLBvYrlir/iqseg==
X-Gm-Gg: AYBFou1+2dNuddiRUOgCKYgnQ2F1ySZ7p3xU4OpiQU295uzk0fOtv0+qj20w8xdGstw
	zOXWnJZQLlCTrDcf7cK6ljFs3ovQxzDmtWesEs6x1/xwiHe/bnk4KHasZWXtnVa2NbayNuy2EJH
	0+JDb69y8vA/550AEBcwPnT23jSI5+ZDJ557tA5ohtxDcb08B8uvriTs43207vFr351lw8jF4fN
	ijrS3bmJ5n3tYhr4iaJMkIte8mR24pLT1prFTaB78rLh2eSlj3dxoLJBulTCXCq8GBBIZpJYDvc
	3z/FAYdzbfQSf6qrU9JHf03xG+TNFyTQKxQs5ockPgW8t2JupkI0jYoDQTXmzMZSTGekQngSMa8
	BdE0S2kwnx3KGLeHcpNItUaB/OfIVgXBnLgJxmllEXWGDuQ==
X-Received: by 2002:a05:622a:2485:b0:53f:a444:dc7c with SMTP id d75a77b69052e-54e156631cemr89224071cf.56.1794071857766;
        Sat, 07 Nov 2026 09:17:37 -0800 (PST)
X-Received: by 2002:a05:622a:2485:b0:53f:a444:dc7c with SMTP id d75a77b69052e-54e156631cemr89223681cf.56.1794071857081;
        Sat, 07 Nov 2026 09:17:37 -0800 (PST)
Received: from [172.31.1.12] ([70.105.246.93])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ea6acebb0sm47546086d6.45.2026.11.07.09.17.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Nov 2026 09:17:36 -0800 (PST)
Message-ID: <7a18bcc9-515e-4b80-84ef-ee812ed06fd3@redhat.com>
Date: Sat, 7 Nov 2026 12:17:35 -0500
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
Subject: Re: [PATCH] nfsiostat: display READ_PLUS statistics when available
To: Karim Manaouil <kmanaouil.dev@gmail.com>, linux-nfs@vger.kernel.org
References: <20260929012258.7objh6we7hdzqlzv@wrangler>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260929012258.7objh6we7hdzqlzv@wrangler>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/28/26 9:22 PM, Karim Manaouil wrote:
> NFSv4.2 mounts may report READ_PLUS operations separately from READ
> in /proc/self/mountstats. nfsiostat parses these counters but does
> not display them, leaving read activity out of its reports.
> 
> Display READ_PLUS in the default and page cache reports when the
> operation is present. Document the conditional output.
> 
> Signed-off-by: Karim Manaouil <karim.manaouil@ed.ac.uk>
Committed... (tag: nfs-utils-3-1-2.rc1

steved.> ---
>   tools/nfs-iostat/nfs-iostat.py | 4 ++++
>   tools/nfs-iostat/nfsiostat.man | 5 ++++-
>   2 files changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index af04aac5..2a681bbe 100755
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -436,6 +436,8 @@ class DeviceData:
>   
>           if which == 0:
>               self.__print_rpc_op_stats('READ', sample_time, use_mb)
> +            if 'READ_PLUS' in self.__rpc_data:
> +                self.__print_rpc_op_stats('READ_PLUS', sample_time, use_mb)
>               self.__print_rpc_op_stats('WRITE', sample_time, use_mb)
>           elif which == 1:
>               self.__print_rpc_op_stats('GETATTR', sample_time, use_mb)
> @@ -449,6 +451,8 @@ class DeviceData:
>               self.__print_dir_cache_stats(sample_time)
>           elif which == 3:
>               self.__print_rpc_op_stats('READ', sample_time, use_mb)
> +            if 'READ_PLUS' in self.__rpc_data:
> +                self.__print_rpc_op_stats('READ_PLUS', sample_time, use_mb)
>               self.__print_rpc_op_stats('WRITE', sample_time, use_mb)
>               self.__print_page_stats(sample_time)
>   
> diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
> index 4f24318d..b06e65aa 100644
> --- a/tools/nfs-iostat/nfsiostat.man
> +++ b/tools/nfs-iostat/nfsiostat.man
> @@ -10,6 +10,8 @@ nfsiostat \- Emulate iostat for NFS mount points using /proc/self/mountstats
>   The
>   .B nfsiostat
>   command displays NFS client per-mount statistics.
> +The default report displays READ and WRITE statistics.  It also displays
> +READ_PLUS when it is present in /proc/self/mountstats.
>   .TP
>   <interval>
>   specifies the amount of time in seconds between each report.
> @@ -126,7 +128,8 @@ only print stats for first LIST mount points
>   display throughput in megabytes per second
>   .TP
>   .B \-p " or " \-\-page
> -displays statistics related to the page cache
> +displays statistics related to the page cache, including READ_PLUS
> +when it is present in /proc/self/mountstats
>   .TP
>   .B \-s " or " \-\-sort
>   Sort NFS mount points by ops/second

