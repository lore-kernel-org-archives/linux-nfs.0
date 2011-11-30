Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e3.ny.us.ibm.com ([32.97.182.143]:36448 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757050Ab1K3O5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 09:57:16 -0500
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 30 Nov 2011 09:57:15 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAUEvAqe301858
	for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 09:57:11 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAUEv23G015734
	for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 07:57:02 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id pAUEuwlZ015349
	for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 07:56:58 -0700
Date: Wed, 30 Nov 2011 08:56:57 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: only do COMMIT for range written with direct I/O
Message-ID: <20111130145657.GA7883@us.ibm.com>
References: <1322662074-3843-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322662074-3843-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton [jlayton@redhat.com] wrote:
> When given a range to write with unstable writes, the current code
> always does a COMMIT of the entire file afterward. This is potentially
> expensive on some servers and unnecessary. Instead, just do a COMMIT for
> the offset and count that was written.
> 
> Khoa, who reported this bug, stated that this made a big difference in
> performance in their environment, which I believe involves GPFS on the
> server. He didn't pass along any hard numbers so I can't quantify the
> gain, but it stands to reason that clustered filesystems might suffer
> more contention issues when issuing a commit over the whole file.
> 
> Reported-by: Khoa Huynh <khoa@us.ibm.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/direct.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 1940f1a..33f2be7 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -77,6 +77,7 @@ struct nfs_direct_req {
>  	/* completion state */
>  	atomic_t		io_count;	/* i/os we're waiting for */
>  	spinlock_t		lock;		/* protect completion state */
> +	loff_t			pos;		/* offset into file */

Why not call it "offset"? Should we set this to zero in
nfs_direct_req_alloc (just like count is set to zero there)?

Thanks, Malahal.

