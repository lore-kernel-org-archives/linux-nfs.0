From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 14:27:01 +1000
Message-ID: <17552.57749.121240.42384@cse.unsw.edu.au>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-cluster@redhat.com
Return-path: <linux-cluster-bounces@redhat.com>
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Wednesday June 14
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

On Wednesday June 14, wcheng@redhat.com wrote:
> Hi,
> 
> KABI (kernel application binary interface) commitment is a big thing
> from our end - so I would like to focus more on the interface agreement
> before jumping into coding and implementation details. 
> 

Before we can agree on an interface, we need to be clear what
functionality is required.

You started out suggesting that the required functionality was to
"remove all locks that lockd holds on a particular filesystem".

I responded that I suspect a better functionality was "remove all
locks that locked holds on behalf of a particular IP address".

You replied that this such an approach

>  give[s] individual filesystem no freedom to adjust what they
> need upon failover. 

I asked:
> Can you say more about what sort of adjustments an individual filesystem
> might want the freedom to make?  It might help me understand the
> issues better.

and am still waiting for an answer.  Without an answer, I still lean
towards and IP-address based approach, and the reply from James
Yarbrough seems to support that (though I don't want to read too much
into his comments).

Lockd is not currently structured to associate locks with
server-ip-addresses.  There is an assumption that one client may talk
to any of the IP addresses that the server supports.  This is clearly
not the case for the failover scenario that you are considering, so a
little restructuring might be in order.

Some locks will be held on behalf of a client, no matter what
interface the requests arrive on.  Other locks will be held on behalf
of a client and tied to a particular server IP address.  Probably the
easiest way to make this distinction in as a new nfsd export flag.

So, maybe something like this:

  Add a 'struct sockaddr_in' to 'struct nlm_file'.
  If nlm_fopen return (say) 3, then treat is as success, and 
    also copy rqstp->rq_addr into that 'sockaddr_in'.
  define a new file in the 'nfsd' filesystem into which can
    be written an IP address and which calls some new lockd
    function which releases all locks held for that IP address.
  Probably get nlm_lookup_file to insist that if the sockaddr_in
    is defined in a lock, it must match the one in rqstp

Does that sound OK ?


> >   One is the multiple-lockd-threads idea.
> 
> Assume we still have this on the table.... Could I expect the admin
> interface goes thru rpc.lockd command (man page and nfs-util code
> changes) ? The modified command will take similar options as rpc.statd;
> more specifically, the -n, -o, and -p (see "man rpc.statd"). To pass the
> individual IP (socket address) to kernel, we'll need nfsctl with struct
> nfsctl_svc modified.

I'm losing interest in the multiple-lockd-threads approach myself (for
the moment anyway :-)
However I would be against trying to re-use rpc.lockd - that was a
mistake that is best forgotten.
If the above approach were taken, then I don't think you need anything
more than
   echo aa.bb.cc.dd > /proc/fs/nfsd/vserver_unlock
(or whatever), though it you really want to wrap that in a shell
script that might be ok.

> 
> For the kernel piece, since we're there anyway, could we have the
> individual lockd IP interface passed to SM (statd) (in SM_MON call) ?
> This would allow statd to structure its SM files based on each lockd IP
> address, an important part of lock recovery.
> 

Maybe....  but I don't get the scenario.
Surely the SM files are only needed when the server  restarts, and in
that case it needs to notify all clients... Or is it that you want to
make sure the notification comes from the right IP address.... I guess
that would make sense.  I that what you are after?


> >   One is to register a callback when an interface is shut down.
> 
> Haven't checked out (linux) socket interface yet. I'm very fuzzy how
> this can be done. Anyone has good ideas ? 

No good idea, but I have a feeling there is a callback we could use.
However I think I am going off this idea.

> 
> >   Another (possibly the best) is to arrange a new signal for lockd
> >   which say "Drop any locks which were sent to IP addresses that are
> >   no longer valid local addresses".
> 
> Very appealing - but the devil's always in the details. How to decide
> which IP address is no longer valid ? Or how does lockd know about these
> IP addresses ? And how to associate one particular IP address with the
> "struct nlm_file" entries within nlm_files list ? Need few more days to
> sort this out (or any one already has ideas in mind ?).

See above.

NeilBrown
