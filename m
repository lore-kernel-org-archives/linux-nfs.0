From: Alex Riesen <alexander.riesen@synopsys.COM>
Subject: Re: NFS root: New error messages in latest bk
Date: Tue, 27 May 2003 14:34:53 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030527123453.GU32559@Synopsys.COM>
References: <3E47D057.4070205@walrond.org>
Reply-To: alexander.riesen@synopsys.COM
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <3E47D057.4070205@walrond.org>
List-ID: <nfs.lists.sourceforge.net>

Andrew Walrond, Mon, Feb 10, 2003 17:16:23 +0100:
> Latest bk 2.5;

2.5.70 here

> Just booted with NFS root and noticed these new error messages in dmesg:
> 
> NFS: server cheating in read reply: count 4096 > recvd 1000
> NFS: giant filename in readdir (len 0xcb2d2053)!
> 

I have almost the same, but without the "server cheating":

16:12:06 NFS: giant filename in readdir (len c8f2d9f0)!

got this by doing "find /mnt -type f | xargs cat > /dev/null".
The server is 2.4.20-ck4 (Con Kolivas patches: aavm, preempt, lolatency).

Also seen something about 7 min later (the find was still running):

16:19:22 nfs: server server1 not responding, still trying
16:19:25 nfs: server server1 OK

The "server1" (my desktop machine) was doing almost nothing at this time
and felt ok (still does).

-alex
