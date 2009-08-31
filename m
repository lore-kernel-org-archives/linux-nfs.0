From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 5/5] nfsd41: replace page based DRC with buffer
	based DRC
Date: Mon, 31 Aug 2009 09:08:22 -0400
Message-ID: <20090831130822.GB27432@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com> <1251389264-3009-2-git-send-email-andros@netapp.com> <1251389264-3009-3-git-send-email-andros@netapp.com> <1251389264-3009-4-git-send-email-andros@netapp.com> <1251389264-3009-5-git-send-email-andros@netapp.com> <1251389264-3009-6-git-send-email-andros@netapp.com> <20090828213323.GD2462@fieldses.org> <4A9B06FF.2030303@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37722 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbZHaNIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 09:08:23 -0400
In-Reply-To: <4A9B06FF.2030303@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 31, 2009 at 02:10:55AM +0300, Benny Halevy wrote:
> On Aug. 29, 2009, 0:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > I think this is OK for now, but maybe stick something like:
> > 
> > 	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot)
> > 			+ sizeof(struct nfsd4_session) > PAGE_SIZE);
> > 
> > in state.h just to warn anyone who wants to blindly bump up
> 
> I think that the BUILD_BUG_ON should be placed in a function so
> it gets to compile,

Whoops, thanks--I hadn't noticed that.

> so it'd better be defined here and not in state.h
> (where it also is in the right context)

Sounds fine.--b.
