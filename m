Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:50648 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab3FRTdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 15:33:11 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: big send queues on NFS server
In-Reply-To: <20130618172530.GB9915@fieldses.org>
References: <9160.1371563311@sandelman.ca> <20130618172530.GB9915@fieldses.org>
Date: Tue, 18 Jun 2013 15:32:04 -0400
Message-ID: <15556.1371583924@sandelman.ca>
From: mcr@sandelman.ca
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, Jun 18, 2013 at 09:48:31AM -0400, mcr@sandelman.ca wrote:
    >> Hi, I have been an NFS user and enthusiast for 20+ years.  My home
    >> systems still have the numerical uid that doe.carleton.ca assigned me
    >> back in 1989... cause of NFS...  Recently, I turned off a NetBSD 5

...

    >> If they decline in time, there is no interruption, otherwise, the web
    >> server gets an underrun, and the music stops.
    >> 
    >> I could also capture the entire NFS stream, or just do TCP window
    >> analysis on this stream, but I would suspect that it's a problem on
    >> the client.

J. Bruce Fields <bfields@fieldses.org> wrote:
    jb> Could be, though it sounds like all you changed here was replacing
    jb> the NetBSD server by a Linux server?

well, I mentioned NetBSD to indicate the length of time I have used various
NFS systems, not because I felt that it was a specific interop issue.

    jb> Of course, that's a rather complicated change in itself (default NFS
    jb> version, transport (tcp vs udp), etc. may have changed as well.

    jb> Might be worth fooling with those parameters using mount options.
    jb> The defaults should be best, but it might help narrow down the
    jb> problem.

I am using mostly  default options: nosuid, nodev, hard.
Generally, I have solved problems in the past by going back to NFSv3 on UDP
mounts, and then doing the classic nfsd worker tuning dance, and the
rsize=/wsize= game.   

I am posting to understand if someone says, "oh, yes, you found issue 34534,
and it's a client side problem, and it's fixed in 3.7.2..."
or: "thats is weird.  What does /proc/nfs/magic_client_side_tunnable say?"
or: "I have that too"
or: "can you send a pcap?"

I would love: "that's a client problem" vs "that's a server problem",
and I'd go investigate deeper there :-)

-- 
]               Never tell me the odds!                 | ipv6 mesh networks [ 
]   Michael Richardson, Sandelman Software Works        | network architect  [ 
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [ 
	
