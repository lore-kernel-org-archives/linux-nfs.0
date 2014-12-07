Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbaLGPay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2014 10:30:54 -0500
Message-ID: <5484729B.4070001@RedHat.com>
Date: Sun, 07 Dec 2014 10:30:35 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>,
        linux-nfs@vger.kernel.org, ncopa@alpinelinux.org
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
References: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
In-Reply-To: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/02/2014 09:41 AM, Timo Teräs wrote:
> Changes since the first send:
> - split to five separate patches
> - fixed a bug in cache_get_filehandle() that made result parsing not work
> - fixed to check result of write() calls
> 
> The review mentioned my patches adding:
> nfssvc.c:71:8: warning: ignoring return value of 'system', declared with attribute warn_unused_result [-Wunused-result]
> nfssvc.c:325:9: warning: ignoring return value of 'write', declared with attribute warn_unused_result [-Wunused-result]
> but this does not make any sense: I'm only adding one #include there.
> Is that perhaps uncovering some other issues?
> 
> I'm not sure if the NFSv3 related issues were caused by the cache_get_filehandle()
> issue or not, so this still needs testing. Another potential cause is that the
> kernel is sending to user land requests longer than RPC_CHAN_BUF_SIZE bytes, but
> that does not seem likely.
> 
> Timo Teräs (5):
>   Add string.h to source files that need it
>   mountd: talk to kernel using file descriptors instead of FILE
>   gssd: talk to kernel using file descriptors instead of FILE
>   nfsexport: talk to kernel using file descriptors instead of FILE
>   nfslib: remove now unused FILE helpers
> 
>  support/include/exportfs.h     |   1 +
>  support/include/nfslib.h       |   7 -
>  support/include/nfsrpc.h       |   1 +
>  support/nfs/cacheio.c          | 111 +------------
>  support/nfs/nfsexport.c        |  77 +++++----
>  utils/gssd/gssd_proc.c         |   9 +-
>  utils/gssd/svcgssd.h           |   2 +-
>  utils/gssd/svcgssd_main_loop.c |   9 +-
>  utils/gssd/svcgssd_proc.c      |  51 +++---
>  utils/gssd/write_bytes.h       |   1 +
>  utils/mountd/cache.c           | 343 ++++++++++++++++++++++-------------------
>  utils/nfsd/nfssvc.c            |   1 +
>  12 files changed, 270 insertions(+), 343 deletions(-)
> 
Committed and tested!

steved.

