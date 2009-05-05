From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Allow nfs/vers=4 option in text-based mount commands
Date: Tue, 5 May 2009 18:02:44 -0400
Message-ID: <6BEE21E5-A57E-46EA-A9A2-AED95715BFDE@oracle.com>
References: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-2-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-3-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:23536 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbZEEWCw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2009 18:02:52 -0400
In-Reply-To: <1241560004-16787-3-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 5, 2009, at 5:46 PM, Kevin Constantine wrote:

> This allows a user to specify nfsvers=4, or vers=4 on the mount
> commandline and have mount.nfs4 called as though fstype=nfs4 were
> specified.  This patch handles the nfsmount_string case in
> mount.c's try_mount().
>
> We get the value of the "vers=" or "nfsvers=" from the nfsmount_info
> structure, and if the value equals 4, we set the fstype to nfs4, and
> remove the nfsvers/vers options from the structure since it shouldn't
> be there in the first place, and we don't want to pass it along down
> the stack.
>
> po_get_numeric returns the rightmost instance, so we honor the last
> value of nfsvers/vers in the event that it is overridden later in the
> options string.
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
> >
> ---
> utils/mount/stropts.c |    9 +++++++++
> 1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c369136..72b0d13 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -754,6 +754,15 @@ static const char *nfs_background_opttbl[] = {
>
> static int nfsmount_start(struct nfsmount_info *mi)
> {
> +	long tmp;
> +	po_get_numeric(mi->options, "vers", &tmp);
> +	po_get_numeric(mi->options, "nfsvers", &tmp);

If someone specifies both a vers= and a nfsvers= on the command line,  
this won't handle it.  You need to implement a rightmost search, as  
Steve's patch (posted previously on this list) did.

> +	if (tmp == 4) {
> +		mi->type = "nfs4";
> +		po_remove_all(mi->options, "vers");
> +		po_remove_all(mi->options, "nfsvers");
> +	}
> +
> 	if (!nfs_validate_options(mi))
> 		return EX_FAIL;
>
> -- 
> 1.6.2.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




