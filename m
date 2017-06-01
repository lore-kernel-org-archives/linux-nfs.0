Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39690 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751078AbdFAOCt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 10:02:49 -0400
Subject: Re: [PATCH] mount.nfs: improve version negotiation when vers=4 is
 specified.
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170519222510.31205-1-steved@redhat.com>
 <87inktk2yg.fsf@notabene.neil.brown.name>
 <5a0d2640-ec93-279b-9113-228994283923@RedHat.com>
 <877f18jsx5.fsf@notabene.neil.brown.name>
 <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
 <87lgpceeuo.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <82c09e27-2d53-f7a4-2826-a5f7a91ded33@RedHat.com>
Date: Thu, 1 Jun 2017 10:02:47 -0400
MIME-Version: 1.0
In-Reply-To: <87lgpceeuo.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/31/2017 08:22 PM, NeilBrown wrote:
> 
> If NFSv4, in general, is requested (possibly by -t nfs4 or -o v4 or -o
> vers=4 etc) then we need to negotiate the best minor version, but must
> not fallback to v3 or v2.  Internally, this state is reflected in v_mode
> == V_GENERAL.  This means that a major version was given, but the minor
> version still needs to be negotiated.
> 
> This is handled by nfs_autonegotiate(). It currently does the right
> thing for EPROTONOSUPPORT and EINVAL, but not for other errors.
> In particular, ENOENT can cause problems as  NFSv4 might export
> a different namespace than NFSv3 (e.g. by using fsid=0 in the Linux
> NFS server).  Currently a mount request for NFSv4 and a particular path
> can result if an NFSv3 mount if the path is available with v3 but
> not v4.
> 
> So move the special handling of V_GENERAL into the common fall_back:
> code, and add extra checking in the ENCONNREFUSED case, which does
> not use fall_back:.
> 
> Tested-by: Steve Dickson <steved@redhat.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... with the addition change to nfs_set_version() 
which stops -t nfs4 from rolling back to v3.

Thanks! 

steved.
 
> ---
>  utils/mount/stropts.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0fbb37569ef9..b20ad1c8bf55 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -838,9 +838,6 @@ check_result:
>  	case EINVAL:
>  		/* A less clear indication that our client
>  		 * does not support NFSv4 minor version. */
> -		if (mi->version.v_mode == V_GENERAL &&
> -			mi->version.minor == 0)
> -				return result;
>  		if (mi->version.v_mode != V_SPECIFIC) {
>  			if (mi->version.minor > 0) {
>  				mi->version.minor--;
> @@ -862,6 +859,9 @@ check_result:
>  		/* UDP-Only servers won't support v4, but maybe it
>  		 * just isn't ready yet.  So try v3, but double-check
>  		 * with rpcbind for v4. */
> +		if (mi->version.v_mode == V_GENERAL)
> +			/* Mustn't try v2,v3 */
> +			return result;
>  		result = nfs_try_mount_v3v2(mi, TRUE);
>  		if (result == 0 && errno == EAGAIN) {
>  			/* v4 server seems to be registered now. */
> @@ -878,6 +878,9 @@ check_result:
>  	}
>  
>  fall_back:
> +	if (mi->version.v_mode == V_GENERAL)
> +		/* v2,3 fallback not allowed */
> +		return result;
>  	return nfs_try_mount_v3v2(mi, FALSE);
>  }
>  
> 
