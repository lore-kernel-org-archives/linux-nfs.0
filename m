Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9C9F50C298
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:19:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789568368; cv=none; b=DCd0VRbW1pmTi9y88VfW3gIPeHcfNIhRb3jASRIbrmxVDAB3PcgQ4LIM4gbbxU6xRGhNqyu5w2Y2BKXwSa9YeB8Md0awTMIze1KHvhfmHsrQKf+JozAcI0DYyKEcVZL6ki8CTIFqeA0HYM4uM8Ivcn7TClgOyXeQ8aQKgIxovOM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789568368; c=relaxed/simple;
	bh=STsd6Gwx7l1ZUzvKis1OVlsRHSAF/5Fd7D16HJJsr5U=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=rDpYm/nBhrmuVayKc9XoQr6udu868c6vTISXELTHC6evRb1w3tmJZ25ZFE5dvNYQAeA2xoBk0avYv7vyVpkLz5I95fIaDQShCjkxtjSm4qPQwlwY/hC96NdQ4l+VdeoKO0u2SXHOxnQklTnQVPvFj2N8XytepRMfzIOjEMuFkVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YKm/TTPW; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=T9u9waUH; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YKm/TTPW";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="T9u9waUH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789568365;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=uMk0U98aZkVkTWYrU2gIAkE3NOE04SXAwK0cv98ImJk=;
	b=YKm/TTPWwhgsNbxVqfHcgyV7hTkb/lTazoCk1xeKUbqv5nbBX4sUEpeb4LRpTssXu40/YP
	BTIANJ7N1qKXb0JE754Wnv+DUhHCpALewwJZx1XEXNLAeL779bX2+5T/DafWAV8jM1jsLf
	xTykQPoPtxtlEJUrahGst4wuKIhBwpc=
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com
 [209.85.218.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-130-tDcaWL82NlOcnW4-VrE4PA-1; Wed, 16 Sep 2026 10:19:24 -0400
X-MC-Unique: tDcaWL82NlOcnW4-VrE4PA-1
X-Mimecast-MFC-AGG-ID: tDcaWL82NlOcnW4-VrE4PA_1789568363
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-c294c2dcdf5so556255966b.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:19:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789568363; x=1790173163; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uMk0U98aZkVkTWYrU2gIAkE3NOE04SXAwK0cv98ImJk=;
        b=T9u9waUHvMANg7wBAriHXx8nG6N5au24PuqYgksQI9ZQq5BnF/ke3PVIUP/Wsb07fn
         otsnxPhRyMRiL3l9py6SjPg7F/V7ebsxm8KbEo8y8QHyEkQ49eDKjOtCG81SX+/+/KJa
         fT+Xq0Ul6hbxgjlqPqb2lFH52P5i3A/r6t/22FfLBvWHMO3wDT8pNjWVbF2SFrXL5++d
         6EA/l9OaMHv0dPB2pFrHpkTdoJvn5phSlmPXHAkxs4a6MiEnSWLve1So7QVw2TeptFRj
         T4wdrHF2Y8VlF8slhNJ6DGdJ+66F5UnIzOrC7M4c3cemB++s/Y8ctYixk49txL5Z9mVq
         lZqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789568363; x=1790173163;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uMk0U98aZkVkTWYrU2gIAkE3NOE04SXAwK0cv98ImJk=;
        b=mJsB8IkaiCCQJ/0Oa3gv5ZETWVgnbYBYBkd/y5xJUlY+lSvqeR+WxKRHeJNLbK6BpO
         pu8bcGjPqHuZSNRHLlOi2lux4HFaPFIgBAWKFiet8aGbn7LYk1e9il16oAFBUqNMud2k
         82Eum191mUuo3Ja9RQo4dlwpWEsrUErexa2K5IbvEVzO9P1Oji/c2Y+vjZI67myk4qig
         0GxzZWApNjjkM69WQhGFKLL544WYZV4OFfgn9PqI52cvRAg8NP/CORnPUZL+mDEJ6Ipi
         iEcmsP38Tc02Okce5nNGobGCCnfmngpP5fKT4E20Q+KomjLP+Cgmudv7xJTN4F4JFfDE
         g0Cg==
X-Gm-Message-State: AFuF++nj6RNPQ3lzaEVu0iukqhbvj/UMUO2JPs0GAYMDaa3g1IQvmxjk
	LZMJrSCoFpT0u97QrzK3Q8LXHtviZ9TD3HotRzJYujn4yGQpqZoOtBN76l/ij1W3bS4VviUFsOs
	rWUTf5ZzBSOpkqtVFEBgD2mUFLa44ecLRgdXriBo5jfYpm9vocQQqtLgmFhlZfQ==
X-Gm-Gg: AYBFou2AvzgWZK3fT93I4nuuUEzsalyfCl5dxJ01vIF3wN8wEpb7GyJJjw33c2DyuQo
	m+jQfZkUHC+25lDlm6xRUSteFhuIItqWdfsZWNikLM4H8NNsqW5alOWfjhdyVBSX/iZc7hohwZL
	T3uMCHW/5O5wD0Sh/p8Wrnu1sUKMHCk8RleCrraCNCi3l+/3asD34LOpMW4P5BsnSgFZ6uAABZh
	Pb/CAzuzrHhqCinI0Ljv4haqeoTq4fmjUUZigfQjCT57rBDNSW593X72nCnfqo2zWA0jjPeT/70
	kvQV7uvN9xX+pZGXpkFm6PhwfZWsIEXEQXIih23T7PtporuN3D1RA9/JZl0AL83ljXOp4FicYdE
	=
X-Received: by 2002:a17:907:9724:b0:c29:41d1:a0c9 with SMTP id a640c23a62f3a-c29e53470d8mr197237466b.44.1789568363323;
        Wed, 16 Sep 2026 07:19:23 -0700 (PDT)
X-Received: by 2002:a17:907:9724:b0:c29:41d1:a0c9 with SMTP id a640c23a62f3a-c29e53470d8mr197235566b.44.1789568362871;
        Wed, 16 Sep 2026 07:19:22 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c29de6040b8sm144175866b.48.2026.09.16.07.19.21
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:19:22 -0700 (PDT)
Message-ID: <3c533de0-da68-4e21-a410-26a9496f7db6@redhat.com>
Date: Wed, 16 Sep 2026 10:19:20 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/1] fsidd: require root credentials on abstract socket
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260907011328.21425-1-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260907011328.21425-1-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 9/6/26 9:13 PM, Olga Kornievskaia wrote:
> fsidd listens on an abstract UNIX domain socket which has no
> filesystem-level access control.  Any local unprivileged user can
> connect and issue mutating commands (get_or_create_fsidnum) that
> grow the reexport database without limit, degrading mountd
> performance.
> 
> Add a SO_PEERCRED check to reject connections from non-root
> clients.  The only legitimate client is mountd, which runs as root.
> 
> Fixes: 6fd2732d ("export: Add fsidd")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
After all the recent fsidd changes this patch did
apply cleanly..

Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   support/reexport/fsidd.c | 9 +++++++++
>   1 file changed, 9 insertions(+)
> 
> diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
> index 9b80b451..c714386e 100644
> --- a/support/reexport/fsidd.c
> +++ b/support/reexport/fsidd.c
> @@ -7,6 +7,7 @@
>   #include <dlfcn.h>
>   #endif
>   #include <event2/event.h>
> +#include <sys/socket.h>
>   #include <sys/un.h>
>   #include <unistd.h>
>   
> @@ -147,6 +148,8 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
>   {
>   	int cl = accept4(fd, NULL, NULL, SOCK_NONBLOCK);
>   	struct event *client_ev;
> +	struct ucred cred;
> +	socklen_t clen = sizeof(cred);
>   
>   	if (cl == -1) {
>   		if (errno == EMFILE || errno == ENFILE || errno == ENOMEM ||
> @@ -162,6 +165,12 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
>   	(void)ev;
>   	(void)d;
>   
> +	if (getsockopt(cl, SOL_SOCKET, SO_PEERCRED, &cred, &clen) < 0 ||
> +	    cred.uid != 0) {
> +		close(cl);
> +		return;
> +	}
> +
>   	client_ev = event_new(evbase, cl, EV_READ | EV_PERSIST | EV_CLOSED, client_cb, event_self_cbarg());
>   	if (!client_ev || event_add(client_ev, NULL) == -1) {
>   		if (client_ev)

