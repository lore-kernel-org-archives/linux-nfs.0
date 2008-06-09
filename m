From: Peter Staubach <staubach@redhat.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how best
 to	close the sockets?
Date: Mon, 09 Jun 2008 11:03:53 -0400
Message-ID: <484D4659.9000105@redhat.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, nhorman@redhat.com,
	lhh@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753715AbYFIPED (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 11:04:03 -0400
In-Reply-To: <20080609103137.2474aabd-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> Apologies for the long email, but I ran into an interesting problem the
> other day and am looking for some feedback on my general approach to
> fixing it before I spend too much time on it:
>
> We (RH) have a cluster-suite product that some people use for making HA
> NFS services. When our QA folks test this, they often will start up
> some operations that do activity on an NFS mount from the cluster and
> then rapidly do failovers between cluster machines and make sure
> everything keeps moving along. The cluster is designed to not shut down
> nfsd's when a failover occurs. nfsd's are considered a "shared
> resource". It's possible that there could be multiple clustered
> services for NFS-sharing, so when a failover occurs, we just manipulate
> the exports table.
>
> The problem we've run into is that occasionally they fail over to the
> alternate machine and then back very rapidly. Because nfsd's are not
> shut down on failover, sockets are not closed. So what happens is
> something like this on TCP mounts:
>
> - client has NFS mount from clustered NFS service on one server
>
> - service fails over, new server doesn't know anything about the
>   existing socket, so it sends a RST back to the client when data
>   comes in. Client closes connection and reopens it and does some
>   I/O on the socket.
>
> - service fails back to original server. The original socket there
>   is still open, but now the TCP sequence numbers are off. When
>   packets come into the server we end up with an ACK storm, and the
>   client hangs for a long time.
>
> Neil Horman did a good writeup of this problem here for those that
> want the gory details:
>
>     https://bugzilla.redhat.com/show_bug.cgi?id=369991#c16
>
> I can think of 3 ways to fix this:
>
> 1) Add something like the recently added "unlock_ip" interface that
> was added for NLM. Maybe a "close_ip" that allows us to close all
> nfsd sockets connected to a given local IP address. So clustering
> software could do something like:
>
>     # echo 10.20.30.40 > /proc/fs/nfsd/close_ip
>
> ...and make sure that all of the sockets are closed.
>
> 2) just use the same "unlock_ip" interface and just have it also
> close sockets in addition to dropping locks.
>
> 3) have an nfsd close all non-listening connections when it gets a
> certain signal (maybe SIGUSR1 or something). Connections on a
> sockets that aren't failing over should just get a RST and would
> reopen their connections.
>
> ...my preference would probably be approach #1.
>
> I've only really done some rudimentary perusing of the code, so there
> may be roadblocks with some of these approaches I haven't considered.
> Does anyone have thoughts on the general problem or idea for a solution?
>
> The situation is a bit specific to failover testing -- most people failing
> over don't do it so rapidly, but we'd still like to ensure that this
> problem doesn't occur if someone does do it.
>
> Thanks,
>   

This doesn't sound like it would be an NFS specific situation.
Why doesn't TCP handle this, without causing an ACK storm?

    Thanx...

       ps
