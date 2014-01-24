Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:58303 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaAXRLO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 12:11:14 -0500
Received: by mail-pd0-f171.google.com with SMTP id g10so3357425pdj.2
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 09:11:14 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140124105213.2c40a783@tlielax.poochiereds.net>
Date: Fri, 24 Jan 2014 10:11:11 -0700
Cc: Christoph Hellwig <hch@infradead.org>,
        linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <1C06779A-6513-4460-9A12-6AAE7E6BD446@primarydata.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.205194841@bombadil.infradead.org> <20131114133551.5d08b5cd@tlielax.poochiereds.net> <20131115142847.GA1107@infradead.org> <20131115095241.2c5e1cfb@tlielax.poochiereds.net> <20131115150204.GA8105@infradead.org> <20131115103324.6a3cf978@tlielax.poochiereds.net> <20140121142159.210ca0b8@tlielax.poochiereds.net> <20140122082414.GA12530@infradead.org> <20140122070409.503db5c2@tlielax.poochiereds.net> <20140124105213.2c40a783@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2014, at 8:52, Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 22 Jan 2014 07:04:09 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Wed, 22 Jan 2014 00:24:14 -0800
>> Christoph Hellwig <hch@infradead.org> wrote:
>> 
>>> On Tue, Jan 21, 2014 at 02:21:59PM -0500, Jeff Layton wrote:
>>>> In any case, this helps but it's a little odd. With this patch, you add
>>>> an invalidate_inode_pages2 call prior to doing the DIO. But, you've
>>>> also left in the call to nfs_zap_mapping in the completion codepath.
>>>> 
>>>> So now, we shoot down the mapping prior to doing a DIO write, and then
>>>> mark the mapping for invalidation again when the write completes. Was
>>>> that intentional?
>>>> 
>>>> It seems a little excessive and might hurt performance in some cases.
>>>> OTOH, if you mix buffered and DIO you're asking for trouble anyway and
>>>> this approach seems to give better cache coherency.
>>> 
>>> Thile follows the model implemented and documented in
>>> generic_file_direct_write().
>>> 
>> 
>> Ok, thanks. That makes sense, and the problem described in those
>> comments is almost exactly the one I've seen in practice.
>> 
>> I'm still not 100% thrilled with the way that the NFS_INO_INVALID_DATA
>> flag is handled, but that really has nothing to do with this patchset.
>> 
>> You can add my Tested-by to the set if you like...
>> 
> 
> (re-sending with Trond's address fixed)
> 
> I may have spoken too soon...
> 
> This patchset didn't fix the problem once I cranked up the concurrency
> from 100 child tasks to 1000. I think that HCH's patchset makes sense
> and helps narrow the race window some, but the way that
> nfs_revalidate_mapping/nfs_invalidate_mapping work is just racy.
> 
> The following patch does seem to fix it however. It's a combination of
> a test patch that Trond gave me a while back and another change to
> serialize the nfs_invalidate_mapping ops.
> 
> I think it's a reasonable approach to deal with the problem, but we
> likely have some other areas that will need similar treatment since
> they also check NFS_INO_INVALID_DATA: 
> 
>    nfs_write_pageuptodate
>    nfs_readdir_search_for_cookie
>    nfs_update_inode
> 
> Trond, thoughts? It's not quite ready for merge, but I'd like to get an
> opinion on the basic approach, or whether you have an idea of how
> better handle the races here:

I think that it is reasonable for nfs_revalidate_mapping, but I don’t see how it is relevant to nfs_update_inode or nfs_write_pageuptodate.
Readdir already has its own locking at the VFS level, so we shouldn’t need to care there.

Cheers
  Trond
--
Trond Myklebust
Linux NFS client maintainer

