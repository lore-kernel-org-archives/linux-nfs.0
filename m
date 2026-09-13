Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F4208632B
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 03:48:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789271324; cv=none; b=iGahk6eb3MrPwD8+J+NIgMRgJmLIlS/onUXkFHGkrLTyWYDiLU5pS0sU/sfPFxeqjIy/cVAxwmuUE08pfCnFVfxjfIx9jacTYMIrJIgrQQq7wqyY5qDERpmy2lgZZ2gY7IxBUzHh9tyto5qO8ioFzNrjBnpnXrzQNpcHBf5gaSs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789271324; c=relaxed/simple;
	bh=fl6DMI/WxXo8v2mbzgp5uRXYnAo+b+SKX9SwzYJWjiE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Wxsnpt/ANwVYqCk40lqpsSzW0Tgu0xOZNmACLtOsC1+PJ/gibOai+GxxYAXevvwGsUloznbFQpats9zMVLjo6diiU961KY6JkqHfflc3Yn4R/eTgSDFvFQIVd1qorpMlh1BsGs+C46LXUCFqGE2CkEkSvjJpFOz+FGnl+xEgim8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=O1OmexM0; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=cYWTlU9t; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="O1OmexM0";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="cYWTlU9t"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789271322;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=fNmS6Jlj8y0oxr8/XheQarOTd5hbXNspPNiCc2h4OW4=;
	b=O1OmexM0pw9WXCXA7ILXA1o887+oQ5M1dsa6O6oo6XYNQTYiO7bE/MeZXyFFNRf0MQas9N
	QfLYyngvTSx0MlKUgS/+8PFUuYGdDGQmkCj2vWHNXz6rjkmgnrPLeL5V0STxuZnzirUGHp
	6CkZr33wvbVUoJgth/7E8nhmhnQTEpQ=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-94-11qqk_JyOJ6R-rgLeYnAfw-1; Sat, 12 Sep 2026 23:48:40 -0400
X-MC-Unique: 11qqk_JyOJ6R-rgLeYnAfw-1
X-Mimecast-MFC-AGG-ID: 11qqk_JyOJ6R-rgLeYnAfw_1789271320
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-90e8135d7eeso39907836d6.1
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 20:48:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789271320; x=1789876120; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fNmS6Jlj8y0oxr8/XheQarOTd5hbXNspPNiCc2h4OW4=;
        b=cYWTlU9tiaHM/vgli62ESY+GV88iwn76MoRWs1pKmgh/CtXV78BGiSWGx8QASV+jpi
         DjZ4hLwHtKW5ifHhs02NO8Ei39A6g5HxnD4vubmPaLEPlUyj/U8nTlDUWt/YYv4/w2oh
         yNlq44hGSvV4YhYm0XMIpFKX/6yQiYqpZz7F7UvoLfTHUedxeFum4uqQCgIRDVutg0j4
         rro9CwY3YCR3Fo+rKkCXHd58T4GpdZZLJdr98jVXJCwKoUu6NvaCnBzZfnYeepknlA7h
         DnVnQu/oBsZhNJ9tLj4gN9tGE/qjFVMj6hpKzEsTnejkw5rC9Gaq7rt4KciEiVnrt0v3
         i+XQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789271320; x=1789876120;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fNmS6Jlj8y0oxr8/XheQarOTd5hbXNspPNiCc2h4OW4=;
        b=roKJC2h8x/JaqY1absWAyZxYT9GzD9Fq09D/jLX3a/HGgAfHV8InLidcOdk15CfcvG
         MQEgFRP8xH19GYurG+MevHkC5et0Jsxac7Iza4Y3M/du3Qr4PYPWykRCWneZeHkOSlRJ
         oQf6wfMQ3NuKqpQEDVs/h+LtSSOS6X7QwZ0H56DpYse983ZkQq1F9F9ZMGHDI++SF3if
         37MJYJouYbaQueGtVPX5VvcEgkMFCcCEdo5+3Uwt51IJZf2LHgu9OePhSEeLxP11tLA2
         OtRmpWNGvzw3HqOT3/kDv7oApd5GFlbX6drK8Jv1FdKY9KaVgfUYlEME9hHFgFLMY4AF
         28mA==
X-Gm-Message-State: AFuF++kQj0E+jjUxzE+nxLHxh5xJTKlyuvWRShqirEApxf/NP/w17mTl
	tYpkMdIGze3UDYPbMFFsMEDVjX1RYkAPCAmQkZKQM46SScYUbmkKdibUKkZBw58BzLwlO66RlG4
	lkDNtXzDm6ZZ7Crtwf2l54ZxmZxxsDiZ6DmZI4x8b/KZ253kgGBJK34bY7jbSFw==
X-Gm-Gg: AYBFou2E+YGEHrcncyCfxFw86cUAyLTvNIIB1aI1rB7SSMAlkRCzJiHfvHjc1MPNQtQ
	9oE0c0sv7EDsLTyVxtnvqWJr3sxIFtnCiUv02hzHZKVsORxlglt/Y1MvxgEyLKMkyrFzBngTOor
	/V+yEnxPX92Piewt3jZqqQnb4Vow23UoROkU2vWl5pVLxPHQyyRDfwr9tQIzc9ZE37GM+frvCWg
	3l7Bo+gUJu41UUfo5HpNOA7OkzdSJnsjSX3frmM6FuLGKCrE7qAslG6FNNxdwaApbgC37Sfi9wT
	q717+y0aFwhMEyvH6ZbClM9vtzEJVVU+xZ7fzWvWZZSrHOp5Qdexztk8XSYf75g81hQLVmIh0h0
	=
X-Received: by 2002:a05:622a:4c1a:b0:530:f44b:5867 with SMTP id d75a77b69052e-530f44b5b8cmr61567551cf.26.1789271320115;
        Sat, 12 Sep 2026 20:48:40 -0700 (PDT)
X-Received: by 2002:a05:622a:4c1a:b0:530:f44b:5867 with SMTP id d75a77b69052e-530f44b5b8cmr61567241cf.26.1789271319679;
        Sat, 12 Sep 2026 20:48:39 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-530cc781402sm59745181cf.7.2026.09.12.20.48.33
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 20:48:39 -0700 (PDT)
Message-ID: <b52e4ead-a2d9-4deb-9e45-a64fdd96d9d0@redhat.com>
Date: Sat, 12 Sep 2026 23:48:32 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/3] libtirpc: limit XDR decode node count
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260907011328.21425-1-okorniev@redhat.com>
 <20260907011328.21425-3-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260907011328.21425-3-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/6/26 9:13 PM, Olga Kornievskaia wrote:
> xdr_pmaplist(), xdr_rpcblist_ptr() and xdr_rpcb_entry_list_ptr()
> decode linked lists with no upper bound on element count. A malicious
> server can stream arbitrarily many list nodes, forcing unbounded heap
> allocation in any client that decodes the response (rpcinfo,
> rpcb_getmaps() callers).
> 
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
Committed (tag: libtirpc-1-3-8-rc2)

steved.
> ---
>   src/pmap_prot2.c |  9 ++++++++-
>   src/rpcb_prot.c  | 16 ++++++++++++++++
>   2 files changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/src/pmap_prot2.c b/src/pmap_prot2.c
> index 7611bd5..d043f34 100644
> --- a/src/pmap_prot2.c
> +++ b/src/pmap_prot2.c
> @@ -39,6 +39,8 @@
>   #include <rpc/xdr.h>
>   #include <rpc/pmap_prot.h>
>   
> +/* Cap decoded list length to prevent memory exhaustion from malicious data */
> +#define PMAPLIST_DECODE_MAX_NODES 1024
>   
>   /*
>    * What is going on with linked lists? (!)
> @@ -87,7 +89,7 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
>   	 * xdr_bool when the direction is XDR_DECODE.
>   	 */
>   	bool_t more_elements;
> -	int freeing;
> +	int freeing, node_count = 0;
>   	struct pmaplist *next = NULL;
>   	struct pmaplist *next_copy;
>   
> @@ -102,6 +104,11 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
>   			return (FALSE);
>   		if (! more_elements)
>   			return (TRUE);  /* we are done */
> +		if (xdrs->x_op == XDR_DECODE &&
> +			++node_count > PMAPLIST_DECODE_MAX_NODES) {
> +			return (FALSE);
> +		}
> +
>   		/*
>   		 * the unfortunate side effect of non-recursion is that in
>   		 * the case of freeing we must remember the next object
> diff --git a/src/rpcb_prot.c b/src/rpcb_prot.c
> index 809feb0..0b0574f 100644
> --- a/src/rpcb_prot.c
> +++ b/src/rpcb_prot.c
> @@ -89,6 +89,9 @@ xdr_rpcb(
>    * serialize the rpcb elements.
>    */
>   
> +/* Cap decoded list length to prevent memory exhaustion from malicious data */
> +#define RPCBLIST_DECODE_MAX_NODES 1024
> +
>   bool_t
>   xdr_rpcblist_ptr(
>   	XDR *xdrs,
> @@ -101,6 +104,7 @@ xdr_rpcblist_ptr(
>   	 */
>   	bool_t more_elements;
>   	int freeing = (xdrs->x_op == XDR_FREE);
> +	int node_count = 0;
>   	rpcblist_ptr next;
>   	rpcblist_ptr next_copy;
>   
> @@ -113,6 +117,10 @@ xdr_rpcblist_ptr(
>   		if (! more_elements) {
>   			return (TRUE);  /* we are done */
>   		}
> +		if (xdrs->x_op == XDR_DECODE &&
> +		    ++node_count > RPCBLIST_DECODE_MAX_NODES) {
> +			return (FALSE);
> +		}
>   		/*
>   		 * the unfortunate side effect of non-recursion is that in
>   		 * the case of freeing we must remember the next object
> @@ -178,6 +186,9 @@ xdr_rpcb_entry(
>   	return (TRUE);
>   }
>   
> +/* Cap decoded list length to prevent memory exhaustion from malicious data */
> +#define RPCB_ENTRY_LIST_DECODE_MAX_NODES 1024
> +
>   bool_t
>   xdr_rpcb_entry_list_ptr(
>   	XDR *xdrs,
> @@ -190,6 +201,7 @@ xdr_rpcb_entry_list_ptr(
>   	 */
>   	bool_t more_elements;
>   	int freeing = (xdrs->x_op == XDR_FREE);
> +	int node_count = 0;
>   	rpcb_entry_list_ptr next;
>   	rpcb_entry_list_ptr next_copy;
>   
> @@ -202,6 +214,10 @@ xdr_rpcb_entry_list_ptr(
>   		if (! more_elements) {
>   			return (TRUE);  /* we are done */
>   		}
> +		if (xdrs->x_op == XDR_DECODE &&
> +		    ++node_count > RPCB_ENTRY_LIST_DECODE_MAX_NODES) {
> +			return (FALSE);
> +		}
>   		/*
>   		 * the unfortunate side effect of non-recursion is that in
>   		 * the case of freeing we must remember the next object

