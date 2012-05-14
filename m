Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:59684 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757683Ab2ENV1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 17:27:49 -0400
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120514190500.GC1894@localhost.localdomain>
Date: Mon, 14 May 2012 15:27:47 -0600
Cc: "J. Bruce Fields" <bfields@fieldses.org>, "Ted Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-Id: <60F0B94D-FDB9-4401-B0EA-1A1C6DE4086F@dilger.ca>
References: <20120514140618.GA29902@fieldses.org> <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca> <20120514152334.GB29902@fieldses.org> <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca> <20120514175822.GC1439@thunk.org> <20120514183316.GA1894@localhost.localdomain> <20120514185400.GA32026@fieldses.org> <20120514190500.GC1894@localhost.localdomain>
To: Josef Bacik <josef@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-14, at 1:05 PM, Josef Bacik wrote:
> On Mon, May 14, 2012 at 02:54:00PM -0400, J. Bruce Fields wrote:
>> I don't think they're worried about the inode_inc_iversion() calls
>> themselves, but the behavior of file_update_time():
>> 
>>        if (!timespec_equal(&inode->i_mtime, &now))
>>                sync_it = S_MTIME;
>> 
>>        if (!timespec_equal(&inode->i_ctime, &now))
>>                sync_it |= S_CTIME;
>> 
>>        if (IS_I_VERSION(inode))
>>                sync_it |= S_VERSION;
>> 
>>        if (!sync_it)
>>                return;
>> 	...
>> 	mark_inode_dirty_sync(inode);
>> 
>> So now mark_inode_dirty_sync() is called on every update, instead of
>> merely on every update that sees a time change (so at most once a
>> jiffy).
>> 
>> So mark_inode_dirty_sync (and hence ->dirty_inode = ext4_dirty_inode)
>> may get called more often if you're writing very frequently.
>> 
>> I'm a bit surprised that's expected to add significant overhead to the
>> write.
> 
> It shouldn't, let's be honest, most systems aren't going to have such
> a coarse jiffie counter that they'll be able to get away with doing
> 2 calls to write() or ->page_mkwrite() in the same jiffie and skip the
> update to mtime/ctime anyway.  If they do they are damned lucky, and
> again the amount of overhead added even if they are should be
> negligible since 99% of us all incur the overhead from having
> to update mtime/ctime anyway.  Thanks,

Seriously?  The whole reason the above checks for timespec_equal()
are there is to avoid calling mark_inode_dirty_sync() thousands of
times per second.  If doing write() calls in the same jiffie were
so rare as you suggest then I don't think such an optimization
would ever have appeared in the first place.

For writes to a high-IOPS device (e.g. SSD) can run far higher than
1000 IOPS, and this is an important use case that people care about
today, so why add useless overhead when it isn't needed?

Cheers, Andreas





