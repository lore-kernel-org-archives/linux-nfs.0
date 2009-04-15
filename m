Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:29494 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbZDOO3T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 10:29:19 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <1D9458F7-0AED-478B-BFF6-A612B04FBE2A@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Simon Kirby <sim@hostway.ca>
In-Reply-To: <20090415004809.GC17195@hostway.ca>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Write on close behaviour versus slow media and slow network
Date: Wed, 15 Apr 2009 10:29:06 -0400
References: <20090415004809.GC17195@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Apr 14, 2009, at 8:48 PM, Simon Kirby wrote:
> Hello!
>
> I have a usual process of downloading pictures from a flash card (@ 15
> MB/s or so) and writing them over 100 Mbps Ethernet (@ 12 MB/s or so).
> One would expect and hope that both the reading and writing could  
> happen
> simultaneously to optimize throughput, but the current behaviour on  
> both
> NFSv3 and NFSv4 is as follows:
>
> multiple files loop (copying with "cp"):
> 	open source, dest
> 	data copy loop:
> 		read(source)
> 		write(dest)
> 	close(source)
> 	close(dest)
>
> The inner loop happens at about the rate of the flash card reader  
> all the
> way up to my picture size (12-25 MB).  Then, on close(), rpciod /  
> the NFS
> client flushes all data over the network, at the rate which the  
> network
> can sustain.
>
> Overall throughput is therefore about 1/(1/12+1/15) == 6.67 MB/s,  
> which
> is not very exciting.
>
> I find that replacing "cp" with "dd ... bs=131072 oflag=dsync" lets me
> copy at near network speed, at the expense of slowing down copying  
> to a
> local hard drive should I chose to do that instead, and seems to be  
> more
> of a workaround than a solution (and it's very sensitive to block size
> and still slower than network speed).
>
> Is there any way to convince NFS (or buffer flushing) to start  
> sooner in
> this case -- preferrably when there are at least wsize bytes  
> available to
> write?  Is there any downside to doing this?

VM/VFS and NFS client both delay writes aggressively.  A page cache  
flush is forced by the close(2) call, but the client will hold onto  
dirty data until the last possible moment.  It's kind of a system-wide  
policy, and yes, we know it's not so good for NFS.

There are some VM sysctls that can tune down the maximum amount of  
dirty writes allowed to be outstanding.  Have a look at /proc/sys/vm/ 
dirty_ratio and /proc/sys/vm/dirty_background_ratio.  The problem with  
these is that a) they are system wide, so the settings affect all of  
your file systems, and 2) it's a ratio, so I don't think you can tune  
it to flush files smaller than 1% of your system's physical RAM.  On a  
system with one gigabyte, that means you are still caching about 10MB  
before starting to flush.  I'm guessing your flash files are smaller  
than that.

Another solution is to change your application.  Calling  
sync_file_range(2) in asynchronous mode every so often in your loop  
might be sufficient to kick the VM into flushing the data sooner.

> Other than some special-case handling with deleting a temporary file
> before closing it (does that even work?), I don't see how the current
> behaviour helps performance in _any_ case, even when copying from fast
> media.
>
> I looked around the NFS man pages, /proc and /sys and didn't see  
> anything
> that might be helpful, but I am interested to find out how things  
> came to
> arrive at this implementation.
>
> Cheers!
>
> Simon-
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




