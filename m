Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23308 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab1FANKg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 09:10:36 -0400
Message-ID: <4DE63A42.4090102@panasas.com>
Date: Wed, 01 Jun 2011 16:10:26 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org> <4DE521B9.5050603@panasas.com> <4DE525AE.9030806@itwm.fraunhofer.de>
In-Reply-To: <4DE525AE.9030806@itwm.fraunhofer.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/31/2011 08:30 PM, Bernd Schubert wrote:
> On 05/31/2011 07:13 PM, Boaz Harrosh wrote:
>> On 05/31/2011 03:35 PM, Ted Ts'o wrote:
>>> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
>>>>
>>>> Out of interest, did anyone ever benchmark if dirindex provides any
>>>> advantages to readdir?  And did those benchmarks include the
>>>> disadvantages of the present implementation (non-linear inode
>>>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
>>>> 'rm -fr $dir')?
>>>
>>> The problem is that seekdir/telldir is terminally broken (and so is
>>> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
>>> a linear data structure.  If you're going to use any kind of
>>> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
>>> doesn't cut it.  We actually play games where we memoize the low
>>> 32-bits of the hash and keep track of which cookies we hand out via
>>> seekdir/telldir so that things mostly work --- except for NFSv2, where
>>> with the 32-bit cookie, you're just hosed.
>>>
>>> The reason why we have to iterate over the directory in hash tree
>>> order is because if we have a leaf node split, half the directories
>>> entries get copied to another directory entry, given the promises made
>>> by seekdir() and telldir() about directory entries appearing exactly
>>> once during a readdir() stream, even if you hold the fd open for weeks
>>> or days, mean that you really have to iterate over things in hash
>>> order.
>>
>> open fd means that it does not survive a server reboot. Why don't you
>> keep an array per open fd, and hand out the array index. In the array
>> you can keep a pointer to any info you want to keep. (that's the meaning of
>> a cookie)
> 
> An array can take lots of memory for a large directory, of course. Do we 
> really want to do that in kernel space? Although I wouldn't have a 
> problem to reserve a certain amount of memory for that. But what do we 
> do if that gets exhausted (for example directory too large or several 
> open filedescriptors)?

You miss understood me. Ted was complaining that the cookie was only 32
bit and he hoped it was bigger, perhaps 128 minimum. What I said is that
for each open fd, a cookie is returned that denotes a temporary space
allocated for just that caller. When a second call with the same fd, same
cookie comes, the allocated object is inspected to retrieve all the
information needed to continue the walk from the same place. So the allocated
space is only per active caller, up to the time fd is closed.
(I never meant per directory entry)

> And how does that help with NFS and other cluster filesystems where the 
> client passes over the cookie? We ignore posix compliance then?
> 

I was not referring to that. I understand that this is an hard problem
but it is solvable. The space per cookie is solved above.

> Thanks,
> Bernd

But this is all talk. I don't know enough, or use, ext4 to be able to solve
it myself. So I'm just babbling out here. Just that in the server we've done
it before to keep things in an internal array and return the index as a magic
cookie, when more information was needed internally.

Boaz
