Return-Path: <SRS0=NrPx=75=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F051EC433E1
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Jun 2020 06:42:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CE8BD2082F
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Jun 2020 06:42:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1592289747;
	bh=zT5NX8Dk5gX1bFBzTUf2najOzbbws8RfjHMggGGsEaE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=xJt1lij7eZRynvl90S5UtPbgYhPpNHV826j9JW7xXRVbGDlMmY/n1EIn2HVzGHGDV
	 ZhIMthPEL4ymf7eUUv/BrvQCrdcPcvWI2u9h3SrWtAVUMuI9t8Xg0wOcVC5MHmHpm/
	 uD4wv3XDQ0hC7asS+ICAG9WRJaKtP00vwdVw1h28=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726665AbgFPGmR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Jun 2020 02:42:17 -0400
Received: from mail-ej1-f66.google.com ([209.85.218.66]:34150 "EHLO
        mail-ej1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725775AbgFPGmQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2020 02:42:16 -0400
Received: by mail-ej1-f66.google.com with SMTP id l27so20291324ejc.1;
        Mon, 15 Jun 2020 23:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=8yT+7Ta/B3BUGUR35Fz/0p22bghMwTUAxgTnwepounI=;
        b=CrqjoVKTD3f3KdvDGIeuUsz+tApuK+psSd/zZznBL+PvDQ9kr/y3NysJrLCUvijZ0W
         D1lMJFJjDjxCjK+3vtuSUx88E4FI/icqqmCPzoYqFy6r+CX7+frVJXkQBTdJvOi0k2H8
         BQWo08oG78S63Nmuvi83IANQL4LNBYWwNm3J2aXU7+GGmL071iftqMsCEIxqPKRgxnoO
         l2aRKff/cldTmTKB1sX4cPbWqW005Wxuza/3URs7J0zQObIlg8c0OKxW9NsQzskaJNhs
         WYN8j8RMnmY+IrXoBKVYXvhwDHpIj4QOYGkzsnxSvMv3OoF06DPJymcAuYl6IFpm70uf
         LBaQ==
X-Gm-Message-State: AOAM531HP4eO0zbWwLMfP5GDnN825+ONW2qq1LmJWzlrQRrQ9tLmHjV1
        pUaK0iSgeht2xDq1+zJMRIs=
X-Google-Smtp-Source: ABdhPJwG7kr4DUIGgc4iCDEeodlEq5kx0AY8+Z/EURP92P+0Zf4E0UWpXqDGfffbUz9uBG+pBru51g==
X-Received: by 2002:a17:906:ce2f:: with SMTP id sd15mr1306745ejb.445.1592289731375;
        Mon, 15 Jun 2020 23:42:11 -0700 (PDT)
Received: from localhost (ip-37-188-174-201.eurotel.cz. [37.188.174.201])
        by smtp.gmail.com with ESMTPSA id j10sm9734428edf.97.2020.06.15.23.42.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Jun 2020 23:42:10 -0700 (PDT)
Date:   Tue, 16 Jun 2020 08:42:08 +0200
From:   Michal Hocko <mhocko@kernel.org>
To:     Waiman Long <longman@redhat.com>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        James Morris <jmorris@namei.org>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Joe Perches <joe@perches.com>,
        Matthew Wilcox <willy@infradead.org>,
        David Rientjes <rientjes@google.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        David Sterba <dsterba@suse.cz>,
        "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-mm@kvack.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-crypto@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-stm32@st-md-mailman.stormreply.com,
        linux-amlogic@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-ppp@vger.kernel.org, wireguard@lists.zx2c4.com,
        linux-wireless@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, ecryptfs@vger.kernel.org,
        kasan-dev@googlegroups.com, linux-bluetooth@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-security-module@vger.kernel.org,
        linux-integrity@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v4 1/3] mm/slab: Use memzero_explicit() in kzfree()
Message-ID: <20200616064208.GA9499@dhcp22.suse.cz>
References: <20200616015718.7812-1-longman@redhat.com>
 <20200616015718.7812-2-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200616015718.7812-2-longman@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon 15-06-20 21:57:16, Waiman Long wrote:
> The kzfree() function is normally used to clear some sensitive
> information, like encryption keys, in the buffer before freeing it back
> to the pool. Memset() is currently used for the buffer clearing. However,
> it is entirely possible that the compiler may choose to optimize away the
> memory clearing especially if LTO is being used. To make sure that this
> optimization will not happen, memzero_explicit(), which is introduced
> in v3.18, is now used in kzfree() to do the clearing.
> 
> Fixes: 3ef0e5ba4673 ("slab: introduce kzfree()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Waiman Long <longman@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Although I am not really sure this is a stable material. Is there any
known instance where the memset was optimized out from kzfree?

> ---
>  mm/slab_common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 9e72ba224175..37d48a56431d 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1726,7 +1726,7 @@ void kzfree(const void *p)
>  	if (unlikely(ZERO_OR_NULL_PTR(mem)))
>  		return;
>  	ks = ksize(mem);
> -	memset(mem, 0, ks);
> +	memzero_explicit(mem, ks);
>  	kfree(mem);
>  }
>  EXPORT_SYMBOL(kzfree);
> -- 
> 2.18.1
> 

-- 
Michal Hocko
SUSE Labs
