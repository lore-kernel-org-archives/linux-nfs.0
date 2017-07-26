Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdGZR6X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jul 2017 13:58:23 -0400
Subject: Re: [PATCH 0/4] Fix assorted problems with mount.nfs
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
References: <149992731965.9181.6611555845253022123.stgit@noble>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e1360b67-eea3-eb06-9895-f6424a410c4d@RedHat.com>
Date: Wed, 26 Jul 2017 13:58:22 -0400
MIME-Version: 1.0
In-Reply-To: <149992731965.9181.6611555845253022123.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/13/2017 02:30 AM, NeilBrown wrote:
> These 4 patches fix various issues involves old versions of glibc, old
> kernels, and parsing of old options.
> 
> Thanks,
> NeilBrown
> 
> ---
> 
> NeilBrown (4):
>       mount: support compiling with old glibc
>       mount: use version string that is supported by old kernels.
>       mount: move handling of "-t nfs4" into nfs_nfs_version()
>       mount: Fix problems with parsing minorversion=
> 
> 
>  utils/mount/configfile.c |    2 +-
>  utils/mount/network.c    |   41 ++++++++++++++++++++++++++---------------
>  utils/mount/network.h    |    2 +-
>  utils/mount/nfsumount.c  |    2 +-
>  utils/mount/stropts.c    |   28 +++++++++++++++++++---------
>  5 files changed, 48 insertions(+), 27 deletions(-)
All 4 committed! Thanks!!!

steved.
> 
> --
> Signature
> 
