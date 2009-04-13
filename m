Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr3.xs4all.nl ([194.109.24.23]:1558 "EHLO
	smtp-vbr3.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbZDMQbG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 12:31:06 -0400
Subject: Re: Unexplained NFS mount hangs
From: Rudy Zijlstra <rudy@grumpydevil.homelinux.org>
Reply-To: Rudy@grumpydevil.homelinux.org
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Daniel Stickney <dstickney@pronto.com>, linux-nfs@vger.kernel.org
In-Reply-To: <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
References: <20090413092406.304d04fb@dstickney2>
	 <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
Content-Type: text/plain
Date: Mon, 13 Apr 2009 18:18:57 +0200
Message-Id: <1239639537.13583.41.camel@poledra.romunt.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Op maandag 13-04-2009 om 12:12 uur [tijdzone -0400], schreef Chuck
Lever:
> On Apr 13, 2009, at 11:24 AM, Daniel Stickney wrote:
> > Hi all,
> >
> > I am investigating some NFS mount hangs that we have started to see  
> > over the past month on some of our servers. The behavior is that the  
> > client mount hangs and needs to be manually unmounted (forcefully  
> > with 'umount -f') and remounted to make it work. There are about 85  
> > clients mounting a partition over NFS. About 50 of the clients are  
> > running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of  
> > these 50 has ever had this mount hang. The other 35 are CentOS 5.2  
> > with kernel 2.6.27 which was compiled from source. The mount hangs  
> > are inconsistent and so far I don't know how to trigger them on  
> > demand. The timing of the hangs as noted by the timestamp in /var/ 
> > log/messages varies. Not all of the 35 CentOS clients have their  
> > mounts hang at the same time, and the NFS server continues operating  
> > apparently normally for all other clients. Normally maybe 5 clients  
> > have a mount hang per week, on different days, mostly different  
> > times. Now and then we might see a cluster of a few clien
> > ts have their mounts hang at the same exact time, but this is not  
> > consistent. In /var/log/messages we see
> >
> > Apr 12 02:04:12 worker120 kernel: nfs: server broker101 not  
> > responding, still trying
> 
> Are these NFS/UDP or NFS/TCP mounts?
> 
> If you use a different kernel (say, 2.6.26) on the CentOS systems, do  
> the hangs go away?
> 

Hi Chuck,

In my case NFS/TCP.

I have tried most 2.6.2x kernels, it may take a week or longer for them
to hang, but hang they do :(

have been fighting with this one since at least 2.6.24, and probably
2.6.22

The reader that was hanging last week, is running 2.6.26

Rudy

