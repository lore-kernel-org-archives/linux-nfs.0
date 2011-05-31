Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48785 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574Ab1EaRNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 13:13:39 -0400
Message-ID: <4DE521B9.5050603@panasas.com>
Date: Tue, 31 May 2011 20:13:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Ted Ts'o" <tytso@mit.edu>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org>
In-Reply-To: <20110531123518.GB4215@thunk.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/31/2011 03:35 PM, Ted Ts'o wrote:
> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
>>
>> Out of interest, did anyone ever benchmark if dirindex provides any
>> advantages to readdir?  And did those benchmarks include the
>> disadvantages of the present implementation (non-linear inode
>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
>> 'rm -fr $dir')?
> 
> The problem is that seekdir/telldir is terminally broken (and so is
> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
> a linear data structure.  If you're going to use any kind of
> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
> doesn't cut it.  We actually play games where we memoize the low
> 32-bits of the hash and keep track of which cookies we hand out via
> seekdir/telldir so that things mostly work --- except for NFSv2, where
> with the 32-bit cookie, you're just hosed.
> 
> The reason why we have to iterate over the directory in hash tree
> order is because if we have a leaf node split, half the directories
> entries get copied to another directory entry, given the promises made
> by seekdir() and telldir() about directory entries appearing exactly
> once during a readdir() stream, even if you hold the fd open for weeks
> or days, mean that you really have to iterate over things in hash
> order.

open fd means that it does not survive a server reboot. Why don't you
keep an array per open fd, and hand out the array index. In the array
you can keep a pointer to any info you want to keep. (that's the meaning of
a cookie)

> 
> I'd have to look, since it's been too many years, but as I recall the
> problem was that there is a common path for NFSv2 and NFSv3/v4, so we
> don't know whether we can hand back a 32-bit cookie or a 64-bit
> cookie, so we're always handing the NFS server a 32-bit "offset", even
> though ew could do better.  

Please fix that. In the 64-bit case of NFSv3/v4 you can give out a pointer
instead of array-index. In NFSv2 on 64bit arches you are stuck with an index

> Actually, if we had an interface where we
> could give you a 128-bit "offset" into the directory, we could
> probably eliminate the duplicate cookie problem entirely.  We just
> send 64-bits worth of hash, plus the first two bytes of the of file
> name.
> 

If you hand out a pointer or index per fd, you could keep in memory
any info you want, as big as you need it.

>> 3) Disable dirindexing for readdirs
> 
> That won't work, since it will break POSIX compliance.  Once again,
> we're tied by the decisions made decades ago...
> 
> 						- Ted

Thanks
Boaz
