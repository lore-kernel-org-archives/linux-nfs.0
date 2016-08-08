Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35748 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcHHV7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2016 17:59:11 -0400
Received: by mail-qt0-f193.google.com with SMTP id q11so18072341qtb.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2016 14:59:10 -0700 (PDT)
Message-ID: <1470693546.30036.11.camel@poochiereds.net>
Subject: Re: [PATCH v3 0/2] Eliminate race between LOCK and FREE_STATEID
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Mon, 08 Aug 2016 17:59:06 -0400
In-Reply-To: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
References: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-08-08 at 14:59 -0400, Chuck Lever wrote:
> This series passes light testing in my lab. If it looks good I will
> pass it along to Alexey to confirm it closes the race.
> 
> To aid distributors and stable kernel maintainers, wondering if a
> Fixes: tag should be added. Alexey first observed this issue in v4.1
> kernels (UEK4). But looks like the race could have been introduced
> as early as v3.17. Maybe this one?
> 
> commit fc5a96c3b70d00c863f69ff4ea7f5dfddbcbc0d8
> Author: Jeff Layton <jlayton@primarydata.com>
> Date:   Tue Jul 29 21:34:40 2014 -0400
> 
>     nfsd: close potential race in nfsd4_free_stateid
> 
> There have been a lot of changes since then. It's hard to say if the
> race can be attributed to a single commit.
> 
> 
> Changes since v2:
> - Move NFS4_LOCK_STID arm into a helper, for clarity
> - Add more detail to patch description
> - Add Jeff's patch to fix similar race in nfsd4_lock
> 
> Changes since v1:
> - Use s->sc_count to preserve stateid while cl_lock is dropped
> 

Probably this is a regression from when we removed the big client_mutex
from knfsd. That's what serialized all of this stuff before. So, maybe
this one actually?

commit e7d5dc19ce9800b86dd9e41ff36cc418e9da1fce
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Wed Jul 30 08:27:26 2014 -0400

    nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>


...but yeah, around that era.

> ---
> 
> Chuck Lever (1):
>       nfsd: Fix race between FREE_STATEID and LOCK
> 
> Jeff Layton (1):
>       nfsd: don't return an unhashed lock stateid after taking mutex
> 
> 
>  fs/nfsd/nfs4state.c |   65 ++++++++++++++++++++++++++++++++++++++---
> ----------
>  1 file changed, 48 insertions(+), 17 deletions(-)
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@poochiereds.net>
