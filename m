Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:49065 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaAYBFU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 20:05:20 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so4062861igb.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 17:05:20 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140124195456.5db4f830@tlielax.poochiereds.net>
Date: Fri, 24 Jan 2014 18:05:18 -0700
Cc: Christoph Hellwig <hch@infradead.org>,
        linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <2DA2FEA5-6AAB-49BB-824E-893908BCE225@primarydata.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.205194841@bombadil.infradead.org> <20131114133551.5d08b5cd@tlielax.poochiereds.net> <20131115142847.GA1107@infradead.org> <20131115095241.2c5e1cfb@tlielax.poochiereds.net> <20131115150204.GA8105@infradead.org> <20131115103324.6a3cf978@tlielax.poochiereds.net> <20140121142159.210ca0b8@tlielax.poochiereds.net> <20140122082414.GA12530@infradead.org> <20140122070409.503db5c2@tlielax.poochiereds.net> <20140124105213.2c40a783@tlielax.poochiereds.net> <1C06779A-6513-4460-9A12-6AAE7E6BD446@primarydata.com> <20140124122924.0eb2e6bd@tlielax.poochiereds.net> <1390585206.2927.9.camel@leira.trondhjem.org> <20140124130013.22f706de@tlielax.poochiereds.net> <1390589201.2927.46.camel@leira.trondhjem.org> <20140124162104.3a588571@tlielax.poochiereds.net> <7DB95D70-9E9E-49B9-80BE-EB891F5D72DB@primarydata.com> <20140124195456.5db4f830@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2014, at 17:54, Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 24 Jan 2014 17:39:45 -0700
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Jan 24, 2014, at 14:21, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Fri, 24 Jan 2014 11:46:41 -0700
>>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>> 
>>>> Convert your patch to use wait_on_bit(), and then to call
>>>> wait_on_bit_lock() if and only if you see NFS_INO_INVALID_DATA is set.
>>>> 
>>> 
>>> I think that too would be racy...
>>> 
>>> We have to clear NFS_INO_INVALID_DATA while holding the i_lock, but we
>>> can't wait_on_bit_lock() under that. So (pseudocode):
>>> 
>>> wait_on_bit
>>> take i_lock
>>> check and clear NFS_INO_INVALID_DATA
>>> drop i_lock
>>> wait_on_bit_lock
>>> 
>>> ...so between dropping the i_lock and wait_on_bit_lock, we have a place
>>> where another task could check the flag and find it clear.
>> 
>> 
>> 	for(;;) {
>> 		wait_on_bit(NFS_INO_INVALIDATING)
>> 		/* Optimisation: don’t lock NFS_INO_INVALIDATING
>> 		 * if NFS_INO_INVALID_DATA was cleared while we waited.
>> 		 */
>> 		if (!test_bit(NFS_INO_INVALID_DATA))
>> 			return;
>> 		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING))
>> 			break;
>> 	}
>> 	spin_lock(inode->i_lock);
>> 	if (!test_and_clear_bit(NFS_INO_INVALID_DATA)) {
>> 		spin_unlock(inode->i_lock);
>> 		goto out_raced;
>> 	}
>> ….
>> out_raced:
>> 	clear_bit(NFS_INO_INVALIDATING)
>> 	wake_up_bit(NFS_INO_INVALIDATING)
>> 
>> 
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
> 
> Hmm maybe. OTOH, if we're using atomic bitops do we need to deal with
> the spinlock?  I'll ponder it over the weekend and give it a harder
> look on Monday.
> 

The NFS_I(inode)->cache_validity doesn’t use bitops, so the correct behaviour is to put NFS_INO_INVALIDATING inside NFS_I(inode)->flags (which is an atomic bit op field), and then continue to use the spin lock for NFS_INO_INVALID_DATA.

--
Trond Myklebust
Linux NFS client maintainer

