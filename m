Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46582 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754993Ab1IKQBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 12:01:03 -0400
Received: by pzk37 with SMTP id 37so5475098pzk.1
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2011 09:01:03 -0700 (PDT)
Message-ID: <4E6CDB3D.2050702@tonian.com>
Date: Sun, 11 Sep 2011 09:01:01 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 0/3] pnfs private workqueue, and two cleanups
References: <1315676495-3689-1-git-send-email-rees@umich.edu>
In-Reply-To: <1315676495-3689-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I merged the patches as well as my two SQUASHMEs
under pnfs-all-3.1-rc4-2011-09-11

Thanks!

Benny

On 2011-09-10 10:41, Jim Rees wrote:
> These have been sent to the list previously, and I believe are
> uncontroversial, but have not shown up on your pnfs-all-latest branch.
> 
> Peng Tao (3):
>   SUNRPC/NFS: make rpc pipe upcall generic
>   pNFS: introduce pnfs private workqueue
>   pNFS: make _set_lo_fail generic
> 
>  fs/nfs/blocklayout/blocklayout.c    |   36 +++++++++-----------
>  fs/nfs/blocklayout/blocklayout.h    |    2 -
>  fs/nfs/blocklayout/blocklayoutdev.c |   22 ------------
>  fs/nfs/idmap.c                      |   25 +-------------
>  fs/nfs/nfs4filelayout.c             |   19 ++---------
>  fs/nfs/objlayout/objio_osd.c        |    8 ++++
>  fs/nfs/objlayout/objlayout.c        |    4 +-
>  fs/nfs/pnfs.c                       |   64 ++++++++++++++++++++++++++++++++++-
>  fs/nfs/pnfs.h                       |    5 +++
>  include/linux/sunrpc/rpc_pipe_fs.h  |    2 +
>  net/sunrpc/auth_gss/auth_gss.c      |   24 +------------
>  net/sunrpc/rpc_pipe.c               |   20 +++++++++++
>  12 files changed, 122 insertions(+), 109 deletions(-)
> 
