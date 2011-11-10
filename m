Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:41453 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933718Ab1KJJMS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 04:12:18 -0500
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>, <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>
Date: Thu, 10 Nov 2011 04:11:19 -0500
Subject: RE: [PATCH 6/8] pnfsblock: clean up _add_entry
Message-ID: <F19688880B763E40B28B2B462677FBF805DD054C3A@MX09A.corp.emc.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
 <1320851766-1834-7-git-send-email-bergwolf@gmail.com>
 <4EBB8EDD.9090107@tonian.com>
In-Reply-To: <4EBB8EDD.9090107@tonian.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Thursday, November 10, 2011 4:44 PM
> To: Peng Tao
> Cc: linux-nfs@vger.kernel.org; Trond.Myklebust@netapp.com; Peng, Tao
> Subject: Re: [PATCH 6/8] pnfsblock: clean up _add_entry
> 
> On 2011-11-09 17:16, Peng Tao wrote:
> > It is wrong to kmalloc in _add_entry() as it is inside
> > spinlock. memory should be already allocated _add_entry() is called.
> 
> What about the call from _set_range, it is passing NULL?
> 
> > So BUG instead if we fail to find a match and no memory preallocated.
> >
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/blocklayout/extents.c |    9 ++-------
> >  1 files changed, 2 insertions(+), 7 deletions(-)
> >
> > diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> > index f383524..952ea8a 100644
> > --- a/fs/nfs/blocklayout/extents.c
> > +++ b/fs/nfs/blocklayout/extents.c
> > @@ -110,13 +110,8 @@ static int _add_entry(struct my_tree *tree, u64 s, int32_t
> tag,
> >  		return 0;
> >  	} else {
> >  		struct pnfs_inval_tracking *new;
> > -		if (storage)
> > -			new = storage;
> > -		else {
> > -			new = kmalloc(sizeof(*new), GFP_NOFS);
> > -			if (!new)
> > -				return -ENOMEM;
> > -		}
> > +		BUG_ON(!storage);
> 
> The BUG isn't needed as you dereference the pointer right away.
Yes. Will remove it.

Thanks a lot for reviewing!
Tao

> 
> Benny
> 
> > +		new = storage;
> >  		new->it_sector = s;
> >  		new->it_tags = (1 << tag);
> >  		list_add(&new->it_link, &pos->it_link);

