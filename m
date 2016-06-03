Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:46078 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbcFCDoJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 23:44:09 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160603033750.GL14480@ZenIV.linux.org.uk>
Date: Thu, 2 Jun 2016 23:43:59 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2016, at 11:37 PM, Al Viro wrote:

> On Thu, Jun 02, 2016 at 06:46:08PM -0400, Oleg Drokin wrote:
>> Hello!
>> 
>>   I just came across a bug (trying to run some Lustre test scripts against NFS, while hunting for another nfsd bug)
>>   that seems to be present since at least 2014 that lets users crash nfs client locally.
> 
>>> * Cluster filesystems may call this function with a negative, hashed dentry.
>>> * In that case, we know that the inode will be a regular file, and also this
>>> * will only occur during atomic_open. So we need to check for the dentry
>>> * being already hashed only in the final case.
> 
> Comment is long obsolete and should've been removed.  "Cluster filesystem"
> in question was GFS2 and it had been dealt with there.  Mea culpa - should've
> removed the comment as soon as that was done.

Oh, ok. I assumed it was still valid, esp. considering the issue at hand where
what it describes actually happens and NFS is also a cluster filesystem of sorts ;)

>> The problem was there at least since 3.10 it appears where the fs/nfs/dir.c code
>> was calling d_materialise_unique() that did require the dentry to be unhashed.
>> 
>> Not sure how this was not hit earlier. The crash looks like this (I added
>> a printk to ensure this is what is going on indeed and not some other weird race):
> 
>> [   64.489326] Calling into d_splice_alias with hashed dentry, dentry->d_inode (null) inode ffff88010f500c70
> 
> Which of the call sites had that been and how does one reproduce that fun?
> If you feel that posting a reproducer in the open is a bad idea, just send
> it off-list...

This is fs/nfs/dir.c::nfs_lookup() right after no_entry label.

I'll send you the scripts with instructions separately for now.