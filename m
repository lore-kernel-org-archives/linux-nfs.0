From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 06/19] Use get_random_bytes() to create confounder
Date: Wed, 12 Mar 2008 12:46:16 -0400
Message-ID: <20080312164616.GF10015@fieldses.org>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu> <20080221184417.19195.55123.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50774 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584AbYCLQqT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 12:46:19 -0400
In-Reply-To: <20080221184417.19195.55123.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2008 at 01:44:17PM -0500, Kevin Coffman wrote:
> Instead of using an incementing value for the confounder, use
> get_random_bytes() which gives us the desired unpredictable value.

OK, admittedly I was probably nuts to substitute a predictable number
for a random number in any cryptographic protocol, even if I was pretty
sure it didn't matter in our case--so thanks for doing this.

But my impression is that other callers of this function are using it on
a per-connection basis instead of (as in our case) a per-rpc basis.  Is
there any problem with calling it that frequently?  Is it fast enough?
Will it deplete some common entropy pool?

--b.

> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  net/sunrpc/auth_gss/gss_krb5_wrap.c |   15 +--------------
>  1 files changed, 1 insertions(+), 14 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index a2c92f1..7a0002f 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -90,20 +90,7 @@ out:
>  static inline void
>  make_confounder(char *p, int blocksize)
>  {
> -	static u64 i = 0;
> -	u64 *q = (u64 *)p;
> -
> -	/* rfc1964 claims this should be "random".  But all that's really
> -	 * necessary is that it be unique.  And not even that is necessary in
> -	 * our case since our "gssapi" implementation exists only to support
> -	 * rpcsec_gss, so we know that the only buffers we will ever encrypt
> -	 * already begin with a unique sequence number.  Just to hedge my bets
> -	 * I'll make a half-hearted attempt at something unique, but ensuring
> -	 * uniqueness would mean worrying about atomicity and rollover, and I
> -	 * don't care enough. */
> -
> -	BUG_ON(blocksize != 8);
> -	*q = i++;
> +	get_random_bytes(p, blocksize);
>  }
>  
>  /* Assumptions: the head and tail of inbuf are ours to play with.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
