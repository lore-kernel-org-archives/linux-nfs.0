Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab3FRRZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jun 2013 13:25:39 -0400
Date: Tue, 18 Jun 2013 13:25:30 -0400
To: mcr@sandelman.ca
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: big send queues on NFS server
Message-ID: <20130618172530.GB9915@fieldses.org>
References: <9160.1371563311@sandelman.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9160.1371563311@sandelman.ca>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 18, 2013 at 09:48:31AM -0400, mcr@sandelman.ca wrote:
> 
> Hi, I have been an NFS user and enthusiast for 20+ years.
> My home systems still have the numerical uid that doe.carleton.ca
> assigned me back in 1989... cause of NFS...  Recently, I turned off
> a NetBSD 5 machine that was my NFS server, and everything is on a
> Linux/Ubuntu server, LVM+raid setup.  
> 
> I have a slightly interesting setup at my home.  A VM with a public IP
> (cassidy) address runs a custom web server on port 81 to stream mp3/ogg to
> whatever device needs it.  My music skips/pauses.  Some of this was traced
> down to bufferbloat issues when I was listening from work.  But, it's
> happening at my home desk, connected by Gb/E.  An issue with an IPv6 RA
> server was ruled out. 
> 
> To be clear:
>    desktop(obiwan)---IPv4:81---->server(cassidy)---NFSv4-IPv6-->herring
> 
> I am running a tmux ("screen") on NFS server, with one pane being:
>   watch 'ss -tan | grep 2049'
> 
> And in the other, initially, I was running:
>   sudo tcpdump -i eth0 -n -p ether host ETHERNETOFCASSIDY
> 
> as that was very busy, I ran instead:
> sudo tcpdump -i eth0 -n -p ether host 00:16:3e:11:22:e4 and \   
>      '(tcp[13] & 2!=0     or ip6[53]&2 !=0)'
> 
> and each time the music stops I see huge xmit queues on the NFS server,
> 
> ESTAB      0      789156   2607:dead:f:2::231:2049 2607:dead:f:2:216:3eff:fe11:22e4:868
> 
> *usually* that then results in a TCP restart:
> 
> 09:40:12.701402 IP6 2607:dead:f:2:216:3eff:fe11:22e4.868 >
> 2607:dead:f:2::231.2049: Flags [S], seq 2570499549, win 5712, options [mss
> 1440,sackOK,TS val 2994659072 ecr 1552097470,nop,wscale 2], length 0
> 
> 09:40:12.701456 IP6 2607:dead:f:2::231.2049 >
> 2607:dead:f:2:216:3eff:fe11:22e4.868: Flags [S.], seq 707413120, ack
> 2570499550, win 14280, options [mss 1440,sackOK,TS val 1552097470 ecr
> 2994659072,nop,wscale 7], length 0
> 
> I notice that it always seem to use the same source port number.
> I didn't think that this was allowed until after 2*RTT.
> 
> What seems to be occuring to me is some kind of head of queue problem in the
> TCP stream.  I would be happy to install experimental kernels, instrument
> stuff, whatever..., particularly on the NFS client, as it's not a critical
> machine.  If I need to do something on the NFS server, it will possible. 
> I will shortly update the kernel the debian backports on the client.
> 
> I watch and I regularly see large (+1M) send queues on the server:
> 
> ESTAB      0      1434080   2607:dead:f:2::231:2049 2607:dead:f:2:216:3eff:fe11:22e4:868
> 
> If they decline in time, there is no interruption, otherwise, the web server
> gets an underrun, and the music stops.    
> 
> I could also capture the entire NFS stream, or just do TCP window analysis on
> this stream, but I would suspect that it's a problem on the client.

Could be, though it sounds like all you changed here was replacing the
NetBSD server by a Linux server?

Of course, that's a rather complicated change in itself (default NFS
version, transport (tcp vs udp), etc. may have changed as well.

Might be worth fooling with those parameters using mount options.  The
defaults should be best, but it might help narrow down the problem.

--b.

> 
> NFS server:
> herring-[~] mcr 1001 %uname -a
> Linux herring 3.2.0-39-generic #62-Ubuntu SMP Thu Feb 28 00:28:53 UTC 2013
> x86_64 x86_64 x86_64 GNU/Linux
> 
> NFS client:
> cassidy-[~] mcr 1010 %uname -a
> Linux cassidy.sandelman.ca 2.6.32-5-xen-686 #1 SMP Wed May 18 09:43:15 UTC
> 2011 i686 GNU/Linux
> 
> 
> 
> 
>   


