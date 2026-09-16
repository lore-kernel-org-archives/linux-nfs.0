Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28B863DD86C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:13:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789568021; cv=none; b=NJt0z36/JRq6Au9B6dhG7NWYTfMdxsoiGsxFTx5lHoDWrDR36Q8vFkvTo6MLSk6ug4Vl2v8ZhH/pl0aJ8OHvbKfUfPdOw4bwbddv4RdQTId1Tg6eBgcY3yg48utuZFdgFnGOG59SQOk/jS1RECmcTaIcoFBEE4F8FDFuGGotMK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789568021; c=relaxed/simple;
	bh=olPpOZPLtFvBXf98cZb6kmgdSQ7ZR6OdHU8scIeYRrg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=mRhRKL9KVVLjMRIOkkfteye3CsWEOh50OOnJDo1PtsTAfetOl8leeCTRYsPjR5fw5/JeeDQZRyWcxYN+yARV4fFedcJa9M+/Tjwrb9w3k49y8DBfN2egZBrDT3uaXtKeYhJGVyHfEJsuBLbAREwGHhnWRePG5uzzf8CS4US21L8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gnN/TFHl; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=OQIjZqfy; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gnN/TFHl";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="OQIjZqfy"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789568018;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=inAIAxN6XYpgbYzQOsYYLJSZx4zgCDOd/DLy6eVXU/s=;
	b=gnN/TFHllTtTjYfZJlkUmD0goYIpYaiedRgJwCUDwJZd/9yXUiNQQqmlm5rDp8nhkC5sFe
	1JZeJ/nGTZjKAjNCGMOJweipvgqYbY+QkO808pUjZ+6Y2gV8eZQSgXKs+qUHxg1eA1I/wY
	anZfKdVs9a70PD9i0M8/ovh6hFN2EUE=
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com
 [209.85.208.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-351-XXxLuNnfNia2hxgac1GNDw-1; Wed, 16 Sep 2026 10:13:37 -0400
X-MC-Unique: XXxLuNnfNia2hxgac1GNDw-1
X-Mimecast-MFC-AGG-ID: XXxLuNnfNia2hxgac1GNDw_1789568016
Received: by mail-lj1-f200.google.com with SMTP id 38308e7fff4ca-3a2005c865aso33169101fa.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:13:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789568016; x=1790172816; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=inAIAxN6XYpgbYzQOsYYLJSZx4zgCDOd/DLy6eVXU/s=;
        b=OQIjZqfy7qDv5mCI/AW71ltNuTI/VZILpjMdOWJG0kHB8YHCHBJIb7kyzRkADQw+CY
         3HqDBeWo+E9WHOpR0/+DQ0jUUL/4C4PHnxRKNE66BMl7ZkmNia8XvXn/7H0i+X2uyPMk
         5aU/AOHrsWQASiXQFK/arTpCyQkwdwCJF0YX+95Y4t1AG6aIDOzumAagqeRdYJYGOcUE
         krvBT1LE6L71HQPgB8HkP+O+69wnG1L/Z+3/LjSwoApkpyNs9L7JivK3cmqcDR8S2M4Z
         6a7BgXUs0OdWYACtpDAmL55wHZojBDgGL3zWyeAgs03ZLIaEhpTY96XUkbD2BtA9dAZe
         C4Bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789568016; x=1790172816;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=inAIAxN6XYpgbYzQOsYYLJSZx4zgCDOd/DLy6eVXU/s=;
        b=ZOIYVoXMwO8X9rVG7IR1uHTPNji4Eesi1j3ngWrN38iGYA2FycDkpQRG5/uEN4S9ho
         iimGrZ78CUJQtijDPWzbVh0bQtEQJ5p31JhPuiHRgANarn98yUjyrhaCqCSCRWSOXx1F
         rAHY4vbaz5XVc1b3Yq5BqzMTR+aC4KH3B+sHTrpU2hDs2x+ho8IV1VNvrre9vqxSNERB
         lTHBT5Xv7TFpAvXgDpp7zo4S2EzBiiA/Fr+xMA6xxeFULI/qCbsiENbXL4FtiCYbTRtc
         Bb+1xB2f55MSMCZrQvCL7rKS6XalP5DgeYD+zArH1bkTYcp/VvFHtaB0TwJocuan0Mre
         cX5g==
X-Gm-Message-State: AFuF++mLHJrr0/tvkNr3AgtvLTS9p2IfygPUXlycxNQ1gItVpWZxzquZ
	KXcjris7AtW+SwgJoa9BY0CSas2vAL+Gsp6N4FH2y7OKixU7u/+5jkQtHUor2WBsOkwBN5diV8G
	F4+THlfeBHSz7EjkMgoAXSythzUnFzmd8rPZNJhu73hOHgtM4SB6oLt5U3EFcAekpjiw/lA==
X-Gm-Gg: AYBFou1J/+zJpqfaUcum5U8tTYJEKN4zZi9zI8YpM2RYccoC3FeoSDlPozAsG1GaOc5
	UKQr97XAqB/dxloMbyw3yBJBSnH8NiAPNZDFgcdGBF140j6NRLgz4xcCARyv0/odvZBq6yYA2PA
	RLSS1/NIpXFqcRyoP6n+GxTtCqQLiuobfcUj6Y4tiZE7a/ZXld/ycD6wzSJseSl6LiGMs7DxGC8
	5JHFrDn5V/8ty3EaZzoUfvzYNfDuq6OEfFJMdR057VVuvOUjamfVLqfpsLFsq7fxh/O0cyotz0t
	DTK7p6l5WaUMrMBdcdjSoLSZnkt6E81zlBmnGI98TJjQkW4rwKh+tVl+yNG8s6PE/g25pVjEtQg
	=
X-Received: by 2002:a05:6512:b83:b0:5b8:b3a6:6024 with SMTP id 2adb3069b0e04-5b8b6611fffmr831727e87.10.1789568015923;
        Wed, 16 Sep 2026 07:13:35 -0700 (PDT)
X-Received: by 2002:a05:6512:b83:b0:5b8:b3a6:6024 with SMTP id 2adb3069b0e04-5b8b6611fffmr831711e87.10.1789568015451;
        Wed, 16 Sep 2026 07:13:35 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5b8b57e0bdcsm935489e87.58.2026.09.16.07.13.33
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:13:34 -0700 (PDT)
Message-ID: <c2edd43c-9f72-4591-a42a-a2fc390f4e3d@redhat.com>
Date: Wed, 16 Sep 2026 10:13:32 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] statd: fix notify_list struct leak in
 nlist_free
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903175003.1213806-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903175003.1213806-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:50 PM, Scott Mayhew wrote:
> nlist_free() freed an entry's string members but never the notify_list
> struct itself, despite its name and comment ("Destroy an entry ... and
> free the memory"). Every caller was expected to free the struct
> separately, but several did not:
> 
>    - process_reply() and process_notify_list() (rmtcall.c) clean up
>      entries cloned onto the notify list during SM_NOTIFY handling.
>    - sm_unmon_1_svc() and sm_unmon_all_1_svc() (monitor.c) leak the same
>      way on the SM_UNMON paths.
> 
> Fix the root cause by having nlist_free() free the struct, and drop the
> now-redundant free() calls in sm_mon_1_svc() and load_one_host() that
> would otherwise double-free.
> 
> nlist_kill() previously called nlist_free(head, *head) followed by
> free(*head); since nlist_remove() (called from nlist_free) already
> advanced *head to the next entry, that free(*head) freed the wrong,
> still-live element. Pass NULL so nlist_free() only frees the entry and
> advance the list manually.
> 
> Assisted-by: Claude Opus 4.8 <noreply@anthropic.com>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   utils/statd/monitor.c | 2 --
>   utils/statd/notlist.c | 4 ++--
>   2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index 76ef16f1..f7f4342a 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -225,7 +225,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>   
>   failure:
>   	xlog_warn("STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
> -	free(clnt);
>   	return (&result);
>   }
>   
> @@ -245,7 +244,6 @@ load_one_host(const char *hostname,
>   	clnt->dns_name = strdup(hostname);
>   	if (clnt->dns_name == NULL) {
>   		nlist_free(NULL, clnt);
> -		free(clnt);
>   		return 0;
>   	}
>   
> diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
> index 45879a43..91030d85 100644
> --- a/utils/statd/notlist.c
> +++ b/utils/statd/notlist.c
> @@ -210,6 +210,7 @@ nlist_free(notify_list **head, notify_list *entry)
>   	if (NL_MON_NAME(entry))
>   		free(NL_MON_NAME(entry));
>   	free(entry->dns_name);
> +	free(entry);
>   }
>   
>   /*
> @@ -222,8 +223,7 @@ nlist_kill(notify_list **head)
>   
>   	while (*head) {
>   		next = (*head)->next;
> -		nlist_free(head, *head);
> -		free(*head);
> +		nlist_free(NULL, *head);
>   		*head = next;
>   	}
>   }

