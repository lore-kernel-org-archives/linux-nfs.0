Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34998 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976AbbIYURV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 16:17:21 -0400
Date: Fri, 25 Sep 2015 16:17:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>
Subject: Re: [RFC v7 25/41] richacl: Isolate the owner and group classes
Message-ID: <20150925201720.GA15359@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-26-git-send-email-agruenba@redhat.com>
 <20150922190224.GA19127@fieldses.org>
 <CAHc6FU7_+fbyG0mEu3pUkfaV72AM0DzJnBES=b--koXJgo0a2g@mail.gmail.com>
 <1443180341-22911-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443180341-22911-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2015 at 01:25:41PM +0200, Andreas Gruenbacher wrote:
> Here is another minor improvement that produces deny aces with fewer
> permissions in them and avoids creating unnecessary deny aces in some
> cases.

Looks good.--b.

> 
> Andreas
> 
> ---
>  fs/richacl_compat.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 2f53394..bc0bcfe 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -605,14 +605,13 @@ __richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
>  	int n;
>  
>  	/*
> -	 * Compute the permissions already denied to @who.  There are no
> +	 * Compute the permissions already defined for @who.  There are no
>  	 * everyone@ deny aces left in the acl at this stage.
>  	 */
>  	richacl_for_each_entry(ace, acl) {
>  		if (richace_is_inherit_only(ace))
>  			continue;
> -		if (richace_is_same_identifier(acl, ace, who) &&
> -		    richace_is_deny(ace))
> +		if (richace_is_same_identifier(acl, ace, who))
>  			deny &= ~ace->e_mask;
>  	}
>  	if (!deny)
> -- 
> 2.4.3
