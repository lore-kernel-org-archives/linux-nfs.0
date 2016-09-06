Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:32922 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932996AbcIFLBg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 07:01:36 -0400
Received: by mail-yb0-f170.google.com with SMTP id d205so51299279ybh.0
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 04:01:35 -0700 (PDT)
Message-ID: <1473159691.13234.0.camel@redhat.com>
Subject: Re: [PATCH 0/4] Fix LAYOUTGET/LAYOUTRETURN races
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 07:01:31 -0400
In-Reply-To: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
References: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-09-05 at 09:45 -0400, Trond Myklebust wrote:
> Trond Myklebust (4):
>   pNFS: Ensure LAYOUTGET and LAYOUTRETURN are properly serialised
>   pNFS: Fix pnfs_set_layout_stateid() to clear
> NFS_LAYOUT_INVALID_STID
>   pNFS: Clear out all layout segments if the server unsets
>     lrp->res.lrs_present
>   pNFS: Don't forget the layout stateid if there are outstanding
>     LAYOUTGETs
> 
>  fs/nfs/nfs4proc.c |  9 ++++++---
>  fs/nfs/pnfs.c     | 42 ++++++++++++++++++++++++------------------
>  2 files changed, 30 insertions(+), 21 deletions(-)
> 

All look good to me:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
