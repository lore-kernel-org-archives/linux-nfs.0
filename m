Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43599410D1A
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 12:26:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784809608; cv=none; b=jT84RaHF/LZfOQyajXRKd9XqeA8mTWi7U7UkYlmMUIBStcxzrlT7qGG92kWkoDv/CH2g0candkCgKktSV7RhY0fuZfsDvHthmV72Juisqz5N6DUBWLT60i7CvMOC3EiFweTzFtx1EL0reX49abI8ptdWDiyd3uiYQepNkZfF1ac=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784809608; c=relaxed/simple;
	bh=yhTc1SNfKvCcIHMNqK4fFNLaDWRCj43wSEd6ww/M98Y=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=JHuy2fkW0Awq9Ke5HsQF+NXlmE1gJShgPgdoweCxSfk9oe4pwG7K6QoGUkeqxSMmK/3ngqo36XAj+vu+sI1Jr/ielHADQeJkVlQeCb4g8xj5nel0IUv4q7Sld4KVvBfvBYxHI5wcVpBD5RkyD1jhQb2SVF/sa3E9qN74FDqn+Zk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=XQ5X1lv1; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=IYXdang/; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="XQ5X1lv1";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="IYXdang/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784809605;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=vpgj2o1o5Q8SGAkmiivx5urxR0gjewoHKBOa9Cxc4I0=;
	b=XQ5X1lv1yXVLRUbmy7i8m09OrSUCPu2DmvyVHV+BVcdrznDpyzK+KHBjQnK8StDt5Jn0q+
	3yGY/qy99ifOAqFjuUXjtPUJS6UX3lhwJVMEGP75UXz+MlquQ28d7CF2a/4KVORUxZsr35
	sFmzLide2nV3VdCJ/RyDPCq1l+QkHuY=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-502-jfGrMHNBOKy6xbPzziu_Kw-1; Thu, 23 Jul 2026 08:26:43 -0400
X-MC-Unique: jfGrMHNBOKy6xbPzziu_Kw-1
X-Mimecast-MFC-AGG-ID: jfGrMHNBOKy6xbPzziu_Kw_1784809603
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-8e97889ac8aso12062206d6.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 05:26:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1784809603; x=1785414403; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vpgj2o1o5Q8SGAkmiivx5urxR0gjewoHKBOa9Cxc4I0=;
        b=IYXdang/x+51GBdGF0gEK2tWKA0THKYNTUS6UC5Z/vFwkZjZfn9/SWU3myGcltZLk9
         5cmbyyYOSAFkZi52rTbSPHsLGSWAlAhugSuVUJGdE8jhPG0K1dOXQPSGUkl11hapXSMC
         7XCGOZ1sNRHgTSYM5b1YH9E7R1CsxAut1M+Ebwv9KP8Lqc4Ddffyq8oGbUagTZSZGC8p
         G7AwRmo3IzhRV5yIlSg+SflrykljAGLm2PZ912chs19Z0CsiGKTrlNIs3lCfVkFBqDnl
         obXk2oCZHfcxKDwmHHO1PynN1WlVq+Uz8zieMYEYTrzC5jxbhihECLN5LxQztiyyKudf
         nEdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784809603; x=1785414403;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=vpgj2o1o5Q8SGAkmiivx5urxR0gjewoHKBOa9Cxc4I0=;
        b=srfwk37nXMe902i144EmmINXb+tQxsHHAmZhOy284DXkkFCL00PW2yHONCk1u15w6a
         70+MqSCRBI/VGgAzdr0wSd2CjUpy2hY62vVMwaawYU3QRJ3U3hj5FTJGeZ1Xax8Q1SoA
         GpwnY4s/0GZuB6X6QpqiFxusgjROX5/wbV6aTUijtz/pykuZhtgzQUuTNXUmIdZXh0wI
         iPY43L3bGyEkC4uDoUdMqaeanftzCBHH9us2fkcXdUmgquPfDN4Fog5TiEHzi+Gz1HQ+
         Wg/Cs/Wa/4+JQYxsy4LOdsfp2RAakl6lRyxCDcMAks+A0nu41NQFjyA71nBSB43nFnzU
         3zzA==
X-Gm-Message-State: AOJu0Yz9lsA9LGILKFVP2UJLAjf8WzYe7ddbca2smRgSeWMz/x9dRos7
	cTpd6bllYlEpukMZZ2HNA+NhuuXZj9rGynVYMc/iGTlGSPWSCNN4wGfiXyjdOP46lYj1fPha/en
	qmMyn6IkGy4a2xA1ERLKrMCtuliF9Gdlfnla41Guj7NuKhfKmkY4+9i5zUYMZFA==
X-Gm-Gg: AR+sD11pMsP5Cev6jV7d+Bdj8W051ej4wDnOyM4a1dr9zVUE4jt4jAhyGbCmzal8MC2
	9PRPynmkcTN7h2upCKjN0HTUpO4wcv2iiZCWtpSqqHKKJTSuLgZQxlu/cmzLkS2lXuUQmPKuQhj
	IaRAWEaWPf1wg+sOGjSfGhJnVds+xzoiipYBBMgqDQahJCTbjfMGv/4ykpf4KZ10NYz1T5MGWtT
	8KBezxF3GYA3VQooO53VAwrhUDG0iregACT3Cs0FnIotmmH6uq738H5IB4QKED4mmUl7xYYBG4d
	vE6CtNLjBhbS6kwrJGhoKPYRLmW0MZya9tXGVUuk6mv6Dog9L5KeYAlShZC07JCpq/jpVBawS/i
	q
X-Received: by 2002:a05:6214:5bc7:b0:8f1:8349:59ee with SMTP id 6a1803df08f44-907ca5e73d2mr29710056d6.35.1784809602937;
        Thu, 23 Jul 2026 05:26:42 -0700 (PDT)
X-Received: by 2002:a05:6214:5bc7:b0:8f1:8349:59ee with SMTP id 6a1803df08f44-907ca5e73d2mr29709726d6.35.1784809602348;
        Thu, 23 Jul 2026 05:26:42 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.243.135])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907ba8b31dcsm43697476d6.3.2026.07.23.05.26.39
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 23 Jul 2026 05:26:40 -0700 (PDT)
Message-ID: <04269fed-393c-4e11-92bd-31921f563e9f@redhat.com>
Date: Thu, 23 Jul 2026 08:26:39 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: nfsd: fix memory overflow for haddr
To: "zhangjian (CG)" <zhangjian496@huawei.com>, chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
References: <356736aa-25d8-4b79-a50f-33b4e7035856@huawei.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <356736aa-25d8-4b79-a50f-33b4e7035856@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 7/14/26 4:43 AM, zhangjian (CG) wrote:
> when hcounter is not 0, haddr memory is not enough.
> asan report heap-buffer-overflow error in following scene:
> CFLAGS="-fsanitize=address -g" ./configure && make
> ./utils/nfsd/nfsd -H 192.168.1.1 -H 192.168.1.2
> 
> Signed-off-by: zhangjian <zhangjian496@huawei.com>
Committed... (tag: nfs-utils-2-9-2-rc6)

steved.> ---
>   utils/nfsd/nfsd.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index c95d32f4..e3fcdde4 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -185,7 +185,7 @@ main(int argc, char **argv)
>   				hcounter = 0;
>   			}
>   			if (hcounter) {
> -				haddr = realloc(haddr, sizeof(char*) * hcounter+1);
> +				haddr = realloc(haddr, sizeof(char*) * (hcounter+1));
>   				if(!haddr) {
>   					fprintf(stderr, "%s: unable to allocate "
>   							"memory.\n", progname);

