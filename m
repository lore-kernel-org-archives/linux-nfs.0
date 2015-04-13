Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093AbbDMMxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 08:53:48 -0400
Date: Mon, 13 Apr 2015 08:53:45 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: Writes signal number to kernel as command line
In-Reply-To: <552BB264.8010104@gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1504130843210.4187@planck.local>
References: <552BB264.8010104@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-1277677720-1428929626=:4187"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1277677720-1428929626=:4187
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Mon, 13 Apr 2015, Kinglong Mee wrote:

> When mounting nfs with -overs=4,minorversion=2, want getting
> nfs mounts with vers=4.2, but got vers=4.0 as,
>
> # mount -t nfs -onfsvers=4,minorversion=2 127.0.0.1:/ /mnt/
> # cat /proc/mounts | grep vers
> 127.0.0.1:/ /mnt nfs4 rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=127.0.0.1,local_lock=none,addr=127.0.0.1 0 0
>
> It's caused by mount.nfs writing bad vers to kernel. This patch
> lets mount.nfs writing signal number to kernel as command line.
>
> Note： This patch is based on my last patch,
> "mount: make sure mounting nfs with v4,vers=4 and nfsvers=4"
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>


> ---
>  utils/mount/stropts.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 2ae532e..c8f5a6d 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -737,8 +737,13 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>  	}
>
>  	if (mi->version.v_mode != V_SPECIFIC) {
> -		snprintf(version_opt, sizeof(version_opt) - 1,
> -			"vers=%lu.%lu", mi->version.major, mi->version.minor);
> +		if (mi->version.v_mode == V_GENERAL)
> +			snprintf(version_opt, sizeof(version_opt) - 1,
> +				"vers=%lu", mi->version.major);
> +		else
> +			snprintf(version_opt, sizeof(version_opt) - 1,
> +				"vers=%lu.%lu", mi->version.major,
> +				mi->version.minor);
>
>  		if (po_append(options, version_opt) == PO_FAILED) {
>  			errno = EINVAL;
> --
> 2.3.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--0-1277677720-1428929626=:4187--
