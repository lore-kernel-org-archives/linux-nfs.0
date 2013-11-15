Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:42485 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab3KOPXF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 10:23:05 -0500
Received: by mail-ie0-f169.google.com with SMTP id tp5so4922774ieb.14
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 07:23:05 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131115143237.GC1107@infradead.org>
Date: Fri, 15 Nov 2013 10:23:01 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B39AEFF9-86F1-4427-B413-72B03548FAEE@gmail.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.013211118@bombadil.infradead.org> <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com> <20131115143237.GC1107@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 9:32, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Nov 14, 2013 at 03:43:21PM -0500, Trond Myklebust wrote:
>> 
>> Hi Christoph,
>> 
>> Why do we need to protect the page cache here? Using O_DIRECT and the page cache without some kind of application-specific synchronization method is technically not supported, since that violates close-to-open cache consistency.
> 
> As far as I understand close to open matter for synchronizations with
> access from different clients.  Linux applications do expect tight
> synchronization locally.

Yes, but it seems to me that if you’re adding locking in order to synchronize O_DIRECT with the page cache, then something is very wrong. It is hard to close the races, and you are really mixing 2 models that shouldn’t coexist.

It seems a lot more correct in that case to have the kernel convert those O_DIRECT writes into O_SYNC if we really need page cache consistency. That’s the only way we can really _guarantee_ that consistency.

>> What we _do_ want to support, though, is parallel reads and writes to the server by applications that know what they are doing. If we were to only protect the i_dio_count, then we could fix the truncate race, while continuing to allow parallelism. Is there any reason why we cannot do this?
> 
> To just fix that race we could do it.  Note that even with the patch we
> only do the setup and I/O submission under the lock, and wait for it
> outside, similar to what the local filesystems do for aio, but not for
> synchronous direct I/O.
> 
> Another good way to speed this up is to use locking scheme XFS uses with
> a shared exclusive lock:
> 
> buffered write:			exclusive
> buffered read:			shared
> direct I/O			exclusive if pagecache is present, then
> 				demote to shared for actual I/O,
> 				shared only if no pages are present on
> 				the file

I think we should try to close the truncate race first. Then let’s look at whether or not people need better consistency with the page cache.

Cheers,
  Trond