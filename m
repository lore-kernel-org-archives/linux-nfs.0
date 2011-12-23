Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:59882 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab1LWGkT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 01:40:19 -0500
Message-ID: <4EF422A8.5070907@cn.fujitsu.com>
Date: Fri, 23 Dec 2011 14:41:44 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy 写道:
> I am trying to build a pnfs client on a 32 bit system  and the
> pnfs-latest  kernel fails to compile. I get the following error
> 
>  >  Building modules, stage 2.
>  >  TEST    posttest
>  > MODPOST 2046 modules
>  >ERROR: "__udivdi3" [crypto/xor.ko] undefined!
>  >make[1]: *** [__modpost] Error 1
>  >make: *** [modules] Error 2
>  >make: *** Waiting for unfinished jobs....
>  >Succeed: decoded and checked 1244492 instructions
> 
> Reported-by: Rita Sequeira <rita.prajval@gmail.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
> 
> untested patch yet...
> 
>  crypto/xor.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/crypto/xor.c b/crypto/xor.c
> index 65433f5..2151ded 100644
> --- a/crypto/xor.c
> +++ b/crypto/xor.c
> @@ -95,7 +95,8 @@
>  
>  	ns_end -= ns_begin;
>  	if (ns_end > 0)
> -		speed = BENCH_SIZE / 1024 * count * NSEC_PER_SEC / ns_end;
> +		speed = BENCH_SIZE / 1024 * count *
> +				(unsigned)(NSEC_PER_SEC / ns_end);
>  	else
>  		speed = 17;
>  	tmpl->speed = speed;

Hi,I also meet this problem ,but when  i use you patch ,i can't solve this problem.

