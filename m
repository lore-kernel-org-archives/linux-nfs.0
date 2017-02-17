Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33116 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933900AbdBQRDP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 12:03:15 -0500
Date: Fri, 17 Feb 2017 12:03:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 0/7] Some cleanups and updates for sunrpc
Message-ID: <20170217170313.GA9791@fieldses.org>
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, these look fine to me.

It's really a mixture of client- and server- side stuff, but seems
unlikely to have serious conflicts with either.  For simplicity's sake I
think I'll just take them, unless Trond tells me he has.

--b.

On Tue, Feb 07, 2017 at 09:44:31PM +0800, Kinglong Mee wrote:
> The first one is an bugfix of checking register_shrinker's result,
> the following sixes are codes cleanup and updates.
> 
> Kinglong Mee (7):
>   sunrpc: error out if register_shrinker fail
>   sunrpc/nfs: cleanup procfs/pipefs entry in cache_detail
>   sunrpc: rename NFS_NGROUPS to UNX_NGROUPS for auth unix
>   sunrpc: remove dead codes of cr_magic in rpc_cred
>   sunrpc: update the comments of sunrpc proc path
>   sunrpc: record rpc client pointer in seq->private directly
>   sunrpc: use simple_read_from_buffer for reading cache flush
> 
>  fs/nfs/cache_lib.c           |  3 +-
>  include/linux/sunrpc/auth.h  |  6 +---
>  include/linux/sunrpc/cache.h | 15 ++--------
>  net/sunrpc/auth.c            |  9 +++---
>  net/sunrpc/auth_null.c       |  3 --
>  net/sunrpc/auth_unix.c       | 18 ++++++------
>  net/sunrpc/cache.c           | 68 ++++++++++++++------------------------------
>  net/sunrpc/debugfs.c         | 35 +++++++----------------
>  net/sunrpc/svcauth_unix.c    |  4 +--
>  9 files changed, 52 insertions(+), 109 deletions(-)
> 
> -- 
> 2.9.3
> 
