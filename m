From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 5/5] nfsd41: replace page based DRC with buffer
 based	DRC
Date: Mon, 31 Aug 2009 02:10:55 +0300
Message-ID: <4A9B06FF.2030303@panasas.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>	<1251389264-3009-2-git-send-email-andros@netapp.com>	<1251389264-3009-3-git-send-email-andros@netapp.com>	<1251389264-3009-4-git-send-email-andros@netapp.com>	<1251389264-3009-5-git-send-email-andros@netapp.com>	<1251389264-3009-6-git-send-email-andros@netapp.com> <20090828213323.GD2462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:28144
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751008AbZH3XK4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 19:10:56 -0400
In-Reply-To: <20090828213323.GD2462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 29, 2009, 0:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> I think this is OK for now, but maybe stick something like:
> 
> 	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot)
> 			+ sizeof(struct nfsd4_session) > PAGE_SIZE);
> 
> in state.h just to warn anyone who wants to blindly bump up

I think that the BUILD_BUG_ON should be placed in a function so
it gets to compile, so it'd better be defined here and not in state.h
(where it also is in the right context)

Benny

> NFSD_MAX_SLOTS_PER_SESSION.  (It's not really forbidden to kmalloc more
> than a page, but it's also not reliable, and if it becomes necessary
> then we'd rather find some way to code around it.)
> 
> 
