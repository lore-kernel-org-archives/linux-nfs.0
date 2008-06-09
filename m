Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <76bd70e30806090846x16bf22aoe638a65b07160e69@mail.gmail.com>
Date: Mon, 9 Jun 2008 11:46:35 -0400
From: "Chuck Lever" <chucklever@gmail.com>
To: "Neil Horman" <nhorman@redhat.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how best
	to close the sockets?
In-Reply-To: <20080609152321.GA20181@hmsendeavour.rdu.redhat.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609152321.GA20181@hmsendeavour.rdu.redhat.com>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        Jeff Layton <jlayton@redhat.com>
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

On Mon, Jun 9, 2008 at 11:23 AM, Neil Horman <nhorman@redhat.com> wrote:
> On Mon, Jun 09, 2008 at 11:03:53AM -0400, Peter Staubach wrote:
>> Jeff Layton wrote:
>> >Apologies for the long email, but I ran into an interesting problem the
>> >other day and am looking for some feedback on my general approach to
>> >fixing it before I spend too much time on it:
>> >
>> >We (RH) have a cluster-suite product that some people use for making HA
>> >NFS services. When our QA folks test this, they often will start up
>> >some operations that do activity on an NFS mount from the cluster and
>> >then rapidly do failovers between cluster machines and make sure
>> >everything keeps moving along. The cluster is designed to not shut down
>> >nfsd's when a failover occurs. nfsd's are considered a "shared
>> >resource". It's possible that there could be multiple clustered
>> >services for NFS-sharing, so when a failover occurs, we just manipulate
>> >the exports table.
>> >
>> >The problem we've run into is that occasionally they fail over to the
>> >alternate machine and then back very rapidly. Because nfsd's are not
>> >shut down on failover, sockets are not closed. So what happens is
>> >something like this on TCP mounts:
>> >
>> >- client has NFS mount from clustered NFS service on one server
>> >
>> >- service fails over, new server doesn't know anything about the
>> >  existing socket, so it sends a RST back to the client when data
>> >  comes in. Client closes connection and reopens it and does some
>> >  I/O on the socket.
>> >
>> >- service fails back to original server. The original socket there
>> >  is still open, but now the TCP sequence numbers are off. When
>> >  packets come into the server we end up with an ACK storm, and the
>> >  client hangs for a long time.
>> >
>> >Neil Horman did a good writeup of this problem here for those that
>> >want the gory details:
>> >
>> >    https://bugzilla.redhat.com/show_bug.cgi?id=369991#c16
>> >
>> >I can think of 3 ways to fix this:
>> >
>> >1) Add something like the recently added "unlock_ip" interface that
>> >was added for NLM. Maybe a "close_ip" that allows us to close all
>> >nfsd sockets connected to a given local IP address. So clustering
>> >software could do something like:
>> >
>> >    # echo 10.20.30.40 > /proc/fs/nfsd/close_ip
>> >
>> >...and make sure that all of the sockets are closed.
>> >
>> >2) just use the same "unlock_ip" interface and just have it also
>> >close sockets in addition to dropping locks.
>> >
>> >3) have an nfsd close all non-listening connections when it gets a
>> >certain signal (maybe SIGUSR1 or something). Connections on a
>> >sockets that aren't failing over should just get a RST and would
>> >reopen their connections.
>> >
>> >...my preference would probably be approach #1.
>> >
>> >I've only really done some rudimentary perusing of the code, so there
>> >may be roadblocks with some of these approaches I haven't considered.
>> >Does anyone have thoughts on the general problem or idea for a solution?
>> >
>> >The situation is a bit specific to failover testing -- most people failing
>> >over don't do it so rapidly, but we'd still like to ensure that this
>> >problem doesn't occur if someone does do it.
>> >
>> >Thanks,
>> >
>>
>> This doesn't sound like it would be an NFS specific situation.
>> Why doesn't TCP handle this, without causing an ACK storm?

The NetApp guys can tell you all kinds of horror stories about filer
cluster failover and TCP.

The servers must stop responding to client requests and to client
connection attempts during the failover.  Some clients are not smart
enough to delay their reconnect attempt and will hammer the server
until it finally responds.  That is probably part of the reason for
the "ACK storm".

You also have a problem with what to do about your server's DRC.
During the failover, some requests may get through to the failing
server, and may be executed and retired, but the reply never gets back
to the client because the socket is torn down.

So the best bet for something like this, if you can't shutdown the
nfsd, is to fence the failing server from the network and from
back-end storage.  Something like iptables will not be adequate to
handle the NFS/RPC idempotency issues.

> You're right, its not a problem specific to NFS, any TCP based service in which
> sockets are not explicitly closed on the application are subject to this
> problem.  however, I think NFS is currently the only clustered service that we
> offer in which we explicitly leave nfsd running during such a 'soft' failover,
> and so practically speaking, this is the only place that this issue manifests
> itself.  If we could shut down nfsd on the server doing a failover, that would
> solve this problem (as it prevents the problem with all other clustered tcp
> based services), but from what I'm told, thats a non-starter.
>
> As for why TCP doesnt handle this, thats because the situation is ambiguous from
> the point of view of the client and server.  The write up in the bugzilla has
> all the gory details, but the executive summary is that during rapid failover,
> the client will ack some data to server A in the cluster, and some to server B
> in the cluster.  If you quickly fail over and back between the servers in the
> cluster, each server will see some gaps in the data stream sequence numbers, but
> the client will see that all data has been acked.  This leaves the connection in
> an unrecoverable state.

-- 
I am certain that these presidents will understand the cry of the
people of Bolivia, of the people of Latin America and the whole world,
which wants to have more food and not more cars. First food, then if
something's left over, more cars, more automobiles. I think that life
has to come first.
-- Evo Morales
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
