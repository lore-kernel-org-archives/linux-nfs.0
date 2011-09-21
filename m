From: Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH 0/3] three bug fixes
Date: Wed, 21 Sep 2011 16:37:37 +0300
Message-ID: <4E79E8A1.5060806@tonian.com>
References: <1316489025-24991-1-git-send-email-rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33792 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab1IUNhm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 09:37:42 -0400
Received: by wyg34 with SMTP id 34so1897701wyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 06:37:41 -0700 (PDT)
In-Reply-To: <1316489025-24991-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-09-20 06:23, Jim Rees wrote:
> This patch set fixes three bugs found in pnfsblock testing.
> 
> Peng Tao (3):
>   pnfsblock: fix NULL pointer dereference
>   pnfsblock: fix writeback deadlock
>   nfs4: serialize layoutcommit
> 
>  fs/nfs/blocklayout/blocklayout.c |   11 +++++++++--
>  fs/nfs/nfs4proc.c                |    6 ++++++
>  fs/nfs/pnfs.c                    |   24 +++++++++++++++++++++---
>  include/linux/nfs_fs.h           |    1 +
>  4 files changed, 37 insertions(+), 5 deletions(-)
> 

Submitted these too,

Thanks!

Benny
