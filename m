Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:59210 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769Ab0GZPeB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jul 2010 11:34:01 -0400
Subject: Re: dentry cache memory usage
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Casey Bodley <cbodley@umich.edu>
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
In-Reply-To: <AANLkTinSHDKPO5frmr4sik6ZnIZyOpfsDvXc20W74Df1@mail.gmail.com>
References: <AANLkTinSHDKPO5frmr4sik6ZnIZyOpfsDvXc20W74Df1@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 26 Jul 2010 11:33:54 -0400
Message-ID: <1280158434.2869.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-07-26 at 11:21 -0400, Casey Bodley wrote:
> I'm a developer at CITI working on the windows pnfs client.  We've
> been looking into some optimizations for our name and attribute
> caches, mainly involving the use of pools to avoid allocating memory
> for each new entry.
> 
> We're looking for a sensible initial/maximum pool size.  Once the
> maximum pool size is reached, we'll start scavenging the least
> recently used entries.  Does the linux client impose any limits on the
> size of the dentry cache?
> 
> I'm also curious what time limits you're using before expiring cached
> attributes and lookups.
> 
> I suppose I'm just asking for magic numbers here, in the hope that
> smart people have tested and benchmarked this stuff in the linux
> client.

Linux doesn't really allow you to set a maximum dcache size. Instead,
the system allows you to allocate as many dentries as you like. When the
system runs low on memory, the VM will trigger an LRU based reclaim of
older dentries.

The page cache is managed on a similar basis.

Cheers
  Trond

