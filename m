Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753306AbdLGPj2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 10:39:28 -0500
Subject: Re: [nfs-utils PATCH] mount.nfs: don't parse "device" name for -o
 remount
To: NeilBrown <neilb@suse.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
References: <87zi7cxprk.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <0f2a5118-72b7-27cd-7857-48e5a20c57c7@RedHat.com>
Date: Thu, 7 Dec 2017 10:39:27 -0500
MIME-Version: 1.0
In-Reply-To: <87zi7cxprk.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2017 11:30 PM, NeilBrown wrote:
> 
> When "-o remount" is used, the device/special name
> is ignored.  So don't parse it and risk generating a
> useless error.
> 
> This is particularly important when nfs-root is used
> as the "device name" is listed as "/dev/nfs".
> Because mount.nfs doesn't think that is valid,
>   mount -o remount,rw /
> will fail.
> 
> Link: https://github.com/systemd/systemd/issues/3590
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed.... 

steved.

> ---
>  utils/mount/stropts.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 440131482e2b..12178235f068 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -384,7 +384,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
>   */
>  static int nfs_validate_options(struct nfsmount_info *mi)
>  {
> -	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
> +	/* For remount, ignore mi->spec: the kernel will. */
> +	if (!(mi->flags & MS_REMOUNT) &&
> +	    !nfs_parse_devname(mi->spec, &mi->hostname, NULL))
>  		return 0;
>  
>  	if (!nfs_nfs_proto_family(mi->options, &mi->family))
> 
