Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58352 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383Ab1K3Iau (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 03:30:50 -0500
Message-ID: <4ED5E9E1.9050709@suse.cz>
Date: Wed, 30 Nov 2011 09:31:29 +0100
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        NFS list <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>,
        linux-next@vger.kernel.org, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH v3] ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au> <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com> <4ED4238F.4090407@panasas.com> <4ED56C59.208@panasas.com>
In-Reply-To: <4ED56C59.208@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dne 30.11.2011 00:35, Boaz Harrosh napsal(a):
> 
> As Reported by Randy Dunlap
> 
> When MISC_FILESYSTEMS is not enabled:
> 
> fs/built-in.o: In function `objio_alloc_io_state':
> objio_osd.c:(.text+0xcb525): undefined reference to `ore_get_rw_state'
> fs/built-in.o: In function `_write_done':
> objio_osd.c:(.text+0xcb58d): undefined reference to `ore_check_io'
> fs/built-in.o: In function `_read_done':
> ...
> 
> When MISC_FILESYSTEMS, which is more of a GUI thing then anything else,
> is not selected. exofs/Kconfig is never examined during Kconfig,
> and it can not do it's magic stuff to automatically select everything
> needed.
> 
> We must split exofs/Kconfig in two. The ore one is always included.
> And the exofs one is left in it's old place in the menu.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/Kconfig           |    2 ++
>  fs/exofs/Kconfig     |   11 -----------
>  fs/exofs/ore.Kconfig |   12 ++++++++++++
>  3 files changed, 14 insertions(+), 11 deletions(-)
>  create mode 100644 fs/exofs/ore.Kconfig
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 5f4c45d..fd7bfef 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -218,6 +218,8 @@ source "fs/exofs/Kconfig"
>  
>  endif # MISC_FILESYSTEMS
>  
> +source "fs/exofs/ore.Kconfig"
> +

I suggest you name it Kconfig.ore. We have a couple of Kconfig.* files
in the tree, so let's be consistent.

Michal
