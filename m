Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38431 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab1IULwr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 07:52:47 -0400
Received: by wyg34 with SMTP id 34so1801120wyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 04:52:45 -0700 (PDT)
Message-ID: <4E79D00A.2090108@tonian.com>
Date: Wed, 21 Sep 2011 14:52:42 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 0/3] replacement for "introduce pnfs private workqueue"
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
In-Reply-To: <1316488728-24912-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've submitted this version to the public git tree
(pnfs-all-3.1-rc4-2011-09-20)
and rebased it onto v3.1-rc6 plus Tronds bugfixes for -rc7.
(pnfs-all-3.1-rc6-2011-09-20)

Benny

On 2011-09-20 06:18, Jim Rees wrote:
> The first patch is a bug fix that has already been sent upstream.  The next
> two patches should replace the following in your tree:
> 
> 0359f0e pNFS: introduce pnfs private workqueue
> d9b5876 SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
> ef9e1a70 SQUASHME: pnfs: do pnfsiod_start before registering layout drivers
> 
> This will re-order the patches so that the bug fix is first, followed by the
> workqueue patches.
> 
> These are also available on the for-benny branch of my git repo.
> 
> Benny Halevy (1):
>   SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
> 
> Peng Tao (2):
>   pnfsblock: add missing rpc_put_mount and path_put
>   pnfs: introduce pnfs private workqueue
> 
>  fs/nfs/blocklayout/blocklayout.c |   21 +++++++++++---
>  fs/nfs/objlayout/objio_osd.c     |   10 ++++++-
>  fs/nfs/objlayout/objlayout.c     |    4 +-
>  fs/nfs/pnfs.c                    |   54 +++++++++++++++++++++++++++++++++++++-
>  fs/nfs/pnfs.h                    |    4 +++
>  5 files changed, 84 insertions(+), 9 deletions(-)
> 
