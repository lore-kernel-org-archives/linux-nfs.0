From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 09:29:47 -0500
Message-ID: <4B0BEDDB.1010203@RedHat.com>
References: <19211.7054.291514.185591@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932972AbZKXO3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 09:29:43 -0500
In-Reply-To: <19211.7054.291514.185591-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2009 06:32 PM, Neil Brown wrote:
> 
> Hi,
>  I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
>  got a bug report - "-o nfsvers=3" was needed to mount NFSv3
>  filesystems.
> 
>  mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
>  if it gets ENOENT.  This works fine.
>  However for kernel prior to 2.6.25, you don't get ENOENT, you get
>  EPERM.
>  In that case the fall-back to v3 doesn't happen and you get a failure
>  to mount.
> 
>  So I think we need to fall back on EPERM as well.  See below.
I already posted this patch on the v4 mailing list
http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
but it got shot down...  at least that's how I interpreted the
responses... 

But I do thing we need this, since there are so many server 
that will simple break if we don't... Agreed?

steved. 


> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index b595649..68eb82b 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -657,8 +657,10 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>  				 * To deal with legacy Linux servers that don't
>  				 * automatically export a pseudo root, retry
>  				 * ENOENT errors using version 3
> +				 * And for Linux servers prior to 2.6.25, retry
> +				 * EPERM
>  				 */
> -				if (errno != ENOENT)
> +				if (errno != ENOENT && errno != EPERM)
>  					break;
>  			}
>  		}
