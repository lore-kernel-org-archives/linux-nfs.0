From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] rpc.mountd: Turn off root_squash on pseudo roots, its
	not needed.
Date: Tue, 8 Jun 2010 20:31:34 -0400
Message-ID: <20100609003134.GN26435@fieldses.org>
References: <4C06C99B.2070004@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755983Ab0FIAbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 20:31:35 -0400
In-Reply-To: <4C06C99B.2070004-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 02, 2010 at 05:14:03PM -0400, Steve Dickson wrote:
> Hello,
> 
> It turns out the setting of NFSEXP_ROOTSQUASH option
> on pseudo roots breaks v4 exports when the no_root_squash
> is set on the 'real' export. For example,

I remember thinking about this sort of case as we were working on this,
but can't remember why I left ROOTSQUASH set.  I think it may just have
been paranoia, combined with skepticism that anyone would want to
nfs-export a filesystem that could only be looked up by root.

Apparently someone is?  I'd still be curious why.  But I think your
patch is right; for what it's worth:

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

--b.

> 
> The export:
> 
>     /home/user/dir  *(rw,no_root_squash)
> 
> the /home/user directory has the 0700 permission modes
> 
> Now from an v4 enabled client do the following mount
> will fail with permission denied. 
>    mount server:/home/user/dir /mnt
> 
> The reason being, the 'no_root_squash' option is only
> being applied to the 'dir' part of the path. So then
> root tries to lookup the 'user' part, its denied. 
> 
> Now turns out the NFSEXP_ROOTSQUASH option is not need
> to be set on pseudo roots because one, they are marked
> as read only and two only the export part of the path 
> are exposed if by chance the actual pseudo root is 
> mounted. For example:
>     # mount server:/ /mnt
>     # ls /mnt
>      ./  ../  home/
>     # ls /mnt/home
>     ./  ../  user/
> 
> only the above directories would be shown and they would be 
> read-only
> 
> steved.
> 
> 
> Currently the default setting of a pseudo root is to have
> NFSEXP_ROOTSQUASH enabled. This setting will cause the looking
> up of real export to fail when have the no_root_squash set.
> 
> It turns the setting of NFSEXP_ROOTSQUASH is not needed on pseudo
> roots for two reasons. 1) pseudo roots are marked as read-only so
> they can not be written on. 2) pseudo roots only show exported
> entries when they are mounted.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/v4root.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 7fd6af3..41b77eb 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -35,9 +35,8 @@ static nfs_export pseudo_root = {
>  	.m_export = {
>  		.e_hostname = "*",
>  		.e_path = "/",
> -		.e_flags = NFSEXP_READONLY | NFSEXP_ROOTSQUASH
> -				| NFSEXP_NOSUBTREECHECK | NFSEXP_FSID
> -				| NFSEXP_V4ROOT,
> +		.e_flags = NFSEXP_READONLY | NFSEXP_NOSUBTREECHECK | 
> +				NFSEXP_FSID | NFSEXP_V4ROOT,
>  		.e_anonuid = 65534,
>  		.e_anongid = 65534,
>  		.e_squids = NULL,
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
