Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D6474A4F1F
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 21:56:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789595806; cv=none; b=Os4uBO/yufVyCTtUqs8M5x8keKLnn7DfJFAmcYz7lVa9ASw8M53hcmQwJryVFrVhB77aly2V2VcHqf+JgbEnHog04maixcryNKZKUrAmYI0f7AzOxlXR+RLUA0a0B5M29Zi4fmO3Wn/vMBfdiXXF2Ey/Z1FKtfGsi5bMBz4b/bo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789595806; c=relaxed/simple;
	bh=07uu/sstX67Ma4fS6jRONoFEB0hO20aC8ZjKmsAaggE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=eoskhdTu/MaIfayKvCGoovCOBL58LSC3fHwYbWYw3HC9Jeqpj8QBxB0McMMwkIyhhkZ5FfTOzgI7oZD3mOwWZOsEjBZO3ZLHTQDgj1P5IqCqkk+1SBx8BtgKLPt68JqRUg5FCcaG4x25oddEY9hLN/nSSQE92Q1cJdaJXaE7Dhw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ANEeHZqV; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=CJiQdfEp; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ANEeHZqV";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="CJiQdfEp"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789595792;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4vWJOV5w7M0fSmZ/wXbcII7vrnfmETgeZnxaUc4bnLE=;
	b=ANEeHZqVIo1wJwV+fy00m7uSLpVncLD9PTVLAG0gGM6iVe9R5YOMgWBpnVCZAt2puJ+db6
	IqhL8J30WyF1rGP69qnI6zd74jP8IN9dQ71fDyginU4s2kiA1KQEcjHsKv0LvmuGSFq4yb
	/QNnL4nVzcxzlIW1ntBAkhiL6FHHdw4=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-411-Gp-cTDZ9OSyHg6_D0Q92fQ-1; Wed, 16 Sep 2026 17:56:31 -0400
X-MC-Unique: Gp-cTDZ9OSyHg6_D0Q92fQ-1
X-Mimecast-MFC-AGG-ID: Gp-cTDZ9OSyHg6_D0Q92fQ_1789595791
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-93909014c85so29450285a.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:56:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789595791; x=1790200591; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=4vWJOV5w7M0fSmZ/wXbcII7vrnfmETgeZnxaUc4bnLE=;
        b=CJiQdfEpY4mr98u31E0zB2c6XdVYZLBuqZQfUwx5QnzUn5ytSNy+DgMMWZKweqhAhK
         o/OlSGM8kR5JI2xxyn2xY0e4UNcFXzWwhaYWPDXj/cKj0DwdFEJ1Il4c2o6EUbMSmonD
         WAliNSEv2CLSJDdNXuPGFLTYQ1AfPxLKX+iNBStO9L19cWDIOKLzZ2aVMrabk/VOwUB4
         yTIJJilE/81iVuGtw+YX/rwHy89rbmDJUFsp3qu4QfJYiZ49cI8xax1PzXaTX/Mp0wvY
         yEUFV066v61+EDVLFLqF1yD4ORgloyKirVt1GZhN0DfyTPDqU8H2rdxb+X/QNVbd3i7v
         cFoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789595791; x=1790200591;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4vWJOV5w7M0fSmZ/wXbcII7vrnfmETgeZnxaUc4bnLE=;
        b=OWbed40wpmScdh7SlIyZVnbxpU17KL1Bt5ILOPefzhAEx/saXc3o/y5Spf/JMYnns1
         TljnZKegB8dVdrYy4iGL+LoJs9bTSK+lhxj9dmEgK/Q4+H8an7bkZcEpVFDtPfpfYQLI
         dZCA0iDX9AyiksLSIlsluWlXbua62GbQ3S9sFXzkJID2pHfW+H8oY+yOb/C//Utfa7J7
         SPNcknELc2i+6UCUUCSRagOhDuJx1HuelvdSAlL9LX5c+LrDFarMbW9MyiA7D+SZJZgB
         3NVW6n56LF5CXqSP9jtcqKXNsuuyDLVm26Gp+IT11WYT0acIByMkR+oiAELMayMWZwun
         h0ng==
X-Gm-Message-State: AFuF++kcU4n/4v2GJNp1i9NhguyTZSZwejmtOJlA7sGqKWkiVQ4Fpm87
	f+RWSlMtJ09jhHOOEutuI2rErSB5PVzcm3Bj+dNWdI9M4Q5TWsCzJTgzM7VyWxPXw/Ewky6gNeO
	Bd8oGWufI8MRJvrL1JLDzpR3DsggGKG5pczT58292xYYDs3K7W8Ac1rXDxXxxtw==
X-Gm-Gg: AYBFou0pY7pwWc9QhtUTxxm8zD0voIiniVvjo338u6mt/yboe8POXe4dbMnAIhAl04W
	+ibcBbY+5gKr78LaTbNgBn/0ILniRKuUcEwHQeLqO0Vtfe84RLx4dM+yb77w1oksE0XSZId7a+o
	+cKA23qCa23PBEyuk7UPNG2pZyFF4X115f4xUfXAr4VuK8W0nXil3SEOjXLzkueIbMS1MkzGDmi
	XM1xynfUxtrIW7ix14xCYtgAflnYdfHuNUd80HJunrLKyfy/XHfhIflo+KS8ZDnfVQYbW4WJ4oG
	tjWejaspulRJfX+2Dd/zx3wzdOj2B4OSaaUReXEoJJR+KwIfVg0zE5E5Pfv7fSL9aVkmA+fw
X-Received: by 2002:a05:620a:708d:b0:93a:3d71:c9ec with SMTP id af79cd13be357-93bb76e6cc3mr676895685a.7.1789595791016;
        Wed, 16 Sep 2026 14:56:31 -0700 (PDT)
X-Received: by 2002:a05:620a:708d:b0:93a:3d71:c9ec with SMTP id af79cd13be357-93bb76e6cc3mr676889985a.7.1789595790332;
        Wed, 16 Sep 2026 14:56:30 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.2])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93bc0801a9fsm171220285a.39.2026.09.16.14.56.29
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 14:56:29 -0700 (PDT)
Message-ID: <3dd18810-b7b6-460c-8f39-8d16d5ea2090@redhat.com>
Date: Wed, 16 Sep 2026 17:56:26 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] gssd: fix upcall_* leak when re-reading service
 info
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260831230256.814412-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260831230256.814412-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/31/26 7:02 PM, Scott Mayhew wrote:
> gssd_scan_clnt() calls gssd_read_service_info() whenever clp->prog == 0,
> and the function's fail path leaves clp->prog == 0. If an initial read
> fails (e.g. the "info" file is not fully populated when inotify fires),
> the fail path strdup()s the parsed values into clp->upcall_address,
> upcall_port, upcall_protoname and upcall_service. A subsequent re-scan
> then calls gssd_read_service_info() again and overwrites those fields
> without freeing them first: the success path sets them to NULL and the
> fail path strdup()s fresh copies, leaking the previous allocations.
> 
> Free the upcall_* fields at the top of the function before repopulating.
> clp is calloc()'d so the fields are NULL on the first call, making the
> free() calls safe.
> 
> This fixes the following leak:
> 
> ==1300== 5 bytes in 1 blocks are definitely lost in loss record 13 of 929
> ==1300==    at 0x4877826: malloc (vg_replace_malloc.c:447)
> ==1300==    by 0x4B7B9FE: strdup (strdup.c:42)
> ==1300==    by 0x400D08D: gssd_read_service_info (gssd.c:373)
> ==1300==    by 0x400D08D: gssd_scan_clnt (gssd.c:734)
> ==1300==    by 0x400D7C6: gssd_inotify_clnt (gssd.c:922)
> ==1300==    by 0x400D7C6: gssd_inotify_cb (gssd.c:988)
> ==1300==    by 0x48B9D9B: event_persist_closure (event.c:1623)
> ==1300==    by 0x48B9D9B: event_process_active_single_queue (event.c:1682)
> ==1300==    by 0x48BA5BE: event_process_active (event.c:1783)
> ==1300==    by 0x48BA5BE: event_base_loop (event.c:2006)
> ==1300==    by 0x400A431: main (gssd.c:1292)
> ==1300==
> 
> Assisted-by: Claude Opus 4.8 <noreply@anthropic.com>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc5)

steved.> ---
>   utils/gssd/gssd.c | 15 +++++++++++++++
>   1 file changed, 15 insertions(+)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index e381c0f2..223d5dfe 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -276,6 +276,21 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
>   	char *port = NULL;
>   	char *servername = NULL;
>   
> +	/*
> +	 * This may be a re-scan of a client whose previous read failed
> +	 * (gssd_scan_clnt only calls us while clp->prog == 0, which the fail
> +	 * path below leaves set).  Free any upcall_* values left over from that
> +	 * attempt so we don't leak them when we repopulate the fields below.
> +	 */
> +	free(clp->upcall_address);
> +	free(clp->upcall_port);
> +	free(clp->upcall_protoname);
> +	free(clp->upcall_service);
> +	clp->upcall_address = NULL;
> +	clp->upcall_port = NULL;
> +	clp->upcall_protoname = NULL;
> +	clp->upcall_service = NULL;
> +
>   	fd = openat(dirfd, "info", O_RDONLY);
>   	if (fd < 0) {
>   		printerr(0, "ERROR: can't open %s/info: %s\n",

