Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256830;
	b=NxZYAv/Bh25uYAjnKqBiF7RmlIim0janJ2mcHUae42BHzzKIjpOqOMo/zq9sNpumFVjb
	 7+60HiY2iplRqZgXou6uW8MjJBqMqZhgCoBaJ3RWJsFqYWc9UzO5qvD7MrFEXd9VwVLLX
	 FDzA5Vu+LR0nc4Rp7G05lWNp0nOFBTJZ6nC8HxyS1eCM89wzXaEH4lcqIeNn1S2SKn6Jd
	 XVhCISReKX2worVtl3CyuwqcS4jCnu9fxiFCI4QWeNu8D0CyFSGUY76wdHiF/r7/Zeecs
	 e5fPhAiQ/owcCBeZMeR1Owbd6dnbUuWiWQPRQqwdpXle+5DBiRDeX5quc1lg0RVyVnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256830;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:References:Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=MdiKeGP7O5ZGOQBfri/HkycbA3OkA90HO2mjHp2zSQQ=;
	b=h3l4MEz3y1S0rvVimJ+l/4niBHTRKMDjAul52I1NBxzXXaqJF5/8j9XzEy7l8nGPdiRC
	 cazmpbsxp11yPspSHSeDp+Ip7C05ysijrBKSYjd5z34oM7BwiDTZIKk3AgaHCCXl5rF+y
	 hZCho2ThqQPhSXr/5M9IktWc/tk5lvmuoKTsIgPGUdCRspFhPjv6/Cu9xj7xwMb9FDsSV
	 xBn7kNUIIIE6hI1aZnufXm3lGDKHPZEgnaRi6mHIDS8ZDBD5+b4bNPIgVTrqEV0L9IUU1
	 HcbW4y9V2B9bA5VgI6YV8hxXCuZutQKTM+GrC/r5bWNwa98Q1mYIPTOrVQ5KpQXRNmA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=GYQ5ZwJe;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=dOqe7gWp;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88D2A606A326
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 20:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 88D2A606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=GYQ5ZwJe;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=dOqe7gWp
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794256828;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MdiKeGP7O5ZGOQBfri/HkycbA3OkA90HO2mjHp2zSQQ=;
	b=GYQ5ZwJe2zOGlPRJ6VVhNrxBciMB4TIPzB2xp3MIESCpvapZ2qxl8SVcW0q7iPJCTLy1Xm
	CVQx5GFwUd78+etPHmzddFoMtdHz70ZbTCQ2gMtgB9wJxtwWbZBiG9Kcn1LSyiWNtmu+Is
	TUaguugIfHz/Yz492N7M6fb2uefotG0=
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com
 [209.85.222.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-56-mtbW6qIhMuakrRGMO5ITJA-1; Mon, 09 Nov 2026 15:40:27 -0500
X-MC-Unique: mtbW6qIhMuakrRGMO5ITJA-1
X-Mimecast-MFC-AGG-ID: mtbW6qIhMuakrRGMO5ITJA_1794256826
Received: by mail-qk1-f197.google.com with SMTP id af79cd13be357-94607500fb0so231020785a.2
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2026 12:40:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794256826; x=1794861626; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=MdiKeGP7O5ZGOQBfri/HkycbA3OkA90HO2mjHp2zSQQ=;
        b=dOqe7gWp7u6jU8EzEdlDsQGkb2A4bSpSOVuLbtGs7B8jfplfsdF2+HQAQKA5+eA37n
         6A6YHm1hwrRwmdtrHDYLXaHZFZuwsDs56QHgViOgrTDuHDNtYOZj7RF109Gc9zk1sj6S
         mHzSSJnKEN0oSwEom/3/Jfg7B+bKd3zK+n9Fb7j7tH6dFSos+W4NpzqTvI3W0UadFr07
         6dhtVHI7ESpT8cXl6E8xCz4XdX7VPVID1lwtZYDoIU3ooMaJ4Jvjtlqxkq5H1X0JtGYZ
         yZmWlf5OpWwqag+QabRf+eoXpg+Y2Ja/ec1ilGedBva/0QkHHanMV5ouks4Ecq0y/D86
         uWuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794256826; x=1794861626;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MdiKeGP7O5ZGOQBfri/HkycbA3OkA90HO2mjHp2zSQQ=;
        b=dYW1vZtnP8P5t420vag1LmqPn1g4Z7dV0HCcwF/k2DAWDWh2V51CoT8xzBCuWsTGdh
         y9g+IBSzaPOWzGyFrWG2oKSLQKGN6o2Rhj2lEEEHoh5iDqKq+hMvyNnmGIBS7yP8YrRU
         i0m6EkzthAAxy53Mx0R3F2lUSFUyIdnzXFdpFO13LpC37UHdGmbZhG+we+CfiWd8HeF7
         RZgvGjNjbYfOKEsxewPcArn7kRDY7PJt0qPiSkYagq1amYnT4uc91WjSO1FLxguM7Bzm
         eoftSdFpU71xT8SwVT7+HqNdj1A0DdtmU8Gxm85svsJ7u0gy/fWUcYRoIJ5yQewXCrvV
         aPMA==
X-Forwarded-Encrypted: i=1; AL+hErGgskIuveqEzEYv0OtKU3QzNhBZmUayjkpJizVjJ5yg9zELtdx/xGieDgPrCEPXI5DBLPIuprlEWyE=@vger.kernel.org
X-Gm-Message-State: APuU4Z8w3bo6iSLJqnYKgvZhfIf1JKZXMsoCogMho2/SN69O4irs2fP1
	Py9RR3K3WFND3G6Y3F1zutFNjk0G7O3z/2kurakJ5Z5FVka8ly+uKmsfK7S+EikF9pds1WszuV2
	y5YV6PIUF6iFJ0mFxXaccKJZzNCgdOWV8rulvcU/csAYgyPl4abI9kuPXGqNB2w==
X-Gm-Gg: AYBFou0iulziTp45BC/8LL4T1fhcis0kOoz4p6GnRjHOnPA7aY/usrshPyX/8X8hpXa
	sUCOp0NdMqsXLGJ6WIpj/2GHa9I7FIj8pG0ZWtG3Pev/rGa4kN0vGoAS7gl8iyyni3Dy6/Kt6to
	aXqUaEpVulAfYsSdsVJpZ8HeWcr+nDhhIqg0Vc5/9nEYJVx0l6C2wQVl5TPxbM5N773q/hIxmv1
	b+MYPOXafVSB6GIVYJG4sgJmtMKGN8Lqk1Ne7vOCvyV+Zk06Sw+Ii4KWJwrFh6u3g3eK4StGLGk
	+1hkYHghtZZQO5pkkTELM42MQCnuYPVOSGM7OAmenUF3o8jb54nAysXyPVAxa5031mTOwJG8Smv
	L2tHQ3pTCZ2+NFQ43HVevuwNTSl5iJ467u1B6U32HFQYchrk=
X-Received: by 2002:a05:620a:8806:b0:93e:5fbf:a41c with SMTP id af79cd13be357-9479f2b05e5mr106017885a.16.1794256826262;
        Mon, 09 Nov 2026 12:40:26 -0800 (PST)
X-Received: by 2002:a05:620a:8806:b0:93e:5fbf:a41c with SMTP id af79cd13be357-9479f2b05e5mr106013385a.16.1794256825576;
        Mon, 09 Nov 2026 12:40:25 -0800 (PST)
Received: from [172.31.1.12] ([70.105.245.156])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9479e7a8348sm59726985a.26.2026.11.09.12.40.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Nov 2026 12:40:23 -0800 (PST)
Message-ID: <8e468ecc-7874-4473-a04f-8ac8432ae2e6@redhat.com>
Date: Mon, 9 Nov 2026 15:40:22 -0500
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
Subject: Re: [PATCH rpcbind] rpcbind: bind the TCP listeners to the -h
 addresses too
To: Orgad Shaneh <orgads@gmail.com>, linux-nfs@vger.kernel.org
References: <20261006083746.353335-1-orgads@gmail.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261006083746.353335-1-orgads@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 10/6/26 4:37 AM, Orgad Shaneh wrote:
> -h restricts only the datagram transports: tcp and tcp6 still bind to
> the wildcard address, so rpcbind answers on every interface over TCP
> even when -h names loopback and a single internal address. A host that
> uses -h to keep rpcbind off its external interfaces gets that only for
> UDP.
> 
> When -h is given, take the stream transports through the same
> per-address loop as the datagram ones (AF_LOCAL ones have no address
> and keep their own path), with the SO_REUSEADDR and listen() that the
> wildcard path already does for them. Without -h nothing changes.
> 
> Assisted-by: Claude:claude-opus-5-5
> Signed-off-by: Orgad Shaneh<orgads@gmail.com>
Committed... (tag: rpcbind-1_3_2-rc1)

steved.> ---
>   man/rpcbind.8 |  2 +-
>   src/rpcbind.c | 15 ++++++++++++++-
>   2 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/man/rpcbind.8 b/man/rpcbind.8
> index 15b70f9..03b5514 100644
> --- a/man/rpcbind.8
> +++ b/man/rpcbind.8
> @@ -85,7 +85,7 @@ checks are shown in detail.
>   .It Fl f
>   Do not fork and become a background process.
>   .It Fl h
> -Specify specific IP addresses to bind to for UDP requests.
> +Specify specific IP addresses to bind to for UDP and TCP requests.
>   This option may be specified multiple times and can be used to
>   restrict the interfaces rpcbind will respond to.
>   When specifying IP addresses with
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index c39df97..1215c73 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -535,7 +535,13 @@ init_transport(struct netconfig *nconf)
>   		hints.ai_socktype = si.si_socktype;
>   		hints.ai_protocol = si.si_proto;
>   	}
> -	if (nconf->nc_semantics == NC_TPI_CLTS) {
> +	/*
> +	 * With -h, bind the stream transports to the given addresses too,
> +	 * not only the datagram ones; AF_LOCAL transports have no address.
> +	 */
> +	if (nconf->nc_semantics == NC_TPI_CLTS ||
> +	    (nhosts > 0 && strcmp(nconf->nc_netid, "local") != 0 &&
> +	     strcmp(nconf->nc_netid, "unix") != 0)) {
>   		/*
>   		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
>   		 * make sure 127.0.0.1 is added to the list.
> @@ -621,6 +627,11 @@ init_transport(struct netconfig *nconf)
>   			}
>   			addrlen = res->ai_addrlen;
>   			sa = (struct sockaddr *)res->ai_addr;
> +			if (nconf->nc_semantics != NC_TPI_CLTS &&
> +			    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
> +				       sizeof(on)) != 0)
> +				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
> +				    nconf->nc_netid);
>   			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
>                           if (bind(fd, sa, addrlen) != 0) {
>   				syslog(LOG_ERR, "cannot bind %s on %s: %m",
> @@ -673,6 +684,8 @@ init_transport(struct netconfig *nconf)
>   				(void) free(uaddr);
>   			}
>   #endif
> +			if (nconf->nc_semantics != NC_TPI_CLTS)
> +				listen(fd, SOMAXCONN);
>   			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr,
>                                   RPC_MAXDATASIZE, RPC_MAXDATASIZE);
>   			if (my_xprt == (SVCXPRT *)NULL) {
> -- 2.53.0
> 

