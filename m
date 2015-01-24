Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:63110 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbAXL6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 06:58:03 -0500
Received: by mail-qc0-f171.google.com with SMTP id s11so1474141qcv.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 03:58:02 -0800 (PST)
Date: Sat, 24 Jan 2015 06:58:00 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Parallelise OPEN/OPEN_DOWNGRADE/CLOSE in NFSv4.x
 (x>0)
Message-ID: <20150124065800.4e1900a1@tlielax.poochiereds.net>
In-Reply-To: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 24 Jan 2015 00:39:23 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Hi all,
> 
> The following patchset improves the tracking of stateids in the CLOSE code
> to ensure that we can rely on it in situations where we remove the NFSv4.0
> serialisation of state that shares the same open owners.
> It then proceeds to add a series of changes to the NFSv4.0 seqid code to
> ensure that it can be removed in the case of NFSv4.0 opens.
> Only lightly tested so far, but it seems to be working...
> 
> In principle there is nothing stopping us from doing the same with byte
> range locks; we only need to add better atomicity of stateid updates,
> so that we can track the seqid number in the stateid and ensure that it
> never regresses. The exercise has been left for the reader...
> 
> Cheers
>   Trond
> 
> Trond Myklebust (5):
>   NFSv4: Fix an atomicity problem in CLOSE
>   NFSv4: More CLOSE/OPEN races
>   NFSv4: Convert nfs_alloc_seqid() to return an ERR_PTR() if allocation
>     fails
>   NFSv4: Check for NULL argument in nfs_*_seqid() functions
>   NFSv4.1: Allow parallel OPEN/OPEN_DOWNGRADE/CLOSE
> 
>  fs/nfs/nfs4_fs.h        |  3 +++
>  fs/nfs/nfs4proc.c       | 50 ++++++++++++++++++++++++++++++++++++++++---------
>  fs/nfs/nfs4state.c      | 31 ++++++++++++++++++------------
>  fs/nfs/nfs4xdr.c        |  9 ++++++---
>  include/linux/nfs_xdr.h |  2 +-
>  5 files changed, 70 insertions(+), 25 deletions(-)
> 

Nice work! I gave it a once-over and it looks pretty sound. I'll plan
to give it a good thrashing soon.

-- 
Jeff Layton <jeff.layton@primarydata.com>
