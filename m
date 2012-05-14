Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:11111 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757209Ab2ENR1o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 13:27:44 -0400
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120514152334.GB29902@fieldses.org>
Date: Mon, 14 May 2012 11:27:42 -0600
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-Id: <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
References: <20120514140618.GA29902@fieldses.org> <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca> <20120514152334.GB29902@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-14, at 9:23 AM, J. Bruce Fields wrote:
> On Mon, May 14, 2012 at 09:02:12AM -0600, Andreas Dilger wrote:
>> On 2012-05-14, at 8:06, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> knfsd needs i_version updates on, as will userspace nfs servers and
>>> probably others.
>>> 
>>> The only effects are that inode->i_version is bumped (under the i_lock)
>>> in more places, and that ->dirty_inode(I_DIRTY_DATASYNC) may be called
>>> more frequently than once per jiffy on write (see file_update_time).
>>> However the latter appears to be mostly a no-op in that case.
>> 
>> I thought this can have noticeable performance impact, since ext4_mark_inode_dirty() is quite heavyweight?
> 
> There's no reason it should be, should it, if we already just dirtied
> the inode a moment ago?

Ideally not, but the way ext[34]_mark_inode_dirty() is implemented
is that it copies the whole in-core inode to the on-disk inode every
time it is marked dirty.  That ensures that the on-disk inode is
up-to-date when the journal flushes the blocks to disk, but is not
an ideal implementation.  It has been this way since the first ext3
implementation was done.

As a result, dirtying the inode very frequently for ext[34] is
currently expensive and should be avoided.

I _think_ that the ext4 metadata checksum patches have changed this
to only flag the inode dirty and run a pre-commit callback to copy
the in-core inode to the on-disk inode.  I'm not sure what the
current status of that patch is, nor how easily it could be split
from that patch series and land separately.

>> This is one of the reasons that the i_version update is conditional.
>> If someone is exporting a filesystem from userspace the should be able
>> to turn this on as a mount option, and knfsd could do it from inside
>> the kernel. Why add overhead when it is not needed?
> 
> Any user of the change attribute also wants it to function correctly
> while they're away.

It would only need to change once, however, not continuously.
Is there any way to know when a consumer has sampled the version?
That way the on-disk version could be bumped once after the version
was referenced, and wouldn't have to be changed thousands of times
per second, nor at all if nothing is using the version.

The MS_I_VERSION is intended to be used to indicate that i_version
needs to be updated.  I can imagine that it might make sense to
make this flag "sticky" on a filesystem, so that once it is used
for NFSv4 the version will be bumped once for an inode change even
if MS_I_VERSION is not in use, but that is sufficient for NFSv4
and it does not have to be a permanent drag on the filesystem.

> And if it at all possible I'd rather have it be something that Just
> Works rather than something that requires extra configuration.

Sure, but this is only useful for NFSv4, but costs everyone using
ext4 continuous overhead, so it isn't a clear-cut case to enable
the version just on the thought that NFS might one day be used on
any particular filesystem.

Cheers, Andreas





