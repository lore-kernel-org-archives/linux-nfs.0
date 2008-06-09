Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 11:43:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Horman <nhorman@redhat.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to	close the sockets?
Message-ID: <20080609114358.27eb02a1@tleilax.poochiereds.net>
In-Reply-To: <20080609153155.GB20181@hmsendeavour.rdu.redhat.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<20080609153155.GB20181@hmsendeavour.rdu.redhat.com>
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

On Mon, 9 Jun 2008 11:31:55 -0400
Neil Horman <nhorman@redhat.com> wrote:

> On Mon, Jun 09, 2008 at 11:18:21AM -0400, Jeff Layton wrote:
> > On Mon, 09 Jun 2008 11:03:53 -0400
> > Peter Staubach <staubach@redhat.com> wrote:
> > 
> > > Jeff Layton wrote:
> > > > Apologies for the long email, but I ran into an interesting problem the
> > > > other day and am looking for some feedback on my general approach to
> > > > fixing it before I spend too much time on it:
> > > >
> > > > We (RH) have a cluster-suite product that some people use for making HA
> > > > NFS services. When our QA folks test this, they often will start up
> > > > some operations that do activity on an NFS mount from the cluster and
> > > > then rapidly do failovers between cluster machines and make sure
> > > > everything keeps moving along. The cluster is designed to not shut down
> > > > nfsd's when a failover occurs. nfsd's are considered a "shared
> > > > resource". It's possible that there could be multiple clustered
> > > > services for NFS-sharing, so when a failover occurs, we just manipulate
> > > > the exports table.
> > > >
> > > > The problem we've run into is that occasionally they fail over to the
> > > > alternate machine and then back very rapidly. Because nfsd's are not
> > > > shut down on failover, sockets are not closed. So what happens is
> > > > something like this on TCP mounts:
> > > >
> > > > - client has NFS mount from clustered NFS service on one server
> > > >
> > > > - service fails over, new server doesn't know anything about the
> > > >   existing socket, so it sends a RST back to the client when data
> > > >   comes in. Client closes connection and reopens it and does some
> > > >   I/O on the socket.
> > > >
> > > > - service fails back to original server. The original socket there
> > > >   is still open, but now the TCP sequence numbers are off. When
> > > >   packets come into the server we end up with an ACK storm, and the
> > > >   client hangs for a long time.
> > > >
> > > > Neil Horman did a good writeup of this problem here for those that
> > > > want the gory details:
> > > >
> > > >     https://bugzilla.redhat.com/show_bug.cgi?id=369991#c16
> > > >
> > > > I can think of 3 ways to fix this:
> > > >
> > > > 1) Add something like the recently added "unlock_ip" interface that
> > > > was added for NLM. Maybe a "close_ip" that allows us to close all
> > > > nfsd sockets connected to a given local IP address. So clustering
> > > > software could do something like:
> > > >
> > > >     # echo 10.20.30.40 > /proc/fs/nfsd/close_ip
> > > >
> > > > ...and make sure that all of the sockets are closed.
> > > >
> > > > 2) just use the same "unlock_ip" interface and just have it also
> > > > close sockets in addition to dropping locks.
> > > >
> > > > 3) have an nfsd close all non-listening connections when it gets a
> > > > certain signal (maybe SIGUSR1 or something). Connections on a
> > > > sockets that aren't failing over should just get a RST and would
> > > > reopen their connections.
> > > >
> > > > ...my preference would probably be approach #1.
> > > >
> > > > I've only really done some rudimentary perusing of the code, so there
> > > > may be roadblocks with some of these approaches I haven't considered.
> > > > Does anyone have thoughts on the general problem or idea for a solution?
> > > >
> > > > The situation is a bit specific to failover testing -- most people failing
> > > > over don't do it so rapidly, but we'd still like to ensure that this
> > > > problem doesn't occur if someone does do it.
> > > >
> > > > Thanks,
> > > >   
> > > 
> > > This doesn't sound like it would be an NFS specific situation.
> > > Why doesn't TCP handle this, without causing an ACK storm?
> > > 
> > 
> > No, it's not specific to NFS. It can happen to any "service" that
> > floats IP addresses between machines, but does not close the sockets
> > that are connected to those addresses. Most services that fail over
> > (at least in RH's cluster server) shut down the daemons on failover
> > too, so tends to mitigate this problem elsewhere.
> > 
> > I'm not sure how the TCP layer can really handle this situation. On
> > the wire, it looks to the client and server like the connection has
> > been hijacked (and in a sense, it has). It would be nice if it
> > didn't end up in an ACK storm, but I'm not aware of a way to prevent
> > that that stays within the spec.
> > 
> I've not really thought it through yet, but would IP tables be another options
> here?  Could you, if you preformed a soft failover, add a rule that responded to
> any frame on an active connection that wasn't a SYN frame, force the sending of
> an ACK frame?  It probably wouldn't scale, and its kind of ugly, but it could
> work...
> 

Yow, that is ugly...

So once a client does a new SYN, what would have to happen to make the
connection then work? That sounds pretty complicated. I could forsee
using
iptables here though...

When the service is "leaving" the server:

1) add rule to drop all traffic to port 2049
2) restart all of the nfsd's
3) remove iptables rule

...that would (briefly) disrupt communications between all clients and
the server, but it probably would work. You'd need to drop traffic to
prevent races that might get you an "Connection Refused".

Still, it's a kludge. I'd prefer a fix that didn't cause service
disruptions for anything but the stuff that's failing over. Also, that
would be pretty nightmarish from a coding standpoint. People have all
sorts of firewalling configurations, so doing this may be difficult in
practice.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
