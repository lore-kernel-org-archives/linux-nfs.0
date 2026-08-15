Received: from mail-yx1-f47.google.com (mail-yx1-f47.google.com [74.125.224.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 565DA3EF0D3
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 12:31:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786797119; cv=none; b=Z84kK4gC9jP8R2zGIrcPfo7c/a8NCiwNw0+BV6JA2MBkDCw1+u+jqEVOOGpKozhRO64M7E/ho1HXdu9iDoRa5/EfCrunLrYPoA88CmO0k5sQsqKsCcAJRCGkYyV3o7lek8T16C+wA3bR2xWSfFo+BZhtiiSKEe0AbSb3oOCBqpA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786797119; c=relaxed/simple;
	bh=7GIrgPS7aYiKXEUEqxC6DO/Ruf9bX1cZeQvHmWqu+5o=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=QNagMIbwDs6XOj4Iouu2NDb9f8XvaoM218TmuaWFIci2maqWEBdGojTr2EubEp+TQuy8TlzG5x1tkkjZafQHjlbwgAX6+U9cLfDetnit9XGXCym9I/tSUZuaZzzE2CqWRAGY56j9uBhc0jolkrMbYnOC9PMLapQtGA8KDzo9GI8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=bzwHxVyw; arc=none smtp.client-ip=74.125.224.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="bzwHxVyw"
Received: by mail-yx1-f47.google.com with SMTP id 956f58d0204a3-6679d88abdcso2529567d50.2
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 05:31:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786797116; x=1787401916; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zRFDbDEdq+en0/C2kkY5O+q8oWHYZfSakLCBIc20fp4=;
        b=bzwHxVywInlxDDOH0O+A0HeEetlRqBk4atfAydNYWT/pZm3+BWGmkd1GvSt83BNWrp
         jfRy4f0CtGgl55eiH1x7zzykH3EAG6/SzLERjU7ICUyPiFryYqoLS1ZJb1jtNLLlyxXz
         COoDhyU/liKoYzkl/llWzKJIuer5feIt590Y7jyAZqOkzBFA/qknLX2WMABVchHrWrKR
         t1Ze9wouxr82/sLlsPnZxbg0GBUtnq0i2eLzCIlsRC86lWMc+6Z1prM6PHgn8R/toifx
         EkRD7IVBvkU3mycO1CgiwD3lfjgp6qzv8m6P7Xep2H0bsbnmHGIacYCskJCPtRLny6uM
         vrOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786797116; x=1787401916;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zRFDbDEdq+en0/C2kkY5O+q8oWHYZfSakLCBIc20fp4=;
        b=Acod/io6SzqL6pb/bU9uEzMEw52+scv+LgeEX8pmsL81vO/t3uV18yVJXHJnuXTzr2
         l0ctOzlTpBP9GoFrjR9BrCiUX+YNJ/a6v/zxhVS+0XdLzwoVWyFmZy6g4V+y6cdFy7we
         INDJ9qoUxCQfVtIzCdFv0ZuemhteoEO//ku7n51eKhYTotBEJZLXenXWg9FUFmfSWgnz
         kIrSy5tvQitDemt3sNofccraSLGr74eDg3V+dKRmGD/5qQdOnRmCJuUV3nRthJhhmP4X
         y+irE+LziHKcjSZVXy4d7p3X+NvBhHFhe7XJl8E+EhQqlvwPMjcPBApz6O3i6tosdnOW
         gD+Q==
X-Forwarded-Encrypted: i=1; AHgh+Rru5q+/2k++GOfr8wK33o04l4gON1Zm4BX8mbsZqOKPr6HFAsRizxrj9+BLJ5rbKf4tg+MMcNJy52c=@vger.kernel.org
X-Gm-Message-State: AOJu0YzXRYJ+lo92lVLGNWYg16zKfi9a9kGlheuXnmlKiDmHNJEDsGMh
	u8e0VZ4B1w0vGh5ehiGx18BWbABtUC2fmDMqh2osZw+VmGKXtQVVImD55/oTnMgHxQ==
X-Gm-Gg: AR+sD10ODlYxNB2Lsrf2zBMsWA2xUsbM6KbrSxjmQvbN0Xa92fnoUMmwrrvrptN+SDN
	5M733lbJ+lPHF8PO9wuMYBOBvc6cwAx5cmKKsbeUjsxZsUkZWdyJwbZIkf+MhQsDtdKbqeSzsyi
	wBT+Z6xMkctqUvEsXUHE/jB5B9Njp3ndHr1RuUBGjf/y3QmCw3/OgasiITAJN1H5lYcOzFT00w0
	e3WRf7401Bd7/L6iTaW+qzf8apyaWQCgQxo75JdbHuZyFDsADhQYzXMRz1t86ACyFzejJmgkX8N
	Zwn2u3Jh/pYq7oFEPuHElSdKHY/I4EbIeOqneTge+V8Zi2tY+mAwT7EcMRvxLeQiaV/M70RBEeE
	X3yYJj+K1W3U8mTj1gcP72HhFdU+TUzjZPao/uRZP297rw4zv82RA3+wv417eaGPvAUn+7tmBOi
	/LHRqyG22CLwM2eu4yAvnjEPPeL/zL4+Toxq2Ad3nJStVzdR7jjTUo21m4k5fr
X-Received: by 2002:a05:690e:250:b0:668:2e0a:ba97 with SMTP id 956f58d0204a3-66c72b66e72mr3487267d50.13.1786797116135;
        Sat, 15 Aug 2026 05:31:56 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 956f58d0204a3-66c7934f51esm2132182d50.17.2026.08.15.05.31.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 15 Aug 2026 05:31:55 -0700 (PDT)
Date: Sat, 15 Aug 2026 17:31:47 +0500
From: Ameer Hamza <ameer.hamza@truenas.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: cel@kernel.org, neil@brown.name, okorniev@redhat.com, 
	Dai.Ngo@oracle.com, tom@talpey.com, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, alexander.motin@truenas.com, caleb.stjohn@truenas.com
Subject: Re: [PATCH v2 0/2] sunrpc: don't strip a uid's groups when the
 mountd group lookup fails
Message-ID: <aoBb18TpdIe77NOI@hamza-PC>
References: <20260814221953.108837-1-ameer.hamza@truenas.com>
 <3b34e782725fed9a661a4c77ab875f1bd755fcd8.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b34e782725fed9a661a4c77ab875f1bd755fcd8.camel@kernel.org>

On Sat, Aug 15, 2026 at 06:50:48AM -0400, Jeff Layton wrote:
> On Sat, 2026-08-15 at 03:19 +0500, Ameer Hamza wrote:
> > On a server running rpc.mountd with --manage-gids, a transient
> > name-service failure makes mountd answer the auth.unix.gid upcall
> > with a zero-group reply, which the kernel installs as a valid
> > positive entry.  Patch 1 records such replies as negative entries
> > on the classic /proc channel, so the credential keeps the groups
> > it already carries.  Patch 2 does the same for the netlink upcall,
> > which has an explicit NEGATIVE flag the parser does not propagate.
> > 
> > One observation from reviewing the netlink path: in steady-state
> > netlink-only operation, mountd currently receives no unix_gid
> > upcalls, because unix_gid_upcall() still gates request generation
> > on cache_listeners_exist(), which counts only classic-channel
> > writers, and netlink-mode mountd opens no /proc channels.  A
> > flagged reply reaches the parser today only via the 30-second
> > post-close grace window, a concurrent classic-channel writer, or
> > a direct SUNRPC_CMD_UNIX_GID_SET_REQS.  Patch 2 fixes the parser
> > semantics ahead of that; making upcall generation netlink-aware
> > needs a per-cache listener signal (mountd subscribes to the
> > notification group even without --manage-gids) and is left for a
> > separate, runtime-tested series.
> > 
> 
> Do you intend to send the separate series for this?

Not at the moment. I may take a look later if it is still open.

Thanks for the review.

> 
> > Patch 1 was tested on a live 6.12 server over NFSv3 and v4.0-v4.2
> > with sec=sys and sec=krb5, and applies unmodified to every
> > maintained stable tree, 5.10.y through 7.1.y.  Patch 2 is build-
> > and static-checked (sparse, W=1) but not runtime-tested.
> > 
> > Changes since v1:
> > - split the netlink fix into its own patch with its own Fixes:
> >   tag, as requested by Chuck
> > - patch 1 is unchanged
> > 
> > v1: https://lore.kernel.org/linux-nfs/20260814172507.1474519-1-ameer.hamza@truenas.com/
> > 
> > Ameer Hamza (2):
> >   sunrpc: treat empty auth.unix.gid replies as negative entries
> >   sunrpc: honor the netlink unix_gid NEGATIVE flag
> > 
> >  net/sunrpc/svcauth_unix.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > 
> > base-commit: 46db3c8a1be96a354758b44b1d4fbb4b70d09a20
> 
> Good catch. Both of these look good to me.
> -- 
> Jeff Layton <jlayton@kernel.org>
