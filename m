Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:23589 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab3DJXX0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 19:23:26 -0400
Date: Wed, 10 Apr 2013 19:23:24 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Bram Vandoren <brambi@gmail.com>
Message-ID: <449485738.724843.1365636204483.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com>
Subject: Re: NFS client hangs after server reboot
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> [ Adding Rick Macklem ]
> 
> On Apr 9, 2013, at 3:08 PM, J. Bruce Fields <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Apr 09, 2013 at 05:51:40PM +0200, Bram Vandoren wrote:
> >> Hello,
> >> we have a FreeBSD 9.1 fileserver and several clients running kernel
> >> 3.8.4-102.fc17.x86_64. Everything works fine till we reboot the
> >> server. A fraction (1/10) of the clients don't resume the NFS
> >> session
> >> correctly. The server sends a NFS4ERR_STALE_STATEID. The client
> >> sends
> >> a RENEW to the server but no SETCLIENTID. (this should be the
> >> correct
> >> action from my very quick look at RFC 3530). After that the client
> >> continues with a few READ call and the process starts again with
> >> the
> >> NFS4ERR_STALE_STATEID response from the server. It generates a lot
> >> of
> >> useless network traffic.
> >
> >   0.003754 a.b.c.2 -> a.b.c.120 NFS 122 V4 Reply (Call In 49) READ
> >   Status: NFS4ERR_STALE_STATEID
> >   0.003769 a.b.c.2 -> a.b.c.120 NFS 114 V4 Reply (Call In 71) RENEW
> >
> > I don't normally use tshark, so I don't know--does the lack of a
> > status
> > on that second line indicate that the RENEW succeeded?
> >
> > Assuming the RENEW is for the same clientid that the read stateid's
> > are
> > associated with--that's definitely a server bug. The RENEW should be
> > returning STALE_CLIENTID.
> 
> The server is returning NFS4_OK to that RENEW and we appear to be out
> of the server's grace period. Thus we can assume that state recovery
> has already been performed following the server reboot, and a fresh
> client ID has been correctly established. One possible explanation for
> NFS4ERR_STALE_STATEID is that the client skipped recovering these
> state IDs for some reason.
> 
This is a possible explanation. There is a "boottime" field in both
the clientid and stateid for a FreeBSD NFSv4 server, which is checked
and generates a NFS4ERR_STALE_CLIENTID or NFS4ERR_STALE_STATEID, depending
on whether it is a clientid or stateid. In other words, the code would
generate the stale error message for all clientids/stateids that were
issued before the server reboot. (Also, the FreeBSD server delays the
end of grace until it doesn't see any reclaim ops for a while, so it
shouldn't just run out of grace period, unless the client delays for
seconds without completing a recovery.)

If you have a capture of the above that you can look at in wireshark,
you could look at the bits that make up the stateid/clientid. Although
I don't have the code in front of me, but I think the first 32bits are
the "boottime" and should be different for the stateid vs clientid for
the above two RPCs.

> A full network capture in pcap format, started before the server
> reboot occurs, would be needed for us to analyze the issue properly.
> 
I agree. A network capture on the server from when it reboots would
be needed to analyse this. You could stick a line to start a tcpdump
capture in the /etc/rc.d/nfsd script or disable starting the nfsd
in /etc/rc.conf and then start it manually after starting a
"tcpdump -w reboot.pcap -s 0" or similar.

If you get such a <file>.pcap, I could probably take a look at it,
although it might not happen until May.

rick

> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
