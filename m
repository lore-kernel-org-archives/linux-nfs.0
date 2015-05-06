Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbbEFUOp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 16:14:45 -0400
Message-ID: <554A7626.1050709@RedHat.com>
Date: Wed, 06 May 2015 16:14:30 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Allow users to disable mount option rewriting
 via norewriteopts mount option
References: <alpine.DEB.2.10.1504201417410.5338@valhalla.home>
In-Reply-To: <alpine.DEB.2.10.1504201417410.5338@valhalla.home>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/20/2015 02:18 PM, Gregory Boyce wrote:
> Allow users to disable mount option rewriting via norewriteopts mount option.
> This was required in our case in order to allow mounting a filer which inappropriately responded via the wrong interface.
> 
> Signed-off-by: Gregory Boyce <gregory.boyce@gmail.com>
Again... This is fixing a filer bug, correct? 

We generally don't do that... 

steved.

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
