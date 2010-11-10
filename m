Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45160 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab0KJUTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 15:19:40 -0500
Message-ID: <4CDAFE4B.1060408@netapp.com>
Date: Wed, 10 Nov 2010 15:19:23 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: Catalin Marinas <catalin.marinas@arm.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Memory leak via nfs_readdir_make_qstr
References: <1289412737.4513.80.camel@e102109-lin.cambridge.arm.com>
In-Reply-To: <1289412737.4513.80.camel@e102109-lin.cambridge.arm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/10/2010 01:12 PM, Catalin Marinas wrote:
> Hi,
> 
> I tested the 2.6.37-rc1 on an ARM platform with nfsroot filesystem.
> Kmemleak reports quite a lot (> 150) of leaks like below. You seem to
> have made changes recently to this area.
> 
<snip>
> 
> Any quick thoughts? I'll have a look tomorrow as well.

Hi

My first thought is that this is because of how we are caching the result of a readdir now.  We are storing the name of each directory entry as part of the cache, and this requires allocating memory for each string.  These are freed on unmount (see nfs_readdir_clear_array() in fs/nfs/dir.c), but you probably don't want to unmount your root filesytem...

- Bryan

> 
> Thanks,
> 
> Catalin
> 

