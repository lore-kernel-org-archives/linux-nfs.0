Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbaBTRuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 12:50:21 -0500
Message-ID: <53064057.70703@RedHat.com>
Date: Thu, 20 Feb 2014 12:50:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>,
        Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - nfs-utils] Fix fallback from tcp to udp
References: <20140218104307.34205fc8@notabene.brown>
In-Reply-To: <20140218104307.34205fc8@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/17/2014 06:43 PM, NeilBrown wrote:
> 
> Protocol negotiation in mount.nfs does not correctly negotiate with a
> server which only support NFSv3 and UDP.
> 
> When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> it does not fall back to NFSv3, as this is not recognised as a
> "does not support NFSv4" error.
> However ECONNREFUSED is a clear indication that the server doesn't
> support TCP, and ipso facto does not support NFSv4.
> So ECONNREFUSED should trigger a fallback from v4 to v2/3.
I'm also pretty this is the error returned when the server is 
down or more pointy when server is rebooting... Do we really
want to fallback at this point?

Secondly, its worrisome to me that we keep making this fallback
list longer and longer... we really don't want to fall back
to v3 but I do understand we want to be compatible with 
older servers... 

steved. 
> 
> Once we allow that error, NFSv3 is attempted and mount.nfs talks to
> rpcbind and discovers that UDP should be used for v3 and the mount
> succeeds.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> Reported-by: Carsten Ziepke <kieltux@gmail.com>
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index a642394d2f5a..6d4fd70b7b9e 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -807,6 +807,9 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
>  		/* Linux servers prior to 2.6.25 may return
>  		 * EPERM when NFS version 4 is not supported. */
>  		goto fall_back;
> +	case ECONNREFUSED:
> +		/* UDP-Only servers won't support v4 */
> +		goto fall_back;
>  	default:
>  		return result;
>  	}
> 
