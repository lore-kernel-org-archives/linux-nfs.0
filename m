Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964842Ab1GKStv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2011 14:49:51 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p6BInoMQ014389
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2011 11:49:51 -0700 (PDT)
Subject: Re: [PATCH 1/1] NFSv4.1: handle decoding of three attribute bitmaps
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 11 Jul 2011 14:49:49 -0400
In-Reply-To: <C42C21AC-EABC-48F2-85DE-79EF1EEEA13B@netapp.com>
References: <1310406847-31297-1-git-send-email-andros@netapp.com>
	 <1310407708.12660.2.camel@lade.trondhjem.org>
	 <C42C21AC-EABC-48F2-85DE-79EF1EEEA13B@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310410189.12660.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-07-11 at 14:30 -0400, Andy Adamson wrote: 
> On Jul 11, 2011, at 2:08 PM, Trond Myklebust wrote:
> 
> > On Mon, 2011-07-11 at 13:54 -0400, andros@netapp.com wrote: 
> >> From: Andy Adamson <andros@netapp.com>
> >> 
> >> Attribute IDs assigned in RFC 5661 now require three bitmaps.
> >> 
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> Cc:stable@kernel.org [2.6.39]
> > 
> > Is this really so urgent?
> > 
> > [trondmy@lade linux-2.6]$ git grep FATTR4_WORD2 fs/nfs include/linux
> > include/linux/nfs4.h:#define FATTR4_WORD2_SUPPATTR_EXCLCREAT (1UL << 11)
> > include/linux/nfs4.h:#define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
> > 
> > IOW: we don't appear to be using any of those bits, and so the current
> > default behaviour of just ignoring any bitmap values that we don't
> > recognise would seem to be sufficient.
> 
> I should have given more context :)
> 
> In testing nfs4_getfacl,  OnTap returns three attribute bits which triggered a BUG_ON in xdr_shrink_bufhead
> as the third bitmap was incorrectly interpreted as the length.
> 
> Plus, RFC 5661 defines suppattr_exclcreat bit 75 as a mandatory attribute which means it can/will be returned with any supported attributes query.
> 
> So, I think this needed and is a candidate for stable.

You missed my point. The only part that should make any difference in
your patch is the bit which changes the declaration of
nfs4_fattr_bitmap_maxsz.

The rest shouldn't be needed because the bits in the WORD2 range should
all be zero: our client doesn't ever request any of those attributes.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

