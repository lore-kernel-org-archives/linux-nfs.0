Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50647 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932248Ab1CCUNJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Mar 2011 15:13:09 -0500
Subject: Re: [PATCH 3/2] mount: Allow 'port=0' to be a valid port value.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D6FF466.2070004@RedHat.com>
Date: Thu, 3 Mar 2011 15:12:49 -0500
Cc: Karel Zak <kzak@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <0B360A89-0FE0-4DB9-92C4-0EE59B1C2B75@oracle.com>
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <4D6FF466.2070004@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

On Mar 3, 2011, at 3:04 PM, Steve Dickson wrote:

> With the new util-linux, /etc/mtab is now is symbolically linked
> to /proc/mounts. In /proc/mounts, the 'port=0' exits which causes
> the umount.nfs to error out with the following error:
>   umount.nfs: invalid value for 'port=' option
> 
> Setting port=0 is a valid value. It just means go out and query
> remote rpcbind to get the correct port.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

Why are you signing off on this?  I sent you this patch weeks ago.  (In fact my version of the patch also fixes this problem in nfs_mount_port() as well).

> ---
> utils/mount/network.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 8049c1a..88ab222 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1346,7 +1346,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
> 	case PO_NOT_FOUND:
> 		break;
> 	case PO_FOUND:
> -		if (tmp >= 1 && tmp <= 65535) {
> +		if (tmp >= 0 && tmp <= 65535) {
> 			*port = tmp;
> 			return 1;
> 		}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




