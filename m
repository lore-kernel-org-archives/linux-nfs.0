Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7E20C433EF
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Apr 2022 09:33:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235801AbiDEJes (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Apr 2022 05:34:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58064 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1343845AbiDEJOl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2022 05:14:41 -0400
Received: from andre.telenet-ops.be (andre.telenet-ops.be [IPv6:2a02:1800:120:4::f00:15])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4558A433AC
        for <linux-nfs@vger.kernel.org>; Tue,  5 Apr 2022 02:00:46 -0700 (PDT)
Received: from ramsan.of.borg ([IPv6:2a02:1810:ac12:ed40:38ab:c2b8:b3aa:7514])
        by andre.telenet-ops.be with bizsmtp
        id Ex0j270041peDqJ01x0jAA; Tue, 05 Apr 2022 11:00:43 +0200
Received: from geert (helo=localhost)
        by ramsan.of.borg with local-esmtp (Exim 4.93)
        (envelope-from <geert@linux-m68k.org>)
        id 1nbf3K-008QxV-RE; Tue, 05 Apr 2022 11:00:42 +0200
Date:   Tue, 5 Apr 2022 11:00:42 +0200 (CEST)
From:   Geert Uytterhoeven <geert@linux-m68k.org>
X-X-Sender: geert@ramsan.of.borg
To:     trondmy@kernel.org
cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Replace readdir's use of xxhash() with hash_64()
In-Reply-To: <20220331033023.718688-1-trondmy@kernel.org>
Message-ID: <alpine.DEB.2.22.394.2204051056580.2010216@ramsan.of.borg>
References: <20220331033023.718688-1-trondmy@kernel.org>
User-Agent: Alpine 2.22 (DEB 394 2020-01-19)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

 	Hi Trond,

On Wed, 30 Mar 2022, trondmy@kernel.org wrote:
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
>
> Both xxhash() and hash_64() appear to give similarly low collision
> rates with a standard linearly increasing readdir offset. They both give
> similarly higher collision rates when applied to ext4's offsets.
>
> So switch to using the standard hash_64().
>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

Thanks for your patch!

> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -4,10 +4,6 @@ config NFS_FS
> 	depends on INET && FILE_LOCKING && MULTIUSER
> 	select LOCKD
> 	select SUNRPC
> -	select CRYPTO

I'm extremely grateful for this part! ;-)

While updating shmobile_defconfig, I was wondering why I was suddenly
asked about all those crypto drivers...

> -	select CRYPTO_HASH
> -	select XXHASH
> -	select CRYPTO_XXHASH
> 	select NFS_ACL_SUPPORT if NFS_V3_ACL
> 	help
> 	  Choose Y here if you want to access files residing on other

Gr{oetje,eeting}s,

 						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
 							    -- Linus Torvalds
