Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD7C2C07E96
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Jul 2021 00:11:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AE26061CAD
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Jul 2021 00:11:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229834AbhGGANh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Jul 2021 20:13:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48090 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229935AbhGGANh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2021 20:13:37 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E1E15C061574
        for <linux-nfs@vger.kernel.org>; Tue,  6 Jul 2021 17:10:57 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 650B350A1; Tue,  6 Jul 2021 20:10:56 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 650B350A1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1625616656;
        bh=mlw0DjucBd+mo3nhTbGmRN4m0lAM+3XXrH9VdG9lZQw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nlRmERQB3QglSU6XJikAQekD1zhLMzZA81YmSGl0UuoHut1Rb6ZxdE9Ak+0HR41MQ
         wRIcHz2vuLMFRaFilrfYHQrI7Q9rzBpevyHOoxRtIMH9LObhWJ+g15/h4Q+kPUQ66W
         2yV+v/bsB7caGInb99zYeg933O0FqTQ8BhWkRyS0=
Date:   Tue, 6 Jul 2021 20:10:56 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Dai Ngo <dai.ngo@oracle.com>
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        trondmy@hammerspace.com, chuck.lever@oracle.com
Subject: Re: [PATCH v7 2/2] NFSv4.2: remove restriction of copy size for
 inter-server copy.
Message-ID: <20210707001056.GA26847@fieldses.org>
References: <20210521190938.24820-1-dai.ngo@oracle.com>
 <20210521190938.24820-3-dai.ngo@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210521190938.24820-3-dai.ngo@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Whoops, I overlooked that this is client side, so it needs to go through
Trond or Anna, not me.

Also note:

On Fri, May 21, 2021 at 03:09:38PM -0400, Dai Ngo wrote:
> This patch, relying on the delayed unmount feature, removes this
> restriction since the mount and unmount overhead is now not applicable
> for every inter-server copy.

There's no guarantee that the same kernel version is running on client
and server, or even that the server is a Linux server.

If there's reason to expect that the lower overhead should be more
typical of servers in general, then say that....

--b.

> 
> Signed-off-by: Dai Ngo <dai.ngo@oracle.com>
> ---
>  fs/nfs/nfs4file.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 441a2fa073c8..b5821ed46994 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -158,13 +158,11 @@ static ssize_t __nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  		sync = true;
>  retry:
>  	if (!nfs42_files_from_same_server(file_in, file_out)) {
> -		/* for inter copy, if copy size if smaller than 12 RPC
> -		 * payloads, fallback to traditional copy. There are
> -		 * 14 RPCs during an NFSv4.x mount between source/dest
> -		 * servers.
> +		/*
> +		 * for inter copy, if copy size is too small
> +		 * then fallback to generic copy.
>  		 */
> -		if (sync ||
> -			count <= 14 * NFS_SERVER(file_inode(file_in))->rsize)
> +		if (sync)
>  			return -EOPNOTSUPP;
>  		cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
>  				GFP_NOFS);
> -- 
> 2.9.5
