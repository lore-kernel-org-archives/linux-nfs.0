Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37367 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935274AbbCPP6q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 11:58:46 -0400
Date: Mon, 16 Mar 2015 11:58:45 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: nfsd use after free in 4.0-rc
Message-ID: <20150316155845.GC12231@fieldses.org>
References: <20150315125614.GA766@infradead.org>
 <20150315180811.02847842@tlielax.poochiereds.net>
 <20150316114648.GA7432@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316114648.GA7432@infradead.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 04:46:48AM -0700, Christoph Hellwig wrote:
> On Sun, Mar 15, 2015 at 06:08:11PM -0400, Jeff Layton wrote:
> > Could you run gdb against nfsd.ko and do a:
> > 
> >     list *(nfsd4_process_open2+0x1de)
> > 
> > I'd be interesting to see where it crashed. My suspicion would be
> > trying to lock the cl->cl_lock, but I can't tell for sure (and from
> > where).
> 
> That's deep inside the spinlock assembly code, but if I got back far
> enough I get here:
> 
> (gdb) l *(nfsd4_process_open2+0x1c6)
> 0xffffffff813c6026 is in nfsd4_process_open2
> (../fs/nfsd/nfs4state.c:3238).
> 3233		stp->st_stateowner = nfs4_get_stateowner(&oo->oo_owner);
> 3234		get_nfs4_file(fp);
> 3235		stp->st_stid.sc_file = fp;
> 3236		stp->st_access_bmap = 0;
> 3237		stp->st_deny_bmap = 0;
> 3238		stp->st_openstp = NULL;
> 3239		spin_lock(&oo->oo_owner.so_client->cl_lock);
> 3240		list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> 3241		spin_lock(&fp->fi_lock);
> 3242		list_add(&stp->st_perfile, &fp->fi_stateids);

I assume you're testing only NFS v4.1?

--b.
