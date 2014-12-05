Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37845 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbaLEQ63 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2014 11:58:29 -0500
Date: Fri, 5 Dec 2014 11:58:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Jeff Layton <jlayton@primarydata.com>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs: nfsd: Fix signedness bug in compare_blob
Message-ID: <20141205165827.GD25884@fieldses.org>
References: <1417706452-30204-1-git-send-email-linux@rasmusvillemoes.dk>
 <1417794008-16944-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1417794008-16944-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2014 at 04:40:07PM +0100, Rasmus Villemoes wrote:
> Bugs similar to the one in acbbe6fbb240 (kcmp: fix standard comparison
> bug) are in rich supply.
> 
> In this variant, the problem is that struct xdr_netobj::len has type
> unsigned int, so the expression o1->len - o2->len _also_ has type
> unsigned int; it has completely well-defined semantics, and the result
> is some non-negative integer, which is always representable in a long
> long. But this means that if the conditional triggers, we are
> guaranteed to return a positive value from compare_blob.
> 
> In this case it could be fixed by
> 
> -       res = o1->len - o2->len;
> +       res = (long long)o1->len - (long long)o2->len;
> 
> but I'd rather eliminate the usually broken 'return a - b;' idiom.
> 
> Reviewed-by: Jeff Layton <jlayton@primarydata.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> 
> Notes:
>     How this could ever have worked is beyond me - compare_blob seems to
>     be used to maintain an rbtree, and I wouldn't expect rbtrees to behave
>     well if the comparison function doesn't satisfy the basic invariant
>     sign(cmp(a, b)) == -sign(cmp(b, a)).

Looking quickly at nfs4_init_*_client_string....  I'm guessing that at
least in testing environments client names are typically all the same
length.

And a failure to find a client by name might only have consequences in
reboot recovery cases, so as long as this doesn't cause the rbtree code
to crash or something, this might be harder than you'd think to notice.

Anyway, applying for 3.19 and stable (I think 3.18's just about closed),
thanks.

--b.


>     
>     v2: Same patch. Slightly less generic subject. Added Jeff's
>     Reviewed-by and Cc stable.
> 
>  fs/nfsd/nfs4state.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e9c3afe4b5d3..d504cd6927f8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1711,15 +1711,14 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
>  	return 0;
>  }
>  
> -static long long
> +static int
>  compare_blob(const struct xdr_netobj *o1, const struct xdr_netobj *o2)
>  {
> -	long long res;
> -
> -	res = o1->len - o2->len;
> -	if (res)
> -		return res;
> -	return (long long)memcmp(o1->data, o2->data, o1->len);
> +	if (o1->len < o2->len)
> +		return -1;
> +	if (o1->len > o2->len)
> +		return 1;
> +	return memcmp(o1->data, o2->data, o1->len);
>  }
>  
>  static int same_name(const char *n1, const char *n2)
> @@ -1907,7 +1906,7 @@ add_clp_to_name_tree(struct nfs4_client *new_clp, struct rb_root *root)
>  static struct nfs4_client *
>  find_clp_in_name_tree(struct xdr_netobj *name, struct rb_root *root)
>  {
> -	long long cmp;
> +	int cmp;
>  	struct rb_node *node = root->rb_node;
>  	struct nfs4_client *clp;
>  
> -- 
> 2.0.4
> 
