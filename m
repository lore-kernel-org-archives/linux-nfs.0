Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:33333 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757086Ab1LWNZ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 08:25:58 -0500
Date: Fri, 23 Dec 2011 08:25:46 -0500
From: Jim Rees <rees@umich.edu>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
Message-ID: <20111223132546.GA10015@umich.edu>
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
 <4EF422A8.5070907@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4EF422A8.5070907@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fanchaoting wrote:

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
  
  Hi,I also meet this problem ,but when  i use you patch ,i can't solve this
  problem.

Maybe something like this?

speed = do_div(BENCH_SIZE, 1024) * count * do_div(NSEC_PER_SEC, ns_end);

This might not be exactly right because it changes the operator precedence,
but it should eliminate the calls to __udivdi3.
