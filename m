From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 23 Dec 2009 20:12:54 +0100
Message-ID: <1261595574.6775.2.camel@localhost>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost>  <20091223180551.GD3159@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31523 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbZLWTN6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2009 14:13:58 -0500
In-Reply-To: <20091223180551.GD3159-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-23 at 19:05 +0100, Jan Kara wrote: 
> On Wed 23-12-09 15:21:47, Trond Myklebust wrote:
> > @@ -474,6 +482,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
> >  	}
> >  
> >  	spin_lock(&inode_lock);
> > +	/*
> > +	 * Special state for cleaning NFS unstable pages
> > +	 */
> > +	if (inode->i_state & I_UNSTABLE_PAGES) {
> > +		int err;
> > +		inode->i_state &= ~I_UNSTABLE_PAGES;
> > +		spin_unlock(&inode_lock);
> > +		err = commit_unstable_pages(inode, wait);
> > +		if (ret == 0)
> > +			ret = err;
> > +		spin_lock(&inode_lock);
> > +	}
>   I don't quite understand this chunk: We've called writeback_single_inode
> because it had some dirty pages. Thus it has I_DIRTY_DATASYNC set and a few
> lines above your chunk, we've called nfs_write_inode which sent commit to
> the server. Now here you sometimes send the commit again? What's the
> purpose?

We no longer set I_DIRTY_DATASYNC. We only set I_DIRTY_PAGES (and later
I_UNSTABLE_PAGES).

The point is that we now do the commit only _after_ we've sent all the
dirty pages, and waited for writeback to complete, whereas previously we
did it in the wrong order.

Cheers
  Trond
