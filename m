Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52293 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756428Ab3CEVLF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 16:11:05 -0500
Date: Tue, 5 Mar 2013 16:10:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yanchuan Nian <ycnian@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Correct read access checking
Message-ID: <20130305211059.GC15816@fieldses.org>
References: <20130303090211.GA29550@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130303090211.GA29550@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 03, 2013 at 05:02:11PM +0800, Yanchuan Nian wrote:
> NFS4_SHARE_ACCESS_WRITE should not be tested in access_permit_read() for this
> function just tests read permission, so remove it.
> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 16d39c6..75c873d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3322,8 +3322,7 @@ static inline int
>  access_permit_read(struct nfs4_ol_stateid *stp)
>  {
>  	return test_access(NFS4_SHARE_ACCESS_READ, stp) ||
> -		test_access(NFS4_SHARE_ACCESS_BOTH, stp) ||
> -		test_access(NFS4_SHARE_ACCESS_WRITE, stp);
> +		test_access(NFS4_SHARE_ACCESS_BOTH, stp);
>  }

This was introduced by a patch from 2005:

    [PATCH] nfsd4: allow read on open for write
    
    The rfc recommends allowing read using stateid's from opens that only
    requested write access, as clients may in some cases be unable to write
    without doing reads.

So I think it's correct.

That said, I don't understand why we still have this function at all:
can it ever return anything other than true?

--b.
