Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40622 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612Ab2J2PCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Oct 2012 11:02:07 -0400
Date: Mon, 29 Oct 2012 11:02:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <sven@geggus.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121029150203.GB9502@fieldses.org>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
 <20121026171549.GA11806@fieldses.org>
 <20121029094038.GA14836@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121029094038.GA14836@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Re-adding linux-nfs to cc:

On Mon, Oct 29, 2012 at 10:40:38AM +0100, Sven Geggus wrote:
> J. Bruce Fields schrieb am Freitag, den 26. Oktober um 19:15 Uhr:
> 
> > Could I see a network trace?
> 
> Shure. I can also do one with the working kernel.
> 
> > 	tcpdump -s0 -wtmp.pcap 'host <myclient> && host <myserver>'
> > 
> > then try the mount, then kill tcpdump and send me a copy of tmp.pcap.
> 
> pcap file attached.

Thanks.  So running "wireshark nfs4.pcap", I see:

	frame 13, 15: create a gss context with handle 0x01000000
	frame 17, 18: client sends a DESTROY for context 0x01000000 and
		a TCP FIN.  The RPC is malformed in that it has no verifier
		field.  The server doesn't respond.
	frame 19: client sends a PUTROOTFH using context 0x01000000.
	frame 25-31: a minute has passed, the client gives up, closes
		the connection and retries the PUTROOTFH, again with the
		same context.

That DESTROY is sent over the same connection as the context creation,
so must have been done by gssd.  So gssd has a bug.  Well, two: first,
the DESTROY is malformed, second, it shouldn't be sending it anyway.

I don't understand why the server is dropping requests instead of
returning errors.  I actually would have expected it to return BADVERF
to the DESTROY request and then accept the PUTROOTFH normally, which
might have allowed the mount to succeed despite the bizarre rpc.gssd
behavior.

I'd be curious to understand what changed on the server to make a
difference.  I can't think of anything.  Looking at a network trace from
a successful mount with 3.5.7 might be useful.

--b.

> 
> This is what I called:
> mount -t nfs4 -v -o sec=krb5 centauri:/storage /mnt
> 
> Client ist venus (10.1.7.30), server is centauri (10.1.7.67) kerberos realm
> (AD) is PC.IITB.FHG.DE
> 
> What I should probably also metion is that the machine is a redundant system
> using drbd. The IP-address 10.1.7.67 can be migrated to the the slave
> machine in case of a hardware failure. So if something seems to be missing I
> can also create a capture file including the other IP-address of the
> server system.
> 
> Regards
> 
> Sven
> 
> -- 
> "Those who do not understand Unix are condemned to reinvent it, poorly"
> (Henry Spencer)
> 
> /me is giggls@ircnet, http://sven.gegg.us/ on the Web


