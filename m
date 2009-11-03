From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC] [PATCH] mount.nfs: Retry v4 mounts with v3 on ENOENT errors
Date: Tue, 03 Nov 2009 08:16:10 -0500
Message-ID: <4AF02D1A.3060500@RedHat.com>
References: <4ADDCB52.2050906@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4ADDCB52.2050906@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/20/2009 10:38 AM, Steve Dickson wrote:
> I'm trying to convince myself this is a good idea... 
> 
> It would definitely help with the v3 to v4 transition
> in the Linux community, but at the end of the day, 
> Linux servers that numerous compared to other types 
> of server so its not clear this will not cause other 
> problems...
> 
> Comments? Suggestions?
> 
> steved.
> 
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Oct 20 10:25:34 EDT 2009
> 
>     Retry v4 mounts with a v3 mount when the version
>     is not explicitly specified and the mount fails 
>     with ENOENT. The will help deal with Linux servers
>     that do not automatically export a pseudo root
> 
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff -up nfs-utils-1.2.0/utils/mount/stropts.c.orig nfs-utils-1.2.0/utils/mount/stropts.c
> --- nfs-utils-1.2.0/utils/mount/stropts.c.orig	2009-10-20 10:11:03.000000000 -0400
> +++ nfs-utils-1.2.0/utils/mount/stropts.c	2009-10-20 10:24:41.000000000 -0400
> @@ -613,8 +613,15 @@ static int nfs_try_mount(struct nfsmount
>  		if (linux_version_code() > MAKE_VERSION(2, 6, 31)) {
>  			errno = 0;
>  			result = nfs_try_mount_v4(mi);
> -			if (errno != EPROTONOSUPPORT)
> -				break;
> +			if (errno != EPROTONOSUPPORT) {
> +				/* 
> +				 * To deal with legacy Linux servers that don't
> +				 * automatically export a pseudo root, retry
> +				 * ENOENT errors using version 3
> +				 */
> +				if (errno != ENOENT)
> +					break;
> +			}
>  		}
>  	case 2:
>  	case 3:
I am going to go ahead an commit this and then cut a release. I 
was waiting to include the server side dynamic pseudo root support, 
but it appears that will not happen in a timely matter... 

After this release, I will actively start catching up on the backlog
of purposed patches... Thank you for your patiences....  

steved.
