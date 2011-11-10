Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:34667 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab1KJIv0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 03:51:26 -0500
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>, <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>
Date: Thu, 10 Nov 2011 03:51:04 -0500
Subject: RE: [PATCH 0/8] pnfsblock cleanup and fixes
Message-ID: <F19688880B763E40B28B2B462677FBF805DD054C31@MX09A.corp.emc.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
 <4EBB8D4E.7080300@tonian.com>
In-Reply-To: <4EBB8D4E.7080300@tonian.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of Benny Halevy
> Sent: Thursday, November 10, 2011 4:38 PM
> To: Peng Tao
> Cc: linux-nfs@vger.kernel.org; Trond.Myklebust@netapp.com
> Subject: Re: [PATCH 0/8] pnfsblock cleanup and fixes
> 
> On 2011-11-09 17:15, Peng Tao wrote:
> > Hi, Trond and Benny,
> >
> > Bellow are some pnfsblock patches that I have tested for days. Most of them
> > are cleanup and small improvements. Only
> > [PATCH 2/8] pnfsblock: acquire im_lock in _preload_range
> > needs to go into stable.
> >
> > Thanks,
> > Tao
> >
> > Peng Tao (8):
> >   pnfsblock: cleanup bl_mark_sectors_init
> >   pnfsblock: acquire im_lock in _preload_range
> 
> I can't find this patch in my mailbox.
> It looks like you did not send it...
> http://thread.gmane.org/gmane.linux.nfs/44761
I have it in both of my mailbox. Not sure why linux-nfs drops it... Anyway, I will resend it.

Thanks,
Tao
> 
> Benny
> 
> >   pnfsblock: move find lock page logic out of bl_write_pagelist
> >   pnfsblock: set read/write tk_status to pnfs_error
> >   pnfsblock: remove rpc_call_ops from struct parallel_io
> >   pnfsblock: clean up _add_entry
> >   pnfsblock: add im_extents to pnfs_inval_markings
> >   pnfsblock: alloc short extent before submit bio
> >
> >  fs/nfs/blocklayout/blocklayout.c |  176
> +++++++++++++++++++++++++-------------
> >  fs/nfs/blocklayout/blocklayout.h |   11 ++-
> >  fs/nfs/blocklayout/extents.c     |  146 ++++++++++++--------------------
> >  3 files changed, 180 insertions(+), 153 deletions(-)
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

