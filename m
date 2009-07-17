Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42808 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757929AbZGQWvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2009 18:51:31 -0400
Subject: Re: [2.6.30.1] Significant latency playing video file from NFS4
 share
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Frans Pop <elendil@planet.nl>
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
In-Reply-To: <200907172250.51504.elendil@planet.nl>
References: <200907172250.51504.elendil@planet.nl>
Content-Type: text/plain
Date: Fri, 17 Jul 2009 18:51:26 -0400
Message-Id: <1247871086.4945.38.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-07-17 at 22:50 +0200, Frans Pop wrote:
> While playing a video (avi) file from an nfs4 share using vlc I'm getting 
> significant latencies on the client resulting in video skips every 10-30 
> seconds. latencytop gives me for example:
> 
> Cause                                      Maximum     Percentage
> rpc_wait_bit_killable __rpc_execute
>    rpc_execute rp[...]                 2638.5 msec         46.1 %
> Scheduler: waiting for cpu               25.1 msec         19.9 %
> Waiting for event (select)                5.0 msec         23.0 %
> Waiting for event (poll)                  4.8 msec          0.3 %
> Userspace lock contention                 4.6 msec          9.9 %
> Waiting for data on unix socket           1.7 msec          0.8 %
> 
> Process vlc (6681)              Total: 2790.2 msec
> rpc_wait_bit_killable __rpc_execute
>    rpc_execute rp[...]                 2638.5 msec         94.6 % [1]
> Scheduler: waiting for cpu                9.3 msec          1.5 %
> Waiting for event (poll)                  4.8 msec          0.6 %
> Userspace lock contention                 4.3 msec          3.3 %
> Waiting for event (select)                0.6 msec          0.1 %
> 
> [1] nfs4_proc_getattr nfs4_proc_getattr __nfs_revalidate_inode nfs_getattr 
> vfs_geta[...]
> 
> There is no other NFS access going on at the time; just reading the single 
> file. No significant other processes running on either the client or the 
> server. latencytop on the server does not show any significant latencies.
> 
> Both server and client are dual core x86_64 running 2.6.30.1 with 
> identical configs (attached); Debian stable.
> 
> From /etc/exports on the server:
> /srv/exports            10.19.66.0/24(rw,fsid=0,subtree_check,sync)
> /srv/exports/myshare    10.19.66.0/24(rw,subtree_check,sync,mp,nohide)
> 
> mount on the client:
> elrond:/myshare on /srv/<mountpoint> type nfs4 (rw,addr=10.19.66.2)
> 
> Cheers,
> FJP

Have you tried running nfs-iostat from the nfs-utils package to try and
figure out what the latency is on each READ request from the client?

http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob_plain;f=tools/nfs-iostat/nfs-iostat.py;hb=HEAD

You need to run something like

    nfs-iostat --page 20 10 /src/<mountpoint>

while running the vlc app.

Trond

