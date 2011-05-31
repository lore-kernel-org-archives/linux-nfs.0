Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:60379 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201Ab1EaRa0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 13:30:26 -0400
Message-ID: <4DE525AE.9030806@itwm.fraunhofer.de>
Date: Tue, 31 May 2011 19:30:22 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org> <4DE521B9.5050603@panasas.com>
In-Reply-To: <4DE521B9.5050603@panasas.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/31/2011 07:13 PM, Boaz Harrosh wrote:
> On 05/31/2011 03:35 PM, Ted Ts'o wrote:
>> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
>>>
>>> Out of interest, did anyone ever benchmark if dirindex provides any
>>> advantages to readdir?  And did those benchmarks include the
>>> disadvantages of the present implementation (non-linear inode
>>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
>>> 'rm -fr $dir')?
>>
>> The problem is that seekdir/telldir is terminally broken (and so is
>> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
>> a linear data structure.  If you're going to use any kind of
>> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
>> doesn't cut it.  We actually play games where we memoize the low
>> 32-bits of the hash and keep track of which cookies we hand out via
>> seekdir/telldir so that things mostly work --- except for NFSv2, where
>> with the 32-bit cookie, you're just hosed.
>>
>> The reason why we have to iterate over the directory in hash tree
>> order is because if we have a leaf node split, half the directories
>> entries get copied to another directory entry, given the promises made
>> by seekdir() and telldir() about directory entries appearing exactly
>> once during a readdir() stream, even if you hold the fd open for weeks
>> or days, mean that you really have to iterate over things in hash
>> order.
>
> open fd means that it does not survive a server reboot. Why don't you
> keep an array per open fd, and hand out the array index. In the array
> you can keep a pointer to any info you want to keep. (that's the meaning of
> a cookie)

An array can take lots of memory for a large directory, of course. Do we 
really want to do that in kernel space? Although I wouldn't have a 
problem to reserve a certain amount of memory for that. But what do we 
do if that gets exhausted (for example directory too large or several 
open filedescriptors)?
And how does that help with NFS and other cluster filesystems where the 
client passes over the cookie? We ignore posix compliance then?

Thanks,
Bernd
