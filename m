Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab1IFWdX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2011 18:33:23 -0400
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: Vitaliy Gusev <gusev.vitaliy@gmail.com>, peng_tao@emc.com,
        linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2011 18:32:53 -0400
In-Reply-To: <4E669B21.30006@nexenta.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315348373.19556.22.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-09-07 at 02:13 +0400, Vitaliy Gusev wrote: 
> >> @@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
> >>
> >>   	list_for_each_entry(lseg,&NFS_I(inode)->layout->plh_segs, pls_list) {
> >>   		if (lseg->pls_range.iomode == IOMODE_RW&&
> >> -		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags))
> >> +		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags)&&
> >> +		    list_empty(&lseg->pls_lc_list))
> >>   			list_add(&lseg->pls_lc_list, listp);
> >>   	}
> >>   }
> >
> > If the lseg is already part of one layoutcommit, but we're sending a
> > second one for the same range (presumably because we wrote more data in
> > the same region), then the above causes the lseg to be excluded.
> 
> 
> Yes, lseg is excluded, This patch does exactly only exclusion of lseg. 
> lseg is used here only to get/put reference on this lseg, so skipping is 
> correct.

Are you sure? As far as I can see, pnfs_list_write_lseg() actually
assigns the lseg to a particular layoutcommit call.

My questions are: if I write to an area described by that lseg _after_
it has been assigned to that layoutcommit RPC call (and the latter has
already been dispatched to the metadata server), then 
     A. shouldn't it be assigned to a second layoutcommit call too? 
     B. If not, what are we doing to ensure mutual exclusion between
        layoutcommit RPC calls and pNFS writes to the data server?

> However, checking on list_empty can occur (on other CPU) in the middle:
> 
> 	list_del_init(&lseg->pls_lc_list);
> Here >>>>>>
> 	if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
> 			       &lseg->pls_flags))
> 		put_lseg(lseg);
> 
> 
> So list_del_init must be executed under the same lock as 
> pnfs_list_write_lseg, i.e. inode->i_lock.

Agreed if my questions above make no sense.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

