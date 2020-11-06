Return-Path: <SRS0=hdvH=EM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91513C2D0A3
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:07:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2445C2087E
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:07:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="zmTKtz6W"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728144AbgKFWHW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 17:07:22 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59680 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728131AbgKFWHW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2020 17:07:22 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 42087C0613CF;
        Fri,  6 Nov 2020 14:07:22 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 283034F3A; Fri,  6 Nov 2020 17:07:21 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 283034F3A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1604700441;
        bh=RqLyV+UCWvbwkSg7aU8JV9KDf8m/ioygVluigPiNn7g=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=zmTKtz6WpAp+LVf2AWC0gv+c8jBiDGrFhtjCQei25OwQIMEKmZSpBaLwokqu+wPhz
         +THdt+UmBaO1BJivLPyxLVVJCEb2EnQYC5QdVD6jz+xiCHtorpa6lGqsXMULsvYdhp
         u0ZqOFSEEUPYmCwaP9GwvyW4K9s3MSOcFnvdHanQ=
Date:   Fri, 6 Nov 2020 17:07:21 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Alex Dewar <alex.dewar90@gmail.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Artur Molchanov <arturmolchanov@gmail.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/sunrpc: Fix return value from proc_do_xprt()
Message-ID: <20201106220721.GE26028@fieldses.org>
References: <20201024145240.23245-1-alex.dewar90@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201024145240.23245-1-alex.dewar90@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Whoops, got 3 independent patches for this and overlooked this one.  See
https://lore.kernel.org/linux-nfs/20201106205959.GB26028@fieldses.org/T/#t

--b.

On Sat, Oct 24, 2020 at 03:52:40PM +0100, Alex Dewar wrote:
> Commit c09f56b8f68d ("net/sunrpc: Fix return value for sysctl
> sunrpc.transports") attempted to add error checking for the call to
> memory_read_from_buffer(), however its return value was assigned to a
> size_t variable, so any negative values would be lost in the cast. Fix
> this.
> 
> Addresses-Coverity-ID: 1498033: Control flow issues (NO_EFFECT)
> Fixes: c09f56b8f68d ("net/sunrpc: Fix return value for sysctl sunrpc.transports")
> Signed-off-by: Alex Dewar <alex.dewar90@gmail.com>
> ---
>  net/sunrpc/sysctl.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> index a18b36b5422d..c95a2b84dd95 100644
> --- a/net/sunrpc/sysctl.c
> +++ b/net/sunrpc/sysctl.c
> @@ -62,6 +62,7 @@ rpc_unregister_sysctl(void)
>  static int proc_do_xprt(struct ctl_table *table, int write,
>  			void *buffer, size_t *lenp, loff_t *ppos)
>  {
> +	ssize_t bytes_read;
>  	char tmpbuf[256];
>  	size_t len;
>  
> @@ -70,12 +71,14 @@ static int proc_do_xprt(struct ctl_table *table, int write,
>  		return 0;
>  	}
>  	len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
> -	*lenp = memory_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
> +	bytes_read = memory_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
>  
> -	if (*lenp < 0) {
> +	if (bytes_read < 0) {
>  		*lenp = 0;
>  		return -EINVAL;
>  	}
> +
> +	*lenp = bytes_read;
>  	return 0;
>  }
>  
> -- 
> 2.29.1
