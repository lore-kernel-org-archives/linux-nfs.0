Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35641 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbbIQWDv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 18:03:51 -0400
Received: by oiww128 with SMTP id w128so17397251oiw.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 15:03:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1509171224520.17945@planck.local>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	<1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150911143347.GQ21084@n2100.arm.linux.org.uk>
	<20150911150613.GR21084@n2100.arm.linux.org.uk>
	<1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150911162416.GV21084@n2100.arm.linux.org.uk>
	<20150911164937.GW21084@n2100.arm.linux.org.uk>
	<20150917135705.GQ21084@n2100.arm.linux.org.uk>
	<1442499509.2865.16.camel@primarydata.com>
	<alpine.OSX.2.19.9992.1509171224520.17945@planck.local>
Date: Thu, 17 Sep 2015 18:03:50 -0400
Message-ID: <CAHQdGtS3YHy6_sEhYn=3Tgzdi4WMranoyRirfY+vN_srGDC0wg@mail.gmail.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        AnnaSchumaker <anna.schumaker@netapp.com>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux ARM Kernel Mailing List
	<linux-arm-kernel@lists.infradead.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 17, 2015 at 12:27 PM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Thu, 17 Sep 2015, Trond Myklebust wrote:
>
>> Hi Russell,
>>
>> On Thu, 2015-09-17 at 14:57 +0100, Russell King - ARM Linux wrote:
>> > On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux
>> > wrote:
>> > > Following that idea, I just tried the patch below, and it seems to
>> > > work.
>> > > I don't know whether it handles all cases after a call to
>> > > kernel_connect(),
>> > > but it stops the multiple connection attempts:
>> > >
>> > >   1   0.000000 armada388 -> n2100 TCP 1009→nfs [SYN] Seq=3794066539
>> > > Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=15712 TSecr=870317691
>> > > WS=128
>> > >   2   0.000414 n2100 -> armada388 TCP nfs→1009 [SYN, ACK]
>> > > Seq=1884476522 Ack=3794066540 Win=28560 Len=0 MSS=1440 SACK_PERM=1
>> > > TSval=870318939 TSecr=15712 WS=64
>> > >   3   0.000787 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066540
>> > > Ack=1884476523 Win=28672 Len=0 TSval=15712 TSecr=870318939
>> > >   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0x905379cc, [Check: RD LU MD XT DL]
>> > >   5   0.001566 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
>> > > Ack=3794066660 Win=28608 Len=0 TSval=870318939 TSecr=15712
>> > >   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0x905379cc, [Check: RD LU MD XT DL]
>> > >   7   0.001866 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
>> > > Ack=3794066780 Win=28608 Len=0 TSval=870318939 TSecr=15712
>> > >   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4),
>> > > [Allowed: RD LU MD XT DL]
>> > >   9   0.003415 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066780
>> > > Ack=1884476647 Win=28672 Len=0 TSval=15712 TSecr=870318939
>> > >  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
>> > >  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6),
>> > > [Allowed: RD LU MD XT DL]
>> > >  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
>> > >  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10),
>> > > [Allowed: RD LU MD XT DL]
>> > >  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH:
>> > > 0xe15fc9c9
>> > > ...
>> >
>> > NFS people - any comments on this patch?  Is it the correct way to
>> > solve
>> > this problem (please see the first message in this thread for the
>> > problem.)
>> > Without this patch, NFS is unusable as it tries to launch multiple
>> > new
>> > connections from the same port to the NFS server without giving the
>> > NFS
>> > server time to respond and establish the TCP connection.
>>
>> I agree that it addresses a real problem here, however there are a
>> couple of issues with the patch itself:
>>
>> AFAICS, the 2 possible next states for SYN_SENT are TCP_ESTABLISHED and
>> TCP_CLOSE, so if the connection attempt fails, this patch leaves the
>> XPRT_CONNECTING flag set.
>> There is also the issue that clearing XPRT_CONNECTING in TCP_FIN_WAIT1,
>> TCP_CLOSE_WAIT and TCP_CLOSING could interfere with another connection
>> attempt by canceling the XPRT_CONNECTING state.
>>
>> How about the following? It is based on your patch, but adds a check to
>> ensure that xs_tcp_state_change() doesn't clear the 'connecting' state
>> more than once (which could otherwise still happen in the TCP_CLOSE
>> case).
>>
>> 8<-------------------------------------------------------------------
>> From 4dbfdebbc09982a9248866f8256549456e2b2efd Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>> Date: Wed, 16 Sep 2015 23:43:17 -0400
>> Subject: [PATCH] SUNRPC: Ensure that we wait for connections to complete
>>  before retrying
>>
>> Commit 718ba5b87343, moved the responsibility for unlocking the socket to
>> xs_tcp_setup_socket, meaning that the socket will be unlocked before we
>> know that it has finished trying to connect. The following patch is based on
>> an initial patch by Russell King to ensure that we delay clearing the
>> XPRT_SOCK_CONNECTING flag until we either know that we failed to initiate
>> a connection attempt, or the connection attempt itself failed.
>>
>> Fixes: 718ba5b87343 ("SUNRPC: Add helpers to prevent socket create from racing")
>> Reported-by: Russell King <linux@arm.linux.org.uk>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>
> This fixes up my network segmentation problem, tested on top of your "Fix
> races between socket connection and destroy code".
>
> Tested-by: Benjamin Coddington <bcodding@redhat.com>
>

Thanks Ben!
