Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:51147 "EHLO
	esa-annu.net.uoguelph.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759270Ab3E1Xas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 19:30:48 -0400
Date: Tue, 28 May 2013 19:30:46 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Bram Vandoren <brambi@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <1480713067.24683.1369783846612.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <CACQjR_D3rFy9dfb4LvywrDi24D0hucvsifXavivJ7UpkEgTLjA@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bram Vandoren wrote:
> >> Hi Rick, Chuck, Bruce,
> >> in attachment is a small pcap when a client is in the locked.
> >> Hopefully I can reproduce the problem so I can send you a capture
> >> during a reboot cycle.
> >
> > The pcap file confirms that the state IDs and client ID do not
> > appear to match, and do appear on the same TCP connection (in
> > different operations). I think the presence of the RENEW operations
> > here suggest that the client believes it has not been able to renew
> > its lease using stateful operations like READ. IMO this is evidence
> > in favor of the theory that the client neglected to recover these
> > state IDs for some reason.
> >
> > We'll need to see the actual reboot recovery traffic to analyze
> > further, and that occurs just after the server reboots. Even better
> > would be to see the initial OPEN of the file where the READ
> > operations are failing. I recognize this is a non-determinstic
> > problem that will be a challenge to capture properly.
> >
> > Rather than capturing the trace on the server, you should be able to
> > capture it on your clients in order to capture traffic before,
> > during, and after the server reboot. To avoid capturing an enormous
> > amount of data, both tcpdump and tshark provide options to save the
> > captured network data into a small ring of files (see their man
> > pages). Once a client mount point has locked, you can stop the
> > capture, and hopefully the ring will have everything we need.
> 
> Hi All,
> I managed to capture the packets after a reboot. I send the pcap file
> to the people in cc (privacy issue, contact me if someone on the list
> wants a copy). This is a summary of what happens after a reboot
> (perhaps a missed some relevant information):
> 
> 38:
> - client -> server: client executes 3 writes with a stale clientid (A)
> - client -> server: RENEW
> 44:
> - server -> client: NFS4ERR_STALE_STATEID (in reponse to A)
> 45:
> - server -> client: NFS4ERR_STALE_CLIENTID
> 65:
> - client -> server: RENEW
> 66
> - server -> client: NFS4ERR_STALE_CLIENTID
> 67,85,87,93:
> SETCLIENTID/SETCLIENTID_CONFIRM sequence (ok)
> 78,79:
> NFS4STALE_STATEID (reponse to the other 2 writes in A)
> 
> 98: OPEN with CLAIM_PREVIOUS
> 107: response to open: NFS4ERR_NO_GRACE (strange?)
> after that the client re-opens the files without CLAIM_PREVIOUS option
> and they are all succesful.
> 
> The client starts using the new stateids except for the files in A.
> The server returns a NFS4_STALE_STATEID, the client executes a RENEW
> (IMO this should be an OPEN request) and retries the WRITE, the server
> returns a NFS4_STALE_STATEID
> 
> Server: FreeBSD 9.1 with new NFS server implementation
> Client: Fedora 17, 3.8.11-100.fc17.x86_64
> 
> Any clues?
> 
> Thanks,
> Bram
I just took a look at the packet capture (I hadn't realized you had
posted one when I did the last reply).

I think the problem is a TCP layer one, from looking at the first 8
packets captured amd their timestamps. However, my TCP is old and
tired, so I'm not sure. From the first 8 packets:
Time(sec)
0  - client sends a SYN
0  - server replies [RST, ACK]
     Since Reset is in the reply, is this when the server rebooted?
6  - client sends a SYN with same port#s. Wireshark thinks this is
     a new connection using same port#s.
6  - FreeBSD replies with [RST, ACK] again, thinking it is a resend
     of the first packet and still considers it the old Reset connection.
15 - Repeat of what happened at 6sec.
30,31 - client sends SYN twice, still from the same port#s
   - no reply from FreeBSD
4393 - client sends SYN again with same port#s
4393 - server replies with [SYN, ACK] establishing the new TCP
     connection on the same port#s, but over an hour later.
Since this is now over an hour after packet 0, it isn't
surprising that Grace is over.

I'd guess that the problem occurs because the client reconnect
uses the same client side port# even though the server did a
Reset for that port#, but I'm not enough of a TCP guy to know
what should be correct TCP behaviour.

If you don't mind the first part of this packet capture being
posted (email me to say if it ok to post it), I can post it to
freebsd-net@freebsd.org, since there are a bunch of TCP savy
types that might be able to help. (If you give the ok for this,
please also email me what version of FreeBSD the server is
running.)

rick
