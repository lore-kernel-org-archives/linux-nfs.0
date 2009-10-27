From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix sort_pacl in fs/nfsd/nf4acl.c to actually
	sort groups
Date: Tue, 27 Oct 2009 19:32:44 -0400
Message-ID: <20091027233244.GD14471@fieldses.org>
References: <1256168703.31791.14.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	Frank S Filz <ffilz@us.ibm.com>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46328 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756850AbZJ0XbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 19:31:21 -0400
In-Reply-To: <1256168703.31791.14.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 21, 2009 at 04:45:02PM -0700, Frank Filz wrote:
> We have been doing some extensive testing of Linux support for ACLs on
> NFDS v4. We have noticed that the server rejects ACLs where the groups
> are out of order, for example, the following ACL is rejected:
> 
> A::OWNER@:rwaxtTcCy
> A::user101@domain:rwaxtcy
> A::GROUP@:rwaxtcy
> A:g:group102@domain:rwaxtcy
> A:g:group101@domain:rwaxtcy
> A::EVERYONE@:rwaxtcy
> 
> Examining the server code, I found that after converting an NFS v4 ACL
> to POSIX, sort_pacl is called to sort the user ACEs and group ACEs.
> Unfortunately, a minor bug causes the group sort to be skipped.

Good grief, I'm embarassed--OK, thanks for catching that!  Do you have
any regression tests that'd be easy for someone else to run?

Applied.

--b.

> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
>  fs/nfsd/nfs4acl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 725d02f..6d9c6aa 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -389,7 +389,7 @@ sort_pacl(struct posix_acl *pacl)
>  	sort_pacl_range(pacl, 1, i-1);
>  
>  	BUG_ON(pacl->a_entries[i].e_tag != ACL_GROUP_OBJ);
> -	j = i++;
> +	j = ++i;
>  	while (pacl->a_entries[j].e_tag == ACL_GROUP)
>  		j++;
>  	sort_pacl_range(pacl, i, j-1);
> -- 
> 1.5.2.2
> 
> 
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
