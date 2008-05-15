From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 17:08:47 +0100
Message-ID: <482C600F.3040909@moving-picture.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>	 <20080515084610.4e5161bc@tupile.poochiereds.net> <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Adam Olsen <arolsen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:60813 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750939AbYEOQfp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 12:35:45 -0400
In-Reply-To: <2473b43f0805150855o59a14e34h82b20f847c53f392-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adam Olsen wrote:
> On Thu, May 15, 2008 at 9:46 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
>> It really depends on the program, but I'd guess that it saw something
>> in the fstat64() call that it didn't like. You might want to use strace
>> with '-v -s 256' or something and look for differences in the info
>> returned by the fstat64 call.
> 
> 
> With the working kernel:
> 
> access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
> open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
> fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
> fstat64(3, {st_dev=makedev(0, 25), st_ino=4634215,
> st_mode=S_IFREG|0666, st_nlink=1, st_uid=1001, st_gid=100,
> st_blksize=32768, st_blocks=194, st_size=48784,
> st_atime=2008/05/14-11:46:53, st_mtime=2008/05/14-11:46:53,
> st_ctime=2008/05/14-21:12:18}) = 0
> mmap2(NULL, 48784, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7a07000
> close(3)
> 
> With the *non* working kernel:
> 
> access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
> open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
> fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
> fstat64(3, {st_dev=makedev(0, 23), st_ino=4299601510,
> st_mode=S_IFREG|0666, st_nlink=1, st_uid=1001, st_gid=100,
> st_blksize=32768, st_blocks=194, st_size=48784,
> st_atime=2008/05/14-11:46:53, st_mtime=2008/05/14-11:46:53,
> st_ctime=2008/05/14-21:12:18}) = 0
> close(3)                                = 0
> 
> Still looks almost identical, except the missing mmap2 in the
> non-working kernel.  Also, the st_ino is different... should they be
> the same?

Is this a 32 bit app running on a 64 OS by any chance?

James Pearson

