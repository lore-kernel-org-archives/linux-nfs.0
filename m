Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36413 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848Ab0HESKv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 14:10:51 -0400
Received: by gxk23 with SMTP id 23so2598018gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Aug 2010 11:10:50 -0700 (PDT)
In-Reply-To: <1280971521.2865.30.camel@heimdal.trondhjem.org>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
	<AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
	<97A00951-577C-4365-AA38-3C6E2D03B372@netapp.com> <AANLkTimi9CSa=XfoKBMCm-XAKcVQKVi0bEXgtA+XHexE@mail.gmail.com>
	<1280956937.2865.13.camel@heimdal.trondhjem.org> <AANLkTi=FivAoO+Rqin82h885_8bj1=Ck5mjqPqV2rif4@mail.gmail.com>
	<1280969564.2865.23.camel@heimdal.trondhjem.org> <AANLkTinq-q5f5QjCBiXuZMJY6dHajpDPZ7aO55ipNZcE@mail.gmail.com>
	<1280971521.2865.30.camel@heimdal.trondhjem.org>
From: Yudong Gao <stgyd@umich.edu>
Date: Thu, 5 Aug 2010 11:10:30 -0700
Message-ID: <AANLkTinD=CVHU9wMhmKRZk4YgaA4kZ1bZVKn5DSNF2jr@mail.gmail.com>
Subject: Re: Write delegation
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I see. I was kind of confused before. Sorry about that.

I am trying to figure out how this read-only is supported in the
source code. When a page is read from the network through
nfs_readpage(), it will be cached to fscache, as implemented in
nfs_readpage_release(). The code in nfs_readpage_release() only checks
whether fscache is available, and if so, the page will be cached to
fscache.

If a page is modified locally in memory (the page cache), then it
becomes dirty. But since the fscache is read-only, the copy of the
page in fscache becomes stale. When the file is close, the dirty page
will be written back to the server. Later when it is not used for a
while, it will be removed from the page cache. Here I suppose the copy
in fscache will not be deleted, or fscache becomes useless: it can
only mirror the pages in the page cache and does not provide extra
cache. And actually in the source code, I can not find the code to
uncache the page in fscache().

So far so good. But if later this page is read again, the behavior
becomes strange. The nfs_readpage() checks first try to read the page
from fscache. In this case, it will read the stale page and oops!

I think the problem here is that when a page become dirty in page
cache, it should be removed from fscache. So my question is where is
this implemented?

Thanks a lot!

best,

Yudong

On Wed, Aug 4, 2010 at 6:25 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2010-08-04 at 18:22 -0700, Yudong Gao wrote:
>
>> But for the integration with NFS, it is confusing. The
>> fscache_write_page() is called only in one place:
>> nfs_readpage_release(). So a NFS page is only written to fscache after
>> it is read from the server in nfs_readpage. So my question is, if a
>> page is locally modified, when its data is propagated to fscache? I
>> check the nfs_write_begin() and nfs_write_end() but cannot find any
>> relative implementation.
>
> See my previous answer. fscache only supports read-only files in NFS.
>
> Trond
>
>
