From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Thu, 24 Dec 2009 10:52:28 +0800
Message-ID: <20091224025228.GA12477@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz> <1261595574.6775.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9243 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbZLXCwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Dec 2009 21:52:32 -0500
In-Reply-To: <1261595574.6775.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

On Thu, Dec 24, 2009 at 03:12:54AM +0800, Trond Myklebust wrote:
> On Wed, 2009-12-23 at 19:05 +0100, Jan Kara wrote: 
> > On Wed 23-12-09 15:21:47, Trond Myklebust wrote:
> > > @@ -474,6 +482,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
> > >  	}
> > >  
> > >  	spin_lock(&inode_lock);
> > > +	/*
> > > +	 * Special state for cleaning NFS unstable pages
> > > +	 */
> > > +	if (inode->i_state & I_UNSTABLE_PAGES) {
> > > +		int err;
> > > +		inode->i_state &= ~I_UNSTABLE_PAGES;
> > > +		spin_unlock(&inode_lock);
> > > +		err = commit_unstable_pages(inode, wait);
> > > +		if (ret == 0)
> > > +			ret = err;
> > > +		spin_lock(&inode_lock);
> > > +	}
> >   I don't quite understand this chunk: We've called writeback_single_inode
> > because it had some dirty pages. Thus it has I_DIRTY_DATASYNC set and a few
> > lines above your chunk, we've called nfs_write_inode which sent commit to
> > the server. Now here you sometimes send the commit again? What's the
> > purpose?
> 
> We no longer set I_DIRTY_DATASYNC. We only set I_DIRTY_PAGES (and later
> I_UNSTABLE_PAGES).
> 
> The point is that we now do the commit only _after_ we've sent all the
> dirty pages, and waited for writeback to complete, whereas previously we
> did it in the wrong order.

Sorry I still don't get it. The timing used to be:

write 4MB   ==> WRITE block 0 (ie. first 512KB)
                WRITE block 1
                WRITE block 2
                WRITE block 3         ack from server for WRITE block 0 => mark 0 as unstable (inode marked need-commit)
                WRITE block 4         ack from server for WRITE block 1 => mark 1 as unstable
                WRITE block 5         ack from server for WRITE block 2 => mark 2 as unstable
                WRITE block 6         ack from server for WRITE block 3 => mark 3 as unstable
                WRITE block 7         ack from server for WRITE block 4 => mark 4 as unstable
                                      ack from server for WRITE block 5 => mark 5 as unstable
write_inode ==> COMMIT blocks 0-5
                                      ack from server for WRITE block 6 => mark 6 as unstable (inode marked need-commit)
                                      ack from server for WRITE block 7 => mark 7 as unstable 

                                      ack from server for COMMIT blocks 0-5 => mark 0-5 as clean

write_inode ==> COMMIT blocks 6-7

                                      ack from server for COMMIT blocks 6-7 => mark 6-7 as clean

Note that the first COMMIT is submitted before receiving all ACKs for
the previous writes, hence the second COMMIT is necessary. It seems
that your patch does not improve the timing at all.

Thanks,
Fengguang

