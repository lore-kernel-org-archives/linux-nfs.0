Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38935 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753511Ab0FGIwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 04:52:07 -0400
Message-ID: <4C0CB334.1030405@panasas.com>
Date: Mon, 07 Jun 2010 11:52:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Alexandros Batsakis <batsakis@netapp.com>
CC: linux-nfs@vger.kernel.org, bhalevy@panasas.com
Subject: Re: [PATCH 0/8] pnfs-submit: forgetful client v2
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
In-Reply-To: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/05/2010 08:00 PM, Alexandros Batsakis wrote:
> This set of patches (2.6.35-rc1) includes a first attempt to implement 

Alexandros what's up with the date of these mails they are all marked
as 5/5/2010. Looks like a bug in git send-email. (Thunderbird gave me
a hard time with that)

Boaz
> the forgetful client model for the pNFS client. The model 
> is explained is patch 7.
> It also includes some minor cleanups in the layout management code 
> that help to improve the maintanability of the current code.
> 
> Passed cthon tests against the pyNFS server, and against a modified 
> version of  pyNFS server that randomly issues layout recalls after opens.
> 
> Alexandros Batsakis (8):
>   pnfs-submit: clean struct nfs_inode
>   pnfs-submit: clean locking infrastructure
>   pnfs-submit: remove lgetcount, lretcount (outstanding
>     LAYOUTGETs/LAYOUTRETUNs)
>   pnfs-submit: change stateid to be a union
>   pnfs-submit: request whole file layouts only
>   pnfs-submit: change layouts list to be similar to the other state
>     list management
>   pnfs-submit: forgetful client model
>   pnfs-submit: support for cb_recall_any (layouts)
> 
>  fs/nfs/callback.h         |    7 +
>  fs/nfs/callback_proc.c    |  231 +++++++++++++++++++++++++++++---------
>  fs/nfs/callback_xdr.c     |    2 +-
>  fs/nfs/client.c           |    2 +-
>  fs/nfs/delegation.c       |   19 ++--
>  fs/nfs/inode.c            |   16 ++-
>  fs/nfs/nfs4_fs.h          |    1 +
>  fs/nfs/nfs4proc.c         |   46 +++++---
>  fs/nfs/nfs4state.c        |    4 +-
>  fs/nfs/nfs4xdr.c          |   38 ++++---
>  fs/nfs/pnfs.c             |  276 +++++++++++++++++++++------------------------
>  fs/nfs/pnfs.h             |    3 +-
>  fs/nfsd/nfs4callback.c    |    1 -
>  include/linux/nfs4.h      |   16 +++-
>  include/linux/nfs4_pnfs.h |    2 +-
>  include/linux/nfs_fs.h    |   28 ++---
>  include/linux/nfs_fs_sb.h |    2 +-
>  17 files changed, 417 insertions(+), 277 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

