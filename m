Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:41525 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab1G1JTM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 05:19:12 -0400
Message-ID: <4E31298B.7050800@itwm.fraunhofer.de>
Date: Thu, 28 Jul 2011 11:19:07 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Subject: Re: [PATCH 3/3] nfsd: vfs_llseek() with O_32BITHASH or O_64BITHASH
References: <20110727110148.204979.49551.stgit@localhost.localdomain> <20110727110259.204979.56782.stgit@localhost.localdomain> <20110727210344.GC9066@infradead.org>
In-Reply-To: <20110727210344.GC9066@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 11:03 PM, Christoph Hellwig wrote:
> On Wed, Jul 27, 2011 at 01:02:59PM +0200, Bernd Schubert wrote:
>> Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
>> the NFS version. NFSv2 gets 32-bit hashes only.
>
> Independent of the O_ vs FMODE thing make sure you pass the correct
> flag at open time, instead of racy runtime modifications.
>

Christoph,

before I'm going to work further on the patch sets, I have few questions 
first. Could you please help me with that?

file->f_mode is set in __dentry_open() based on O_ flags.

So if f_mode is supposed to be set directly during the NFS open call we 
would need O_ *and* FMODE flags,

Now I still do not understand why we cannot add a flag *after* the open 
call and only in nfsd_readdir()? I do not see any races there.

nfsd_readdir() gets its 'struct file' from get_empty_filp() and 
__dentry_open(). Now as 'struct file' is allocated by get_empty_filp() 
it also cannot be used by any other thread.

nfsd_readdir() just reads the directory and closes it immedeatily after 
the readdir().

So where is there supposed to be a race?


And lastly, if we are going to set f_mode directly at open time, we have 
the choice to

1) Specify those new O_ flags for all files. While setting a flag is a 
cheap operation, it still wastes CPU cycles for file opens, as files do 
not need that flag.

2) Duplicate nfsd_open() to implement a new function for directories 
only. I think not a good idea either.

3) Rewrite the nfsd_open() function to allow to set flags from calling 
functions. That would mean to update the nfsd code at at least 8 places. 
Do we really want to go that way?


So altogether, updating the patches to replace O_ by FMODE flags is 
easy, but setting that flag in nfsd at open time, would mean a large 
overhead.


Thanks,
Bernd

