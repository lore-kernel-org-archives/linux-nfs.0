Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:59909 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab1HKS2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 14:28:25 -0400
Message-ID: <4E441F17.7090504@panasas.com>
Date: Thu, 11 Aug 2011 11:27:35 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Chris Metcalf <cmetcalf@tilera.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Dean Hildebrand <dhildebz@umich.edu>
Subject: Re: [PATCH] nfs: fix a couple of minor portability issues
References: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com> <4E42FFDC.9090103@panasas.com> <4E43D88A.3060303@tilera.com>
In-Reply-To: <4E43D88A.3060303@tilera.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 06:26 AM, Chris Metcalf wrote:
> 
> You can't use a cast with do_div() or you get errors about non-lvalues.
> 
> And the context here is that we want the remainder, not the divided result,
> so we'd need a temporary variable anyway if we were going to use a routine
> from math64.h, presumably div_u64_rem().  But that's just an inline wrapper
> around do_div() anyway, so it's no more efficient, and not obviously any
> less "cluttered" in the source code here.  The original code author (who
> I'm adding belatedly to this email) may have a stronger opinion.
> 
> I'm not the author or maintainer of this code, I just want it to compile
> without warning on 32-bit architectures :-)
> 

Still, if you fix it do it properly by using, as you said, div_u64_rem().
It's what needs to be used with u64 types.

Thanks
Boaz
