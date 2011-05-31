Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:59965 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab1EaKdZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 06:33:25 -0400
Message-ID: <4DE4C063.9060100@itwm.fraunhofer.de>
Date: Tue, 31 May 2011 12:18:11 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de>
In-Reply-To: <201105311147.24939.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/31/2011 11:47 AM, Rüdiger Meier wrote:
> On Monday 30 May 2011, Trond Myklebust wrote:
>> On Mon, 2011-05-30 at 11:37 +0200, Ruediger Meier wrote:
>>>
>>> Does this mean ext4 generally does not work with for nfs?
>>
>> ext2/3/4 are all known to have this problem when you switch on the
>> hashed b-tree directories. Typically, a directory with a million
>> entries will have several tens of cookie collisions.
>
> Ok, like Jeff mentioned in the other reply disabling dir_index solves
> it.
>
> I wish I had seen this documented somewhere before switching from xfs to
> ext4 but it's not easy to find something about these ext4/nfs probs
> without knowing the details already.
> Ext4 being default file system on many distros made me feel safe.

Well, this is hardly acceptable and we really need to find a solution. I 
think any parallel filesystem and fuse, etc will have problems with that.

Out of interest, did anyone ever benchmark if dirindex provides any 
advantages to readdir?  And did those benchmarks include the 
disadvantages of the present implementation (non-linear inode numbers 
from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
'rm -fr $dir')?


I see those options to solve the ext3/ext4 seek problem:

1) Break 32bit applications on 64 bit kernels

2) Update the vfs to tell the underlying functions to tell them if 
lseek() was called from 64bit or 32bit userspace

3) Disable dirindexing for readdirs


Thanks,
Bernd

