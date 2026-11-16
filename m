Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794841676;
	b=bKR33OUTu5+5lFBqDYqwngFXGS5gXwz4bmPB6J0fSSP9IVmKRYaUvVjNHp+tKjnyM1LS
	 R/q36wag0++0LNCYkhf3zpTUPwBl/rpPSUn0CI67sH/XlFwb5AtKaNbqHz+chjmwygxHK
	 2xFwny5VTX/M4eYoeExCpkBwMwZ+0pMt/O6QSttA7W+xzdhtY9tA03DWX1nWYwY8CkEK/
	 0UrAthorQDBKOp5xMldH6S4XTFnXb/aFz6a7PaLfwvS+ZuyC3C4629ivRDe36RTz7QzwU
	 OUh5drHJqeQ77NEnHGvnDQ9jlif1wnTFu7uM2hlSY+DudT+cFyNT41wB46Vw2ksHdWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794841676;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=cM3QLUhGrpStinpnv+wMKIwxc19R2VnYQvR9Rwtt3PE=;
	b=1ww8tkb+sH42HcmI+XVfVEUMWRhzXcAao4/Ot0VGpFoD0XW5eSqALfP6tupVm9o9v7Pi
	 Y8JrFXzdDjGPwunKE6rQ4ZjZq47dRu65STReFJHqy/YW8fc/FkGlHsjhpm6sQVwAzMcB2
	 XYmcsCzqyg113r+8ZG+kr1N9pd0HtPJcoVRiwOpnD2OopD3Ts8nnpb020L5B+f4aJ+lls
	 GiDvrUPxKM80plD7vMY3KdZTXAbdZa7sK6PetxeSrLKz5bBg27UgvlkGWC+2nT7ci+Bwk
	 WBq+5RqnWz5n9DoL49IoN4gvgxq7/68Fe7T/88r/jTULuQDO+g6iAHDoDG3HbT3PIMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cFj+8y89;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=BJFeHx0m;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E330606A880
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 15:07:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2E330606A880
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cFj+8y89;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=BJFeHx0m
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794841675;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cM3QLUhGrpStinpnv+wMKIwxc19R2VnYQvR9Rwtt3PE=;
	b=cFj+8y89eWwT4ZdbMYci6Lf/kImkZQWFEWPSjpMtf2BesZ465amiHLR5WR6Kv++WStLRiX
	krprWLolTqXstFetnfVhqa3zkmrijcdLltoCFxSlmjdD/4v0r+ZreG/9dwHOBSac2zVb6s
	s2XRyliKOo8tjbA3YI3DzXmUMqu7eAg=
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com
 [209.85.217.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-137-OQi-SrJoMROZy3PCveXbPA-1; Mon, 16 Nov 2026 10:07:53 -0500
X-MC-Unique: OQi-SrJoMROZy3PCveXbPA-1
X-Mimecast-MFC-AGG-ID: OQi-SrJoMROZy3PCveXbPA_1794841673
Received: by mail-vs1-f69.google.com with SMTP id ada2fe7eead31-7cc36b97a77so567143137.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 07:07:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794841673; x=1795446473; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cM3QLUhGrpStinpnv+wMKIwxc19R2VnYQvR9Rwtt3PE=;
        b=BJFeHx0mE32qmkRm2mc748EzLyeMD+BJrqkPoYMleXjkMV3uwcd6iNiMextnGynfQn
         CF9EXnOiu4YyGaGSYLD58nRejrjOoGbzeTXwuN8QfB42vUOsuGaxIIF3NnEkjofzSwIv
         rzYBacnh2ayd0aCGYbXnuCDzjk0ugcuZ8KNfIWu39vSVtEPsk8kHEzJzJwK6pH5j/NGw
         pFYAuZQW6GNO8OjK8C2CQxuZvt46wKzkCki2ikNsZ7uvzVsPOVyR3oOkkUG9DAwlAYWO
         q4pj/taFPqLxCnh8JYTOjKHzqIexZcTjpKvPWOb5yP5Y+9wHdECLb0C8Nalg/iKTZfuR
         RV/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794841673; x=1795446473;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=cM3QLUhGrpStinpnv+wMKIwxc19R2VnYQvR9Rwtt3PE=;
        b=eG1teXR9kNSOtJmNbP63qBTMAuX2CpbsaeZC69ythb1G3mVrWkLk2e/TWPBlbm1Qsn
         gmAlg46jo1JbyjkSPtf+m90Csz4GXgF9oa7SXXUJXjUl9UZEBAUMB9Vvzyzf2v9wl53T
         iM9SWf3AeyWyI5xVBfkXKLkgiysXV3vf+dpKC8ypGdta8y3UpZxHkwhXGt/aC6bLe81h
         /5W6M+VeqQaxaCcN6XQtN3qmjBS0SBX/+8Wcdrra45SmqByms8h7bJhfBlrLCTomySjX
         lG7O85gLdG/dcv4iyk/0BTG5IMSwfxyOdo8dasBVpBUDozodrsmEnXWv2QcbYLJV6ivy
         4N4Q==
X-Gm-Message-State: APuU4Z+e56h0jx9tC91bS+vmNQy9+cYETKPPvFBdr2LZct6Idi5lkGkp
	X+fzTRh2pLliG0oklsFZemB4VwTEFY6jOOgv2KEnWD19UkZvy0dBS5wq2Q5KfW415IF3YXBX72D
	jhKH8bUBj+7vJ8kpbJpPDjWsraF/314vnXSj02rG8HkQ7PDIAU8Sh7rA+0KcKzA==
X-Gm-Gg: AYBFou3NPXxJs/jYkKGnp2Qeh6VDwCZJP9bq+8kyI7BOI+dkWlBhM2izkBa5Vbi/4At
	PPYpdCU9RzJCRROL82vMBK3kwMPS0cEzsBiDRe0XPOChimdclx7SLbs0YoGKSAd/UUAW1+42ODK
	Rwp30eH1vtQ3+Coi33W4Q3G+JlMYDuRpQEv7YF2+ZB4Bo/ybYpQjN+nrmY7xsohUN61CeQ8laCZ
	THrvxSDoSQFg6/sPgqU5NR5cYoIrAjjuJzV7/gp35ptNMPNbL2zhJQrMz65fvaDsdu+LvyWHUxb
	0M12fpzA/1GAUJMnVVAT2Z6Tad6X5zfeuPvVjlZ/8AQP16xuseu/72wQ4v+NPJfP5I3FjZgDvWE
	p4cBG7+tUvI3eqOc4UUQeKKimg0eDYEEHSQ9w2kTAmVQUbTu8
X-Received: by 2002:a05:6102:94f:b0:7d2:7f93:7708 with SMTP id ada2fe7eead31-7d64d6d5a23mr3100509137.8.1794841672810;
        Mon, 16 Nov 2026 07:07:52 -0800 (PST)
X-Received: by 2002:a05:6102:94f:b0:7d2:7f93:7708 with SMTP id ada2fe7eead31-7d64d6d5a23mr3100426137.8.1794841672189;
        Mon, 16 Nov 2026 07:07:52 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91f23d7b607sm88675606d6.26.2026.11.16.07.07.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 16 Nov 2026 07:07:51 -0800 (PST)
Message-ID: <8bbef8bd-396f-4f50-8d65-a23641f84be7@redhat.com>
Date: Mon, 16 Nov 2026 10:07:50 -0500
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
Subject: Re: [PATCH nfs-utils] nfsdcld: signal readiness only after the pipefs
 watch is installed
To: =?UTF-8?B?7YyM656R7IOI?= <lhjnano@gmail.com>
Cc: linux-nfs@vger.kernel.org, cel@kernel.org
References: <CAN+dWLYt7=WDO-wGHt5_1K2JcqDgrHs1bX2WBOvaTt-PFi1meg@mail.gmail.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <CAN+dWLYt7=WDO-wGHt5_1K2JcqDgrHs1bX2WBOvaTt-PFi1meg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 11/7/26 1:06 AM, 파랑새 wrote:
> nfsdcld daemonizes with daemon(0, 0) and nfsdcld.service is Type=forking,
> so systemd considers the service started when the daemonizing parent exits.
> The child, however, only installs its inotify watch on the rpc_pipefs
> directory much later, after the sqlite database is prepared and
> cld_pipe_init() runs. Until the watch is installed, nfsdcld cannot notice
> that the kernel has (re)created the cld pipe.
> 
> nfs-server.service orders itself After=nfsdcld.service, but that ordering
> is meaningless with Type=forking: on a busy boot or a restart storm,
> systemd starts nfsd while nfsdcld is still doing schema migration or legacy
> record import, and the kernel's one second wait for nfsdcld to open the pipe
> (see nfs4recover.c:nfsd4_cld_tracking_init()) can expire unused. An observed
> instance of this race took an NFS server down for 44 minutes when nothing
> restarted the failed nfsd.
> 
> Fix by converting nfsdcld to the daemon_init()/daemon_ready() helpers used
> by the other nfs-utils daemons: the parent no longer exits until the child
> signals, and the child signals right after cld_pipe_init() has installed
> the inotify watch. With that, the existing After=nfsdcld.service ordering
> means what it claims, and the kernel's one second window is sufficient.
> 
> The event base is now created after daemonizing: daemon_init() renumbers fds
> (its status pipe takes fd 3) and would otherwise clobber the epoll descriptor
> created before daemonizing. The event base allocation failure is now reported
> through xlog() instead of fprintf(stderr): stderr is /dev/null after
> daemonizing, so an fprintf() message would be lost, while xlog() routes it to
> the syslog.
> 
> Suggested-by: Chuck Lever <cel@kernel.org>
> Link: https://lore.kernel.org/linux-nfs/20261015114755.33331-1-lhjnano@gmail.com/
> Signed-off-by: HeonJe Lee <lhjnano@gmail.com>
Committed... (tag: nfs-utils-2-1-2.rc4)

steved.
> ---
> Hi Steve,
> 
> Chuck Lever suggested on linux-nfs that I direct this patch to you as
> the maintainer of nfs-utils. The thread originated from an NFSD startup
> race investigation.
> 
>   utils/nfsdcld/nfsdcld.c | 22 +++++++++++-----------
>   1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> index 8551dc9..772cf31 100644
> --- a/utils/nfsdcld/nfsdcld.c
> +++ b/utils/nfsdcld/nfsdcld.c
> @@ -819,12 +819,6 @@ main(int argc, char **argv)
>   		return 1;
>   	}
> 
> -	evbase = event_base_new();
> -	if (evbase == NULL) {
> -		fprintf(stderr, "%s: unable to allocate event base.\n", argv[0]);
> -		free(progname);
> -		return 1;
> -	}
>   	xlog_syslog(0);
>   	xlog_stderr(1);
> 
> @@ -866,14 +860,18 @@ main(int argc, char **argv)
> 
>   	strlcat(pipepath, DEFAULT_CLD_PATH, sizeof(pipepath));
>   	xlog_open(progname);
> +	daemon_init(foreground);
>   	if (!foreground) {
>   		xlog_syslog(1);
>   		xlog_stderr(0);
> -		rc = daemon(0, 0);
> -		if (rc) {
> -			xlog(L_ERROR, "Unable to daemonize: %m");
> -			goto out;
> -		}
> +	}
> +
> +	/* daemon_init() renumbers fds and would clobber the epoll fd. */
> +	evbase = event_base_new();
> +	if (evbase == NULL) {
> +		xlog(L_ERROR, "unable to allocate event base.");
> +		free(progname);
> +		return 1;
>   	}
> 
>   	/* drop all capabilities */
> @@ -925,6 +923,8 @@ main(int argc, char **argv)
>   	signal(SIGINT, sig_die);
>   	signal(SIGTERM, sig_die);
> 
> +	daemon_ready();
> +
>   	xlog(D_GENERAL, "%s: Starting event dispatch handler.", __func__);
>   	rc = event_base_dispatch(evbase);
>   	if (rc < 0)

