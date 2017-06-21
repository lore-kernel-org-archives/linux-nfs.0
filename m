Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43110 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752462AbdFUObe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jun 2017 10:31:34 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RESEND 0/3] Improvements to page writeback commit policy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170620233539.22417-1-trond.myklebust@primarydata.com>
Date: Wed, 21 Jun 2017 10:31:12 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C653223D-193D-4385-8AA1-11FD38C6CE89@oracle.com>
References: <20170620233539.22417-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 20, 2017, at 7:35 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> The following patches are intended to smooth out the page writeback
> performance by ensuring that we commit the data earlier on the server.
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

These are the same as the patches you sent May 16th?
I am trying to get a little time to try them out.


> Trond Myklebust (3):
>  NFS: Remove unused fields in the page I/O structures
>  NFS: Ensure we commit after writeback is complete
>  NFS: Fix commit policy for non-blocking calls to nfs_write_inode()
> 
> fs/nfs/pagelist.c        |  5 ++--
> fs/nfs/write.c           | 59 +++++++++++++++++++++++++++++++++++++++++++++++-
> include/linux/nfs_page.h |  2 +-
> include/linux/nfs_xdr.h  |  3 ++-
> 4 files changed, 64 insertions(+), 5 deletions(-)
> 
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



