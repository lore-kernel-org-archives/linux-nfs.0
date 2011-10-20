Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39550 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab1JTL4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 07:56:30 -0400
Date: Thu, 20 Oct 2011 07:56:29 -0400
To: Benny Halevy <benny@tonian.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH 7/7] nfsd4: share_access_to_flags should consider only
 nfs4.x share_access flags
Message-ID: <20111020115629.GJ5444@fieldses.org>
References: <4E9F82FC.2000904@tonian.com>
 <1319076817-13550-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319076817-13550-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:13:37PM -0700, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Currently, it will not correctl ignore and nfsv4.1 signal flags if the client
> sends them.

Good catch, but since b6d2f1ca3c1162f51098969e9c52fd099720416a "nfsd4:
more robust ignoring of WANT bits in OPEN" we're actually doing this
right from the start, and this is redundant.

(And remembering to mask out the other bits on every use is so
error-prone, I'm wondering if we should actually put the other bits in a
separate field entirely.  Either that or maybe provide a little helper
function to get the access bits and ensure they're never accessed any
other way.)

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5c3377c..a687e1a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2555,7 +2555,7 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
>  
>  static int share_access_to_flags(u32 share_access)
>  {
> -	share_access &= ~NFS4_SHARE_WANT_MASK;
> +	share_access &= NFS4_SHARE_ACCESS_MASK;
>  
>  	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
>  }
> -- 
> 1.7.6
> 
