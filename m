Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr6.xs4all.nl ([194.109.24.26]:3270 "EHLO
	smtp-vbr6.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbZDMQQT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 12:16:19 -0400
Subject: Re: Unexplained NFS mount hangs
From: Rudy Zijlstra <rudy@grumpydevil.homelinux.org>
Reply-To: Rudy@grumpydevil.homelinux.org
To: Daniel Stickney <dstickney@pronto.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090413092406.304d04fb@dstickney2>
References: <20090413092406.304d04fb@dstickney2>
Content-Type: text/plain
Date: Mon, 13 Apr 2009 18:15:25 +0200
Message-Id: <1239639325.13583.38.camel@poledra.romunt.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Daniel,

Op maandag 13-04-2009 om 09:24 uur [tijdzone -0600], schreef Daniel
Stickney:
> Hi all,
> 
> I am investigating some NFS mount hangs that we have started to see over the past month on some of our servers. The behavior is that the client mount hangs and needs to be manually unmounted (forcefully with 'umount -f') and remounted to make it work. There are about 85 clients mounting a partition over NFS. About 50 of the clients are running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of these 50 has ever had this mount hang. The other 35 are CentOS 5.2 with kernel 2.6.27 which was compiled from source. The mount hangs are inconsistent and so far I don't know how to trigger them on demand. The timing of the hangs as noted by the timestamp in /var/log/messages varies. Not all of the 35 CentOS clients have their mounts hang at the same time, and the NFS server continues operating apparently normally for all other clients. Normally maybe 5 clients have a mount hang per week, on different days, mostly different times. Now and then we might see a cluster of a few cl!
 ien
>  ts have their mounts hang at the same exact time, but this is not consistent. In /var/log/messages we see
> 
> Apr 12 02:04:12 worker120 kernel: nfs: server broker101 not responding, still trying
> 
> One very interesting aspect of this behavior is that the load value on the client with the hung mount immediately spikes to (16.00)+(normal load value). We have also seen client load spikes to (30.00)+(normal load value). These discrete load value increases might be a good hint.
> 
> Running 'df' prints some output and then hangs when it reaches the hung mount point. 'mount -v' shows the mount point like normal. When an NFS server is rebooted, we are used to seeing the client log a "nfs: server ___________ not responding, still trying", then a "nfs: server __________ OK" message when it comes back online. With this issue there is never an "OK" message even though the NFS server is still functioning for all other NFS clients. On a client which has a hung NFS mount, running 'rpcinfo -p' and 'showmount -e' against the NFS server shows that RPC and NFS appear to be functioning between client and server even during the issue.
> 

This matches very will with my own experience. 

For a long time i was thinking this was write related, but recently i
had a hang on a reading client. 

My application is streaming video, and i can have about 40Mbps hitting
the file server, while reading about 16Mbps at the same time

The reading clients only read, they do not write. Most of the hangs i
see are from the writers, and once now from a reader. 

I have tried several recent kernels, and never been able to find a
relation to the kernel on the file server. From my experiments, all
2.6.2x kernels are affected. I cannot reproduce at will though. It is
waiting till it happens. 

Thanks,


Rudy



