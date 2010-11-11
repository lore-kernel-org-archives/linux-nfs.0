Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:40693 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab0KKLBZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 06:01:25 -0500
In-Reply-To: <AANLkTin4OtWZf_uWdFfCMqVyZoR_xm3-jmt0e7f04xc_@mail.gmail.com>
References: <1289412737.4513.80.camel@e102109-lin.cambridge.arm.com>
	<4CDAFE4B.1060408@netapp.com>
	<AANLkTin4OtWZf_uWdFfCMqVyZoR_xm3-jmt0e7f04xc_@mail.gmail.com>
Date: Thu, 11 Nov 2010 11:01:24 +0000
Message-ID: <AANLkTinUjnWfs4vSDvQ24zw0pbpnfsnEo1aCRZQo0DJW@mail.gmail.com>
Subject: Re: Memory leak via nfs_readdir_make_qstr
From: Catalin Marinas <catalin.marinas@arm.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10 November 2010 21:24, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On 10 November 2010 20:19, Bryan Schumaker <bjschuma@netapp.com> wrote:
>> On 11/10/2010 01:12 PM, Catalin Marinas wrote:
>>> I tested the 2.6.37-rc1 on an ARM platform with nfsroot filesystem.
>>> Kmemleak reports quite a lot (> 150) of leaks like below. You seem to
>>> have made changes recently to this area.
>>>
>> <snip>
>>>
>>> Any quick thoughts? I'll have a look tomorrow as well.
>>
>> My first thought is that this is because of how we are caching the result of a readdir now.  We are storing the name of each directory entry as part of the cache, and this requires allocating memory for each string.  These are freed on unmount (see nfs_readdir_clear_array() in fs/nfs/dir.c), but you probably don't want to unmount your root filesytem...
>
> Ah, I got it now. It seems to be a kmemleak false positive since
> kmemleak doesn't scan page cache pages. The easiest thing is to mark
> the leak with kmemleak_not_leak(), with the disadvantage that if at
> some point we get a real leak from the same place it will be missed.
>
> If there is a function that gets called only once for each array
> before it is populated (maybe nfs_do_filldir?), we could inform
> kmemleak about this page so that it can scan it.

These pages may be highmem and kmemleak doesn't do any kmap, therefore
not possible to scan the nfs_cache_array. I'll send a separate patch
to annotate the false positive.

Thanks.

-- 
Catalin
