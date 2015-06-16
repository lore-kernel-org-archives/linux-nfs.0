Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907AbbFPP1K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2015 11:27:10 -0400
Date: Tue, 16 Jun 2015 11:27:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1 linux-next] nfsd: use swap() in sort_pacl_range()
Message-ID: <20150616152709.GA2147@fieldses.org>
References: <1434128337-10366-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1434128337-10366-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks.--b.

On Fri, Jun 12, 2015 at 06:58:57PM +0200, Fabian Frederick wrote:
> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  fs/nfsd/nfs4acl.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 7e10e2a..eb5accf 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -372,7 +372,6 @@ pace_gt(struct posix_acl_entry *pace1, struct posix_acl_entry *pace2)
>  static void
>  sort_pacl_range(struct posix_acl *pacl, int start, int end) {
>  	int sorted = 0, i;
> -	struct posix_acl_entry tmp;
>  
>  	/* We just do a bubble sort; easy to do in place, and we're not
>  	 * expecting acl's to be long enough to justify anything more. */
> @@ -382,9 +381,8 @@ sort_pacl_range(struct posix_acl *pacl, int start, int end) {
>  			if (pace_gt(&pacl->a_entries[i],
>  				    &pacl->a_entries[i+1])) {
>  				sorted = 0;
> -				tmp = pacl->a_entries[i];
> -				pacl->a_entries[i] = pacl->a_entries[i+1];
> -				pacl->a_entries[i+1] = tmp;
> +				swap(pacl->a_entries[i],
> +				     pacl->a_entries[i + 1]);
>  			}
>  		}
>  	}
> -- 
> 2.4.2
