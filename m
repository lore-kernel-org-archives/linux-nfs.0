Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817AbcCNVHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2016 17:07:01 -0400
Date: Mon, 14 Mar 2016 17:06:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH - nfsv4-acl-tools] nfs4_ace_from_string: ignore
 inheritance ACEs on non-directories.
Message-ID: <20160314210659.GB22276@fieldses.org>
References: <8760xen4ph.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8760xen4ph.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 24, 2016 at 02:54:18PM +1100, NeilBrown wrote:
> 
> If you try to use
>      nfs4_setfacl -R -a A:d:........   directory
> 
> to recursively set an inheritance ACE on all directories in a tree, it
> will fail on the first non-directory as setting an inheritance ACE
> there is not permitted (and as it aborts on the first sign of an error).
> 
> So use the is_dir flag to avoid doing that, just as is done with the
> DELETE_CHILD permission.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Hi Bruce,
>  are you still maintaining nfsv4-acl-tools?  Last commit was over
>  a year ago!! I guess that means it is nearly perfect :-)

Alas, it could probably use some love.  I'm hoping richacls take over,
though.  Eventually.

>  A customer came across this problem and it seems simple to fix,
>  but if I'm missing something important, please let me know.

I didn't trace carefully through the callers, but I suspect this'll also
mean that nfs4_setfacl also silently discards inheritable ACEs in some
cases where the user could know better, instead of erroring out?

But, honestly, I'm not necessarily even sure which is the better
behavior, and -R needs to work, so, applying.

Futher patches, or volunteers for maintenance, welcome....

--b.

> 
> NeilBrown
> 
> 
>  libnfs4acl/nfs4_ace_from_string.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
> index 510ffee35d32..a7a30360d860 100644
> --- a/libnfs4acl/nfs4_ace_from_string.c
> +++ b/libnfs4acl/nfs4_ace_from_string.c
> @@ -185,16 +185,20 @@ struct nfs4_ace * nfs4_ace_from_string(char *ace_buf, int is_dir)
>  	for (buflen = strlen(field); buflen > 0; buflen--) {
>  		switch (*field) {
>  			case FLAG_FILE_INHERIT:
> -				flags |= NFS4_ACE_FILE_INHERIT_ACE;
> +				if (is_dir)
> +					flags |= NFS4_ACE_FILE_INHERIT_ACE;
>  				break;
>  			case FLAG_DIR_INHERIT:
> -				flags |= NFS4_ACE_DIRECTORY_INHERIT_ACE;
> +				if (is_dir)
> +					flags |= NFS4_ACE_DIRECTORY_INHERIT_ACE;
>  				break;
>  			case FLAG_NO_PROPAGATE_INHERIT:
> -				flags |= NFS4_ACE_NO_PROPAGATE_INHERIT_ACE;
> +				if (is_dir)
> +					flags |= NFS4_ACE_NO_PROPAGATE_INHERIT_ACE;
>  				break;
>  			case FLAG_INHERIT_ONLY:
> -				flags |= NFS4_ACE_INHERIT_ONLY_ACE;
> +				if (is_dir)
> +					flags |= NFS4_ACE_INHERIT_ONLY_ACE;
>  				break;
>  			case FLAG_SUCCESSFUL_ACCESS:
>  				flags |= NFS4_ACE_SUCCESSFUL_ACCESS_ACE_FLAG;
> -- 
> 2.7.1
> 


