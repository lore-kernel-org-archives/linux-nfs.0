Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35271 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbIQOSx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 10:18:53 -0400
Received: by ioiz6 with SMTP id z6so23233072ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 07:18:53 -0700 (PDT)
Message-ID: <1442499509.2865.16.camel@primarydata.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        AnnaSchumaker <anna.schumaker@netapp.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Sep 2015 10:18:29 -0400
In-Reply-To: <20150917135705.GQ21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
	 <20150911150613.GR21084@n2100.arm.linux.org.uk>
	 <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150911162416.GV21084@n2100.arm.linux.org.uk>
	 <20150911164937.GW21084@n2100.arm.linux.org.uk>
	 <20150917135705.GQ21084@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Russell,

On Thu, 2015-09-17 at 14:57 +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux
> wrote:
> > Following that idea, I just tried the patch below, and it seems to
> > work.
> > I don't know whether it handles all cases after a call to
> > kernel_connect(),
> > but it stops the multiple connection attempts:
> > 
> >   1   0.000000 armada388 -> n2100 TCP 1009→nfs [SYN] Seq=3794066539
> > Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=15712 TSecr=870317691
> > WS=128
> >   2   0.000414 n2100 -> armada388 TCP nfs→1009 [SYN, ACK]
> > Seq=1884476522 Ack=3794066540 Win=28560 Len=0 MSS=1440 SACK_PERM=1
> > TSval=870318939 TSecr=15712 WS=64
> >   3   0.000787 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066540
> > Ack=1884476523 Win=28672 Len=0 TSval=15712 TSecr=870318939
> >   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0x905379cc, [Check: RD LU MD XT DL]
> >   5   0.001566 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
> > Ack=3794066660 Win=28608 Len=0 TSval=870318939 TSecr=15712
> >   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0x905379cc, [Check: RD LU MD XT DL]
> >   7   0.001866 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
> > Ack=3794066780 Win=28608 Len=0 TSval=870318939 TSecr=15712
> >   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4),
> > [Allowed: RD LU MD XT DL]
> >   9   0.003415 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066780
> > Ack=1884476647 Win=28672 Len=0 TSval=15712 TSecr=870318939
> >  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0xe15fc9c9, [Check: RD LU MD XT DL]
> >  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6),
> > [Allowed: RD LU MD XT DL]
> >  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0xe15fc9c9, [Check: RD LU MD XT DL]
> >  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10),
> > [Allowed: RD LU MD XT DL]
> >  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH:
> > 0xe15fc9c9
> > ...
> 
> NFS people - any comments on this patch?  Is it the correct way to
> solve
> this problem (please see the first message in this thread for the
> problem.)
> Without this patch, NFS is unusable as it tries to launch multiple
> new
> connections from the same port to the NFS server without giving the
> NFS
> server time to respond and establish the TCP connection.

I agree that it addresses a real problem here, however there are a
couple of issues with the patch itself:

AFAICS, the 2 possible next states for SYN_SENT are TCP_ESTABLISHED and
TCP_CLOSE, so if the connection attempt fails, this patch leaves the
XPRT_CONNECTING flag set.
There is also the issue that clearing XPRT_CONNECTING in TCP_FIN_WAIT1,
TCP_CLOSE_WAIT and TCP_CLOSING could interfere with another connection
attempt by canceling the XPRT_CONNECTING state.

How about the following? It is based on your patch, but adds a check to
ensure that xs_tcp_state_change() doesn't clear the 'connecting' state
more than once (which could otherwise still happen in the TCP_CLOSE
case).

8<-------------------------------------------------------------------
