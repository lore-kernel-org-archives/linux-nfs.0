Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52793 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab3AWGLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 01:11:36 -0500
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <50FF4BC9.1060206@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com>  <50FF4BC9.1060206@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Jan 2013 22:11:33 -0800
Message-ID: <1358921493.12374.737.camel@edumazet-glaptop>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 18:32 -0800, Ben Greear wrote:

> diff --git a/net/core/dst.c b/net/core/dst.c
> index ee6153e..234b168 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -245,6 +245,7 @@ again:
>                  dst->ops->destroy(dst);
>          if (dst->dev)
>                  dev_put(dst->dev);
> +       dst->input = dst->output = 0xdeadbeef;
>          kmem_cache_free(dst->ops->kmem_cachep, dst);

Great !

You could comment the kmem_cache_free() as well to get better chances to
hit the bug, and maybe start a bisection to find the faulty commit ?



