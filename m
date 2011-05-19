Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27669 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934153Ab1EST4O convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 15:56:14 -0400
Subject: Re: [PATCH] nfs41: Correct offset for LAYOUTCOMMIT
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: Vitaliy Gusev <gusev.vitaliy@gmail.com>, andros@netapp.com,
        linux-nfs@vger.kernel.org
Date: Thu, 19 May 2011 15:56:12 -0400
In-Reply-To: <4DD57342.3060804@nexenta.com>
References: <1305832245-17318-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1305833890.5552.0.camel@lade.trondhjem.org> <4DD57342.3060804@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1305834972.5552.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-19 at 23:45 +0400, Vitaliy Gusev wrote: 
> On 05/19/2011 11:38 PM, Trond Myklebust wrote:
> > On Thu, 2011-05-19 at 23:10 +0400, Vitaliy Gusev wrote:
> >> A client sends offset to MDS as it was seen by DS. As result,
> >> file size after copy is only half of original file size in case
> >> of 2 DS.
> >>
> >> Signed-off-by: Vitaliy Gusev<gusev.vitaliy@nexenta.com>
> >> ---
> >>   fs/nfs/nfs4filelayout.c |    1 +
> >>   1 files changed, 1 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> >> index be79dc9..790eb1d 100644
> >> --- a/fs/nfs/nfs4filelayout.c
> >> +++ b/fs/nfs/nfs4filelayout.c
> >> @@ -167,6 +167,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
> >>   	    wdata->res.verf->committed == NFS_FILE_SYNC)
> >>   		return;
> >>
> >> +	wdata->args.offset = wdata->mds_offset;
> >>   	pnfs_set_layoutcommit(wdata);
> >>   	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
> >>   		(unsigned long) wdata->lseg->pls_end_pos);
> >
> > Err... Shouldn't we rather be fixing pnfs_set_layoutcommit() to use the
> > mds_offset instead of hacking args.offset?
> 
> I thought about it...  pnfs_set_layoutcommit is a generic code for all 
> type of layouts, but mds_offset is set only for file layout.

If we're going to use the struct nfs_write_data as the parameter to
pnfs_set_layoutcommit, then we can and should require that the fields be
correctly initialised. It's another matter altogether that the choice of
nfs_write_data may have been a poor one if other layouts don't use it.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

