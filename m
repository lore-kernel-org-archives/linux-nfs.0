From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [NFS] Re: [RFC] NLM lock failover admin interface
Date: Fri, 16 Jun 2006 11:39:04 -0400
Message-ID: <20060616153904.6A9A21BCBD@citi.umich.edu>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<1150293654.28264.91.camel@localhost.localdomain>
	<20060615140743.36CDC1BBAD@citi.umich.edu>
	<17554.19245.914383.436585@cse.unsw.edu.au>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: Neil Brown <neilb@suse.de>
In-reply-to: <17554.19245.914383.436585@cse.unsw.edu.au> 
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

> On Thursday June 15, andros@citi.umich.edu wrote:
> > this discusion has centered around removing the locks of an export.
> > we also want the interface to ge able to remove the locks owned by a single 
> > client. this is needed to enable client migration between replica's or between 
> > nodes in a cluster file system. it is not acceptable to place an entire export 
> > in grace just to move a small number of clients.
> 
> Hmmmm....
> You want to remove all the locks owned by a particular client
> with the intension of reclaiming those locks against a different NFS
> server (on a cluster filesystem)
> and you don't want to put the whole filesystem into grace mode while
> doing it.
> 
> Is that correct?

yes.

> 
> Sounds extremely racy to me.  Suppose some other client takes a
> conflicting lock between dropping them on one server and claiming them
> on the other?  That would be bad.  The purpose of the grace mode is
> precisely to avoid this sort of race.

the idea is that the underlying file system can place only the files with 
locks held by the migrating client(s) into grace, leaving all other files for 
normal operation. the migrating (nfsv4) client then reclaims opens, locks and 
delegations on the new server. its just reducing the scope of the grace period.

> 
> It would seem that what you "really" want to do is to tell the cluster
> filesystem to migrate the locks to a different node and some how tell
> lockd about out.

what we really want is for the cluster file system to share the locks between 
the original node and the new node. then the client can simply be redirected 
and no grace period or reclaim is needed. this is much harder to code than a 
reduced grace period as describe above. from what we hear, lustre has this 
functionality.

either way, the files with locks held by the migrating client need to be 
identified by both the lock manager (lockd/nfsv4 server) and the underlying fs.

> 
> Is there a comprehensive design document about how this is going to
> work, because I'm feeling doubtful.

we have a work in progress - it's not done but may help describe our thinking.

http://wiki.linux-nfs.org/index.php/Recovery_and_migration

> 
> For the 'between replicas' case - I'm not sure locking makes sense.
> Locking on a read-only filesystem is pretty pointless, and presumably
> replicas are read-only???

nope. we have a promising prototye read/write replica scheme that we are 
testing.

http://www.citi.umich.edu/techreports/reports/citi-tr-06-3.pdf

i agree this is an outlying case....

but another immediate consumer of such an iterface would be an administator 
who needs to remove the locks for a client.

-->Andy

> 
> Basically, dropping locks that are expected to be picked up again,
> without putting the whole filesystem into a grace period simply
> doesn't sound workable to me.
> 
> Am I missing something?
> 
> NeilBrown
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
