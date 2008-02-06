From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 21:24:41 +0100
Message-ID: <47AA1789.2040007@krogh.cc>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>    <47A9C620.70106@oxeva.fr> <64226.195.41.66.226.1202313579.squirrel@mail.jabbernet.dk> <47AA12C5.4010807@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:43660 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661AbYBFUYv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 15:24:51 -0500
In-Reply-To: <47AA12C5.4010807-KSe8qvLY914@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gabriel Barazer wrote:
> On 02/06/2008 4:59:39 PM +0100, "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org> wrote:
> 
>>> I have a similar setup, and I'm very curious on how you can read an
>>> "iowait" value from the clients: On my nodes (server 2.6.21.5/clients
>>> 2.6.23.14), the iowait counter is only incremented when dealing with
>>> block devices, and since my nodes are diskless my iowait is near 0%.
>>
>> Output in top is like this:
>> top - 16:51:01 up 119 days,  6:10,  1 user,  load average: 2.09, 2.00, 
>> 1.41
>> Tasks:  74 total,   2 running,  72 sleeping,   0 stopped,   0 zombie
>> Cpu(s):  0.2%us,  0.0%sy,  0.0%ni, 50.0%id, 49.8%wa,  0.0%hi,  0.0%si, 
>> 0.0%st
>> Mem:   2060188k total,  2047488k used,    12700k free,     2988k buffers
>> Swap:  4200988k total,    42776k used,  4158212k free,  1985500k cached
> 
> You have obviously a block device on your nodes, so I suspect that 
> something is reading/writing to it. Looking at how much memory is used, 
> your system must be constantly swapping. This could explain why your 
> iowait is so high (if your swap space is a block device or a file on a 
> block device. You don't use swap over NFS do you?)

No swap over NFS and no swapping at all.

A "vmstat 1" output of the above situation looks like:
procs -----------memory---------- ---swap-- -----io---- -system-- 
----cpu----
  0  2  42768  11580   1368 1987336    0    0     0     0  638  366  1 
0 50 48
  0  2  42768  13088   1368 1985924    0    0     0     0  695  367  2 
1 50 47
  0  2  42768  13028   1368 1986112    0    0     0     0  345  129  0 
0 50 50
  1  1  42768  12720   1364 1986328    0    0     0     0 1043  710  6 
1 50 42
  0  1  42768  12648   1364 1987308    0    0     0     0  636  374  2 
4 50 44
  0  2  42768  11608   1364 1988436    0    0     0     0  696  382  1 
0 51 49

You can also see that there barely is used any swap in the "top" report.

Jesper
-- 
Jesper
