From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] nfsd41: fix NFSD_MIN_HDR_SEQ_SZ
Date: Mon, 14 Sep 2009 14:51:20 -0400
Message-ID: <20090914185120.GB1658@fieldses.org>
References: <1252709575-3426-1-git-send-email-andros@netapp.com> <1252709575-3426-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36095 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbZINSvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 14:51:18 -0400
In-Reply-To: <1252709575-3426-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2009 at 06:52:54PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The reply RPC header is 12 bytes, the NULL verifier is 8 bytes giving 20
> not 24 bytes in the NFSD_MIN_HDR_SEQ_SZ calculation,

No, 24 is right.  Maybe you forgot the accept stat at the end?:

	xid
	msg type
	reply stat
	verf flavor
	verf length
	accept stat

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 46e9ac5..5ecb42c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -420,12 +420,12 @@ gen_sessionid(struct nfsd4_session *ses)
>   * each time.  Therefore we can advertise a ca_maxresponssize_cached
>   * value that is the number of bytes in our cache plus a few additional
>   * bytes.  In order to stay on the safe side, and not promise more than
> - * we can cache, those additional bytes must be the minimum possible: 24
> + * we can cache, those additional bytes must be the minimum possible: 20
>   * bytes of rpc header (xid through accept state, with AUTH_NULL
>   * verifier), 12 for the compound header (with zero-length tag), and 44
>   * for the SEQUENCE op response:
>   */
> -#define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
> +#define NFSD_MIN_HDR_SEQ_SZ  (20 + 12 + 44)
>  
>  /*
>   * Give the client the number of ca_maxresponsesize_cached slots it
> -- 
> 1.6.2.5
> 
