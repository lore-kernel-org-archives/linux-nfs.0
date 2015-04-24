Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753760AbbDXNSr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2015 09:18:47 -0400
Message-ID: <553A42B4.5010101@RedHat.com>
Date: Fri, 24 Apr 2015 09:18:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs-utils: Allow users to disable mount option rewriting via
 norewriteopts mount option
References: <alpine.DEB.2.10.1504201432530.5987@valhalla.home>
In-Reply-To: <alpine.DEB.2.10.1504201432530.5987@valhalla.home>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 04/20/2015 02:34 PM, Gregory Boyce wrote:
> Allow users to disable mount option rewriting via norewriteopts mount option.
> This was required in our case in order to allow mounting a filer 
> which inappropriately responded via the wrong interface.
Why are we adding a mount option to fix a broken server??

steved.

> 
> Signed-off-by: Gregory Boyce <gregory.boyce@gmail.com>
> ---
>  utils/mount/stropts.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index df67fac..bbda754 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -534,6 +534,14 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options, int checkv4)
>      struct pmap mnt_pmap;
> 
>      /*
> +     * "norewriteopts" option bypasses the options rewriting
> +     */
> +    if (po_contains(options, "norewriteopts") == PO_FOUND) {
> +        po_remove_all(options, "norewriteopts");
> +        return 1;
> +    }
> +
> +    /*
>       * Version and transport negotiation is not required
>       * and does not work for RDMA mounts.
>       */
