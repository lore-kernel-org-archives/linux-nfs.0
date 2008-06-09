Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 16:11:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: chucklever@gmail.com
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
Message-ID: <20080609161124.2d9a90fd@tleilax.poochiereds.net>
In-Reply-To: <76bd70e30806091236k563412dcib951b848aa9a9ce3@mail.gmail.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609120110.1fee7221@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609122249.51767b21@tleilax.poochiereds.net>
	<76bd70e30806091236k563412dcib951b848aa9a9ce3@mail.gmail.com>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        nhorman@redhat.com
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Jun 2008 15:36:18 -0400
"Chuck Lever" <chuck.lever@oracle.com> wrote:

> On Mon, Jun 9, 2008 at 12:22 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Mon, 09 Jun 2008 12:09:48 -0400
> > "Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
> >
> >> At 12:01 PM 6/9/2008, Jeff Layton wrote:
> >> >On Mon, 09 Jun 2008 11:51:51 -0400
> >> >"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
> >> >
> >> >> At 11:18 AM 6/9/2008, Jeff Layton wrote:
> >> >> >No, it's not specific to NFS. It can happen to any "service" that
> >> >> >floats IP addresses between machines, but does not close the sockets
> >> >> >that are connected to those addresses. Most services that fail over
> >> >> >(at least in RH's cluster server) shut down the daemons on failover
> >> >> >too, so tends to mitigate this problem elsewhere.
> >> >>
> >> >> Why exactly don't you choose to restart the nfsd's (and lockd's) on the
> >> >> victim server?
> >> >
> >> >The victim server might have other nfsd/lockd's running on them. Stopping
> >> >all the nfsd's could bring down lockd, and then you have to deal with lock
> >> >recovery on the stuff that isn't moving to the other server.
> >>
> >> But but but... the IP address is the only identification the client can use
> >> to isolate a server. You're telling me that some locks will migrate and
> >> some won't? Good luck with that! The clients are going to be mightily
> >> confused.
> >>
> >
> > Maybe I'm not being clear. My understanding is this:
> >
> > Right now, when we fail over we send a SIGKILL to lockd, and then send
> > a SM_NOTIFY to all of the clients that the "victim" server has,
> > regardless of what IP address the clients are talking to. So all locks
> > get dropped and all clients should recover their locks. Since the
> > service will fail over to the new host, locks that were in that export
> > will get recovered on the "new" host.
> >
> > But, we just recently added this new "unlock_ip" interface. With that,
> > we should be able to just send SM_NOTIFY's to clients of that IP
> > address. Locks associated with that server address will be recovered
> > and the others should be unaffected.
> 
> Maybe that's a little imprecise.
> 
> The failover_unlock_ip() API doesn't send any SM_NOTIFY calls at all,
> it tells the server's NLM to drop all locks held by that IP, but
> there's logic in nlmsvc_is_client() specifically to keep monitoring
> these clients.  The SM_NOTIFY calls will come from user space, just to
> be clear.
> 
> If this is truly a service migration, I would think that the old
> server would want to stop monitoring these clients anyway.
> 
> > All of
> > the NSM/NLM stuff here is really separate from the main problem I'm
> > interested in at the moment, which is how to deal with the old, stale
> > sockets that nfsd has open after the local address disappears.
> 
> IMO it's just the reverse: the main problem is how to do service
> migration in a robust fashion; the bugs you are focused on right at
> the moment are due to the fact the current migration strategy is
> poorly designed.  The real issue is how do you fix your design, and
> that's a lot bigger than addressing a few SYNs and ACKs.  I do not
> believe there is going to be a simple network level fix here if you
> want to prevent more corner cases.
> 
> I am still of the opinion that you can't do this without involvement
> from the nfsd threads.  The old server is going to have to stop
> accepting incoming connections during the failover period.  NetApp
> found that it is not enough to drop a newly accepted connection
> without having read any data -- that confuses some clients.  Your
> server really does need to shut off the listener, in order to refuse
> new connections.
> 

I'm not sure I follow your logic here. The first thing that happens
when failover occurs is that the IP address is removed from the
interface. This prevents new connections on that IP address (and new
packets for existing connections for that matter). Why would this not
be sufficient to prevent new activity on those sockets?

> I think this might be a new server state.  A bunch of nfsd threads
> will exist and be processing NFS requests, but there will be no
> listener.
> 
> Then the old server can drain the doomed sockets and disconnect them
> in an orderly manner.  This will prevent a lot of segment ordering
> problems and keep network layer confusion about socket state to a
> minimum.  It's a good idea to try to return any pending replies to
> clients before closing the connection to reduce the likelihood of RPC
> retransmits.  To prevent the clients from transmitting any new
> requests, use a half-close (just close the receiving half of the
> connection on the server).
> 

Ahh ok. So you're thinking that we need to keep the IP address in place
so that we can send replies for RPC's that are still in progress? That
makes sense.

I suppose that instead of shutting down the listener altogether, we
could just have the listener refuse connections for the given destination
address. That's probably simpler and would mean less disruption for exports
on other IP addrs.

That said, if we assume we want to use the unlock_ip interface then
there's a potential race between writing to unlock_ip and taking down
the address. I'll have to think about how to deal with that maybe some
sort of 3 stage teardown:

1) refuse new connections for the IP address, drain the RPC queues,
   half close sockets

2) remove the address from the interface

3) close sockets the rest of the way, stop refusing connections

Then again, we might actually be better off restarting nfsd instead. It's
certainly simpler...

> Naturally this will have to be time-bounded because clients can be too
> busy to read any remaining data off the socket, or could just be dead.
>  That shouldn't hold up your service migration event.
> 

Definitely.

> Any clients attempting to connect to the old server during failover
> will be refused.  If they are trying to access legitimate NFS
> resources that have not been migrated, they will retry connecting
> later, so this really shouldn't be an issue.  Clients connecting to
> the new server should be OK, but again, I think they should be fenced
> from the old server's file system until the old server has finished
> processing any pending requests from clients that are being migrated
> to the new server.
> 
> When failover is complete, the old server can start accepting new TCP
> connections again.  Clients connecting to the old server looking for
> migrated resources should get something like ESTALE ("These are not
> the file handles you are looking for.").
> 

I think we return -EACCES or something (whatever you get when you try to
access something that isn't exported). We remove the export from the
exports table when we fail over.

> In this way, the server is in control over the migration, and isn't
> depending on any wonky TCP behavior to make it happen correctly.  It's
> using entirely legitimate features of the socket interface to move
> each client through the necessary states of migration.
> 
> Now that the network connections are figured out, your servers can
> start worrying about recoverying NLM, NSM, and DRC state.
> 
-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
