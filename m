Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26943 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758096Ab1DNTdc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 15:33:32 -0400
Subject: Re: [PATCH] NFS: dont restart loop in nfs_delegation_reap_unclaimed
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Weston Andros Adamson <dros@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <F6E1551C-3A7B-4BD4-8C31-62996BEE2ACC@oracle.com>
References: <1302807855-84959-1-git-send-email-dros@netapp.com>
	 <F6E1551C-3A7B-4BD4-8C31-62996BEE2ACC@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Apr 2011 15:33:29 -0400
Message-ID: <1302809609.24028.66.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-04-14 at 15:10 -0400, Chuck Lever wrote:
> On Apr 14, 2011, at 3:04 PM, Weston Andros Adamson wrote:
> 
> > The loop was being restarted after each delegation that has NFS_DELEGATION_NEED_RECLAIM
> > set.  Instead, build a temporary list of delegations that need to be freed and free
> > them after the for-each-delegation loop.
> > 
> > Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> > ---
> > fs/nfs/delegation.c |   16 +++++++++++-----
> > 1 files changed, 11 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > index bbbc6bf..c87fad8 100644
> > --- a/fs/nfs/delegation.c
> > +++ b/fs/nfs/delegation.c
> > @@ -645,8 +645,8 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
> > 	struct nfs_delegation *delegation;
> > 	struct nfs_server *server;
> > 	struct inode *inode;
> > +	LIST_HEAD(tmplist);
> > 
> > -restart:
> > 	rcu_read_lock();
> > 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
> > 		list_for_each_entry_rcu(delegation, &server->delegations,
> > @@ -659,15 +659,21 @@ restart:
> > 				continue;
> > 			delegation = nfs_detach_delegation(NFS_I(inode),
> > 								server);
> > -			rcu_read_unlock();
> > -
> > +			/* super_list is unused now that deleg is detached */
> > 			if (delegation != NULL)
> > -				nfs_free_delegation(delegation);
> > +				list_add(&delegation->super_list, &tmplist);
> > +
> > 			iput(inode);
> 
> /me idly wonders if that iput() is safe to do inside rcu_read_lock() / rcu_read_unlock().

It isn't....

> > -			goto restart;
> > 		}
> > 	}
> > 	rcu_read_unlock();
> > +
> > +	while (!list_empty(&tmplist)) {
> > +		delegation = list_first_entry(&tmplist, struct nfs_delegation,
> > +					super_list);
> > +		list_del(&delegation->super_list);
> > +		nfs_free_delegation(delegation);
> > +	}
> > }

There is also the issue that the inode may have disappeared when we get
to this stage; there is nothing pinning it in memory any more.

One suggestion would be to move the iput into the above loop.

The question is, though, whether or not we get much of a performance
improvement.
One advantage of the current scheme is that we're immediately freeing
the delegation after detaching it. If you queue up the delegations for
freeing, then a process that may need to free a delegation that is at
the end of that list in order to make progress (because it wants to
rename a file, or open it for writing) may have a longer wait during
which the server will be replying NFS4ERR_DELAY.

Do we have any evidence for or against?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

