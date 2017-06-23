Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40880 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751488AbdFWO46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 10:56:58 -0400
Date: Fri, 23 Jun 2017 10:56:57 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND 0/3] Improvements to page writeback commit policy
Message-ID: <20170623145657.GA31966@fieldses.org>
References: <20170620233539.22417-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170620233539.22417-1-trond.myklebust@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 20, 2017 at 07:35:35PM -0400, Trond Myklebust wrote:
> The following patches are intended to smooth out the page writeback
> performance by ensuring that we commit the data earlier on the server.

Was there some particular benchmark or hardware setup that motivated
doing this now?

--b.

> 
> We assume that if something is starting writeback on the pages, then
> that process wants to commit the data as soon as possible, whether it
> is an application or just the background flush process.
> We also assume that for streaming type processes, we don't want to pause
> the I/O in order to commit, so we don't want to rely on a counter of
> in-flight I/O to the entire inode going to zero.
> 
> We therefore set up a monitor that counts the number of in-flight
> writes for each call to nfs_writepages(). Once all the writes to that
> call to nfs_writepages has completed, we send the commit. Note that this
> mirrors the behaviour for O_DIRECT writes, where we similarly track the
> in-flight writes on a per-call basis.
> 
> Trond Myklebust (3):
>   NFS: Remove unused fields in the page I/O structures
>   NFS: Ensure we commit after writeback is complete
>   NFS: Fix commit policy for non-blocking calls to nfs_write_inode()
> 
>  fs/nfs/pagelist.c        |  5 ++--
>  fs/nfs/write.c           | 59 +++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/nfs_page.h |  2 +-
>  include/linux/nfs_xdr.h  |  3 ++-
>  4 files changed, 64 insertions(+), 5 deletions(-)
> 
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
