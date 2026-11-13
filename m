Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.181
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794611195;
	b=CyaqfMaW7I3KM3s9m8pSolddWMuukSJm+2RyXIFBKaFbP0XHqRDItyJ08Y43XTDSpSjK
	 fasOtSEhRe55n09AzpwdYok4DGRzjNFf4/4jt4TvPv1igqKg85eDi+JZkjOsWSobjdzxq
	 zPNXnVaVGcvAm1apIE+ayDeC4zmyhQ0OwwPVj/EuAS6ais5GKLvHEu4zqMw0hL5IWydaL
	 xcci3awPucgg2JuKTEsYnk+uMm4amLDDv7r4qE05ukne9K19KXtZ0moQ/K8icxLrYw27P
	 JuelVGtxe5Uusyr3ItnXwQqnzt5MKKJvP0J9i4KORS4v9z00Yl0hHO7dF0tb1FCZSTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794611195;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To;
	bh=+yZBUb0y0aJXtsvRM5IV1QM8j0O/2H7zq2msJp4QzHk=;
	b=2b8Upe1RDuFrnE2rauLE2jDV/+TI4U6IU1m+CTb0ntP/1oWxMfJikzTHER3yZeksQPdf
	 i+Qw5249eacWhuGdwYEIbENTnFPAtJ8LG1Bf6D1SJGt+j2ugxJTEnQJHFPUj5ywlev3yN
	 BQQGqcr4ugUbOEYl7cY+HEBAKvs0NjveQBIfAusMzlsovW7+7fTkcQDlk1jqh6QsB4Cnj
	 goeodYb5QbMK3XDpXalnvD5kxWY25sT/vEISw0V7T8hf1r2manfgqlf8xSxbReX3UUzy4
	 rOdApd/C5XTVdS9XwrBpG1QBluoLGfa6IIud9D5RdLeD8hWnmo+aitDIz9Rc0hA8vWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VrOkhrXC;
	arc=none smtp.remote-ip=209.85.215.181
Received: from mail-pg1-f181.google.com (mail-pg1-f181.google.com [209.85.215.181])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50506606A330
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 23:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 50506606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VrOkhrXC
Received: by mail-pg1-f181.google.com with SMTP id 41be03b00d2f7-cdb628232d2so1687921a12.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 15:06:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794611195; x=1795215995; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=+yZBUb0y0aJXtsvRM5IV1QM8j0O/2H7zq2msJp4QzHk=;
        b=VrOkhrXC77H0umI4DTwF7JUWQ/krcKt5S0DY6D2pGu6jLl8pQR/+4smtqwe0pYpFwW
         TYLcVkvfkepUs0APzVMHRp0N5kQkKLKrDY18wqAoH33av/qyUBcYkGzFzSFla1XFZY41
         6A4+Teedu7g+cB9Ywm+XF3l72fC9KkOSBDFiDLLUGfQ/2tN84v9byqMCUgOYpqJ/FT/P
         t2mLjm4LeYBkd9fGQCm3i60wf5KOMq9/QN/eTstINGbRAqvGqFVhQphok9WgxOeIYX0x
         0AcfXhuES82VESKnvZa4iWEdL5uTGkZPA9NA9FHbgem+z+RInBo/b1pWo8hI0PtkhwIC
         2F9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794611195; x=1795215995;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=+yZBUb0y0aJXtsvRM5IV1QM8j0O/2H7zq2msJp4QzHk=;
        b=zhBI+fRmv5/J9TPuAoaqW5wGG8zoUvXs84+vbl/WX+1ygc2GOgL9Tp+GPLEjBOKLPq
         xYrXJY/Uok9QDyVv9yV0kRusCig7uhZ9FiqlIl/rhgpaA8qO1TnFwZ7AEg9cTLk/y+OC
         4CjaP0oW1fHwbXrPWtyJ+BS6sLoi6PhG9OuRYzE/jw7XACYzqN/ymqaSPykr/nKMtLpL
         Iv3svr+dMzvjjVYO3jJfEImBb5H0JrJiJxOYMJmQCo+U4oNAKhZzQahDNudCBWyk3IVv
         xmj14sWEtZzzbOgszMCcNEOG46eKJvb/1E5qLKl5hkUwdwXgHVZNBFYZVDn7JqpI0m9t
         Rj7g==
X-Forwarded-Encrypted: i=1; AL+hErHYxsTTJMO4zK3uwHsbJEQCNx58Vtqu5ZKfTEmeE9xrUhD0z+xH262g2OWOorHvlhl1slRHv7suegI=@vger.kernel.org
X-Gm-Message-State: APuU4Z+CtKY8LnMQ7RpAWfvb6NPyhDpEmG2va4mr1CD1QHLJsdAU85Q5
	RUTRbtA/D494uH/qQmKcejrN/ctkduU1bjqpDA2rVnDI2Xc5hm8FiSoU
X-Gm-Gg: AYBFou1cYmabHe3+9jHRINfQKL7xDQMYI3NjZOFJdjbKlq3h3Hd/m2yQ3Ua2BLf9hbe
	w4Aps7+UF9P87Z2sFcaSdOkwqdqN0HLPwGnsqQ1z5mSPVXDWIYKXWx+3U0Zpr7jqm2AJ884go9Q
	RqE+pvcFvLCPPrXOtH0ViKDi6o5KHXblo9hBoVSDmmL2RPS7tBRf5hBiNF6gtr1E8uC1IzF/Iep
	hsV4VBhdcxfMQNuEMCvD3KtnW6Pa6iHgKg+J2L3QIKOASjcL8620KKaJiYspTeerKvI3dKPOrU0
	vz9/ZIjLoCWM/zSt5U3Olz8kwUjxa9TplUa84Y+Ssjgf5lWS8TCXATUKsdq6v3RR6zZA59eVo1g
	xIa18jh63XU5oCNGldSBrJnDVVe3X+qPCFkhEwEFIB2PbQfR15Qvg9EwvnSApOJD2Vp9BFQO1kG
	IY404BkDTo/L9hM1KBUyiYWUgyvMYpfIvLNXQVcXHNhejzL4k361oyicy4hhY0rjcqMDxJY935i
	CkMUx52YbDr+QE9LsbxM/uySHEWxEmAUQAR7oSGuy+AFwp194lHdESey7sCDW9Ji2+XckZpsAWl
	XlzYRNxDbgVS6xqHDRBnDuPloTEbmxr8iQ==
X-Received: by 2002:a05:6a21:a106:b0:3e2:21c0:3dff with SMTP id adf61e73a8af0-3f7a8de8800mr3452800637.65.1794611194624;
        Fri, 13 Nov 2026 15:06:34 -0800 (PST)
Received: from user ([2405:201:c052:b00b:57da:89f:77c9:e916])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8bed2053d26sm1653308b3a.36.2026.11.13.15.06.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 15:06:33 -0800 (PST)
Date: Sat, 14 Nov 2026 04:36:19 +0530
From: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
To: trondmy@kernel.org, anna@kernel.org
Cc: skinsbursky@parallels.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com
Subject: Re: [PATCH] NFS: Destroy callback transports on initialization
 failure
Message-ID: <aveX66UdPwMrs49E@user>
References: <20261108210452.84550-1-pavankumaryalagada@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261108210452.84550-1-pavankumaryalagada@gmail.com>

On Mon, Nov 09, 2026 at 02:34:52AM +0530, pavankumaryalagada@gmail.com wrote:
> From: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
> 
> During NFSv4 callback initialization, the IPv4 listener is created
> successfully, but the IPv6 listener fails to start. The error path
> returns without cleaning up the IPv4 listener. As a result, the
> transport remains attached to serv->sv_permsocks, causing svc_destroy()
> to trigger a warning.
> 
> Call svc_xprt_destroy_all() when IPv6 listener creation fails to
> close any transports that were already created. This ensures all
> transports are cleaned up before the service is destroyed.
> 
> Reported-by: syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com
> Link: https://lore.kernel.org/all/6aee17c4.8be4ead1.3b45e1.0199.GAE@google.com/T/
> Fixes: c946556b8749 ("NFS: move per-net callback thread initialization to nfs_callback_up_net()")
> Signed-off-by: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
> ---
> Note: Tested by syzbot using the reproducer. The kernel built successfully,
> and the original WARNING was no longer reproduced.
> ---
>  fs/nfs/callback.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index bc282b744f34..29134e2c56cd 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -61,9 +61,11 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
>  		dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
>  			nn->nfs_callback_tcpport6, PF_INET6, net->ns.inum);
>  	} else if (ret != -EAFNOSUPPORT)
> -		goto out_err;
> +		goto out_destroy_xprts;
>  	return 0;
>  
> +out_destroy_xprts:
> +	svc_xprt_destroy_all(serv, net, false);

Hi,

Could you please review this when you have a moment?

Thanks,
Pavan

>  out_err:
>  	return (ret) ? ret : -ENOMEM;
>  }
> -- 
> 2.43.0
> 
