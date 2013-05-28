Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:13517 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759011Ab3E1WPu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 18:15:50 -0400
Date: Tue, 28 May 2013 18:06:05 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bram Vandoren <brambi@gmail.com>
Message-ID: <716747148.23547.1369778765656.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <DF4BAE59-D436-410A-9BDA-143CF83E7353@oracle.com>
Subject: Re: NFS client hangs after server reboot
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hi-
> 
> On May 28, 2013, at 8:31 AM, Bram Vandoren <brambi@gmail.com> wrote:
> 
> >>> Hi Rick, Chuck, Bruce,
> >>> in attachment is a small pcap when a client is in the locked.
> >>> Hopefully I can reproduce the problem so I can send you a capture
> >>> during a reboot cycle.
> >>
> >> The pcap file confirms that the state IDs and client ID do not
> >> appear to match, and do appear on the same TCP connection (in
> >> different operations). I think the presence of the RENEW operations
> >> here suggest that the client believes it has not been able to renew
> >> its lease using stateful operations like READ. IMO this is evidence
> >> in favor of the theory that the client neglected to recover these
> >> state IDs for some reason.
> >>
> >> We'll need to see the actual reboot recovery traffic to analyze
> >> further, and that occurs just after the server reboots. Even better
> >> would be to see the initial OPEN of the file where the READ
> >> operations are failing. I recognize this is a non-determinstic
> >> problem that will be a challenge to capture properly.
> >>
> >> Rather than capturing the trace on the server, you should be able
> >> to capture it on your clients in order to capture traffic before,
> >> during, and after the server reboot. To avoid capturing an enormous
> >> amount of data, both tcpdump and tshark provide options to save the
> >> captured network data into a small ring of files (see their man
> >> pages). Once a client mount point has locked, you can stop the
> >> capture, and hopefully the ring will have everything we need.
> >
> > Hi All,
> > I managed to capture the packets after a reboot. I send the pcap
> > file
> > to the people in cc (privacy issue, contact me if someone on the
> > list
> > wants a copy). This is a summary of what happens after a reboot
> > (perhaps a missed some relevant information):
> >
> > 38:
> > - client -> server: client executes 3 writes with a stale clientid
> > (A)
> > - client -> server: RENEW
> > 44:
> > - server -> client: NFS4ERR_STALE_STATEID (in reponse to A)
> > 45:
> > - server -> client: NFS4ERR_STALE_CLIENTID
> > 65:
> > - client -> server: RENEW
> > 66
> > - server -> client: NFS4ERR_STALE_CLIENTID
> > 67,85,87,93:
> > SETCLIENTID/SETCLIENTID_CONFIRM sequence (ok)
> > 78,79:
> > NFS4STALE_STATEID (reponse to the other 2 writes in A)
> >
> > 98: OPEN with CLAIM_PREVIOUS
> > 107: response to open: NFS4ERR_NO_GRACE (strange?)
> > after that the client re-opens the files without CLAIM_PREVIOUS
> > option
> > and they are all succesful.
> 
> That means the server is not in its grace period. I'm not familiar
> enough to know if that's typical for FreeBSD servers after a reboot,
> Rick will have to respond to that. The client responds correctly by
> switching to CLAIM_NULL OPENs.
> 
The grace period is somewhat greater than the lease duration (the lease
duration is 2minutes). Without looking at the code, I can't remember how
much more than 2 minutes it is.

You should look at the timestamps on the packets to see how much time
elapsed between 38 and 107. If it is more than 2 minutes, that is simply
not happening quickly enough. If not, then the client might not be noticing
that it needs to do a TCP reconnect + RPC retry quickly and that could mean
that 38 is happening long after the server rebooted, which is when the
server's grace period starts. (NFSv4.1 "fixed" the "when should grace end"
problem, but for NFSv4.0 all a server can do is wait at least 1 lease period
and then end grace, unless it is still seeing reclaim operations.)

rick

> One thing I don't see is an OPEN for the file whose WRITE operations
> fail with NFS4ERR_STALE_STATEID. That looks like a client problem.
> Bram, would you send your pcap file to Trond (cc'd) ?
> 
> > The client starts using the new stateids except for the files in A.
> > The server returns a NFS4_STALE_STATEID, the client executes a RENEW
> > (IMO this should be an OPEN request) and retries the WRITE, the
> > server
> > returns a NFS4_STALE_STATEID
> 
> RENEW is an allowable response in this case. The client is trying to
> detect a server reboot before it continues with OPEN state recovery.
> 
> > Server: FreeBSD 9.1 with new NFS server implementation
> > Client: Fedora 17, 3.8.11-100.fc17.x86_64
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
