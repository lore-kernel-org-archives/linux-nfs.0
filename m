Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:40933 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbIKNUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 09:20:38 -0400
Date: Fri, 11 Sep 2015 14:18:18 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Message-ID: <20150911131818.GP21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 06:04:51AM -0700, Eric Dumazet wrote:
> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> > I have a recent Marvell Armada 388 board here which uses the mvneta
> > driver.  I'm seeing some weird effects with NFS with it acting as a
> > client.  Unfortunately, the board does not have a functional RTC.
> > 
> > The NFS server is the same NFS server that I've used for years with
> > multiple other clients (it's my main NFS server) and it continues to
> > support all other clients without any ill effect.  The NFS server
> > kernel is rather old now, being a 3.x kernel.
> > 
> > The NFS client appears to connect using TCP/IPv6 and initially is
> > accessible.  Everything appears to work normally, and then the NFS
> > server appears to stop responding.
> > 
> > Running tcpdump on the NFS server, and then dumping the captured
> > packets
> > with tshark (because tcpdump appears not to understand IPv6 SYNs on
> > the
> > NFS port) shows:
> > 
> >   3   0.030036 armada388 -> n2100 TCP 843→nfs [SYN] Seq=936803106
> > Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892366 TSecr=0 WS=128
> 
> >   4   0.030409 n2100 -> armada388 TCP nfs→843 [SYN, ACK] Seq=409465870
> > Ack=936803107 Win=28560 Len=0 MSS=1440 SACK_PERM=1
> >  TSval=818169117 TSecr=892366 WS=64
> 
> >   5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused]
> > 843→nfs [SYN] Seq=936803633 Win=28800 Len=0 MSS=1440 SACK_PERM=1
> > TSval=892366 TSecr=0 WS=128
> 
> Yes, this packet looks very wrong. Like two simultaneous connect with
> same source port. It is not a retransmit (Seq numbers differ)
> 
> >   6   0.030699 n2100 -> armada388 TCP nfs→843 [RST, ACK] Seq=0
> > Ack=936803634 Win=0 Len=0
> >   7   0.030766 armada388 -> n2100 TCP 843→nfs [RST] Seq=936803107
> > Win=0 Len=0
> 
> I suspect port reuse in NFS being broken.
> 
> Have you tried to apply

Thanks, I'll give this a go and report back.

I've been trying to debug this unsuccessfully.  It's really not helpful
to enable rpc debugging, and then be greeted with this from printk:

[ 2760.156924] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
[ 2760.163218] RPC:       xs_tcp_state_change client ee240800...
[ 2760.168976] RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.175273] RPC:       xs_tcp_state_change client ee240800...
[ 2760.181032] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.187315] RPC:       disconnected transport ee240800
[ 2760.192467] RPC:       xs_tcp_state_change client ee240800...
[ 2760.198224] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.204505] RPC:       disconnected transport ee240800
[ 2760.209653] RPC:       xs_tcp_data_ready...
[ 2760.215001] RPC:       wake_up_first(ee240918 "xprt_sending")
lspci -vvx |less
[ 2805.912330] RPC:       looking up Generic cred
[ 2805.916791] RPC:       looking up Generic cred
[ 2805.921259] RPC:       looking up Generic cred
[ 2805.921784] RPC:       looking up Generic cred
[ 2805.921787] RPC:       looking up Generic cred
[ 2805.921788] RPC:       looking up Generic cred
[ 2805.921792] RPC:       new task initialized, procpid 327
[ 2805.921794] RPC:       allocated task ee358300
[ 2805.921797] RPC:  1335 __rpc_execute flags=0x80
[ 2805.921800] RPC:  1335 call_start nfs3 proc ACCESS (sync)
[ 2805.921801] RPC:  1335 call_reserve (status 0)
[ 2805.921805] RPC:  1335 reserved req ee8a2900 xid af74741b
** 168 printk messages dropped ** [ 2805.928207] RPC:       read reply XID b174741b
** 366 printk messages dropped ** [ 2805.941242] RPC:  1343 setting alarm for 60000 ms
** 310 printk messages dropped ** [ 2805.958274] RPC:       xprt = ee240800, tcp_copied = 120, tcp_offset = 120, tcp_reclen = 120
** 89 printk messages dropped ** [ 2805.959613] RPC:  1350 reserved req ee8a2900 xid be74741b
[ 2805.959614] RPC:       wake_up_first(ee240918 "xprt_sending")

which is just where we want to see the printk messages.  This kind'a
makes printk and the rpc debug stuff rather useless. :(

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
