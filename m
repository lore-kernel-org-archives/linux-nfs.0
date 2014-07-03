Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40579 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758412AbaGCOkJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2014 10:40:09 -0400
Date: Thu, 3 Jul 2014 10:40:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 004/114] nfsd: Avoid taking state_lock while holding
 inode lock in nfsd_break_one_deleg
Message-ID: <20140703144008.GB24322@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-5-git-send-email-jlayton@primarydata.com>
 <20140702211424.GD11510@fieldses.org>
 <20140703072012.74b78c49@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140703072012.74b78c49@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 03, 2014 at 07:20:12AM -0400, Jeff Layton wrote:
> On Wed, 2 Jul 2014 17:14:24 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jun 30, 2014 at 11:48:33AM -0400, Jeff Layton wrote:
> > > state_lock is a heavily contended global lock. We don't want to grab
> > > that while simultaneously holding the inode->i_lock.
> > > 
> > > Add a new per-nfs4_file lock that we can use to protect the
> > > per-nfs4_file delegation list. Hold that while walking the list in the
> > > break_deleg callback and queue the workqueue job for each one.
> > > 
> > > The workqueue job can then take the state_lock and do the list
> > > manipulations without the i_lock being held prior to starting the
> > > rpc call.
> > 
> > The code tends to assume that the callback thread only works with the
> > delegation struct itself and puts it when done but doesn't otherwise
> > touch other state.
> > 
> > I wonder how this interacts with state shutdown.... 
> > 
> > E.g. in nfs4_state_shutdown_net() we walk the dl_recall_lru and destroy
> > everything we find, but this callback workqueue is still running so I
> > think another delegation could get added to that list after this?  Does
> > that cause bugs?
> > 
> 
> I don't see what would prevent those bugs today and I'm unclear on why
> you think this patch will make things worse. All this patch really does
> is protect the dl_perfile list manipulations with a new per-nfs4_file
> lock, and have it lock that when walking the perfile list. Then it has
> the workqueue callback do the work of adding it to the del_recall_lru
> list.
> 
> Why wouldn't you have the same problem if you do the queueing to the
> LRU list in break_deleg codepath with the code as it is today?

Yeah, I suppose so.

> That said, the delegation code is horribly complex so it's possible
> I've missed something here.
> 
> > And it'd also be worth checking delegreturn and destroy_client.
> > 
> > Maybe there's no bug, or they just need to flush the workqueue at the
> > appropriate point.
> > 
> > There's also a preexisting expire_client/laundromat vs break race:
> > 
> > 	- expire_client/laundromat adds a delegation to its local
> > 	  reaplist using the same dl_recall_lru field that a delegation
> > 	  uses to track its position on the recall lru and drops the
> > 	  state lock.
> > 
> > 	- a concurrent break_lease adds the delegation to the lru.
> > 
> > 	- expire/client/laundromat then walks it reaplist and sees the
> > 	  lru head as just another delegation on the list....
> > 
> > Possibly unrelated, but it might be good to fix that first.
> > 
> > --b.
> > 
> 
> I was thinking that that would be fixed up in a later patch:
> 
>     nfsd: Fix delegation revocation
> 
> ...but now I'm not so sure. Once you drop the fi_lock, you could end up
> with the race above.
> 
> Honestly, the locking around the delegation code is still a mess, even
> with this series. I don't care much for the state_lock/recall_lock at
> all. It seems like we ought to be able to do something more granular
> there. Let me give it some thought -- maybe I can come up with a better
> way to handle this.

OK.  I agree that it's too complicated.

--b.
