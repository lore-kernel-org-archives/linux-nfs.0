Return-Path: <SRS0=IBnY=DT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77AA5C433E7
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Oct 2020 14:19:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E355A20838
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Oct 2020 14:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="Ij9k9wxB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389085AbgJLOTj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Oct 2020 10:19:39 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37184 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389027AbgJLOTi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2020 10:19:38 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9F5C9C0613D0;
        Mon, 12 Oct 2020 07:19:38 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 1380F69C3; Mon, 12 Oct 2020 10:19:38 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 1380F69C3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1602512378;
        bh=z+6PoTtT6EmkTBGOpwIlpua2wjrUzVQInPgbVjGszZ8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Ij9k9wxB4V8z/k8XID+Tkzy8dUa1Rh6VW5lcwoBLnhMvgfLB/eg15m+UH6CxTMVw4
         D1J43vmOBD09Xh1by75sY9OecXn3DiXuRj5e9cjyEKu5nBBPCNWeIjgjNsnd9Zfllx
         32EchIWzozQbyltP9TIW+AthWbMWH+Ng05vbLyVQ=
Date:   Mon, 12 Oct 2020 10:19:38 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     trix@redhat.com
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: remove unneeded break
Message-ID: <20201012141938.GC26571@fieldses.org>
References: <20201011155155.15538-1-trix@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201011155155.15538-1-trix@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Oct 11, 2020 at 08:51:55AM -0700, trix@redhat.com wrote:
> From: Tom Rix <trix@redhat.com>
> 
> Because every path through nfs4_find_file()'s
> switch does an explicit return, the break is not needed.

OK, applying.--b.

> 
> Signed-off-by: Tom Rix <trix@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c09a2a4281ec..741f64672d96 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5722,7 +5722,6 @@ nfs4_find_file(struct nfs4_stid *s, int flags)
>  			return find_readable_file(s->sc_file);
>  		else
>  			return find_writeable_file(s->sc_file);
> -		break;
>  	}
>  
>  	return NULL;
> -- 
> 2.18.1
