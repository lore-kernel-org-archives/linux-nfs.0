Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:2329 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752277Ab3ERPtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 May 2013 11:49:23 -0400
Subject: Re: [PATCH v2] nfsd: avoid undefined signed overflow
From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
To: Jim Rees <rees@umich.edu>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Sat, 18 May 2013 17:49:11 +0200
In-Reply-To: <20130518145808.GA3670@umich.edu>
References: <1368826380-9864-1-git-send-email-rees@umich.edu>
	 <1368875049.11003.31.camel@thorin> <20130518145808.GA3670@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1368892155.11003.39.camel@thorin>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sam, 2013-05-18 at 10:58 -0400, Jim Rees wrote:
> Bernd Petrovitsch wrote:
> 
>   Hmm, what is actually wrong with plain-old
>   ----  snip  ----
>   static bool stateid_generation_after(stateid_t *a, stateid_t *b)
>   {
>   	return a->si_generation > b->si_generation;
>   }
>   ----  snip  ----
>   ?
> 
> It doesn't account for wraparound. Try this:
> 
>     unsigned int a = 0xffff0000, b = 0x7fff0000;
>     printf("%d %d\n", a > b, (int)(a - b) > 0);
> 
> I just realized that I said this needed a comment, then didn't provide one.

Ooops, yes, thx.
Sry for the noise;-)

	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

