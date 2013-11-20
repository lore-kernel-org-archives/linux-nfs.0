Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab3KTVVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:21:44 -0500
Message-ID: <528D2829.5090902@RedHat.com>
Date: Wed, 20 Nov 2013 16:22:49 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: Recognize v4.x mount options
References: <1384355662-70913-1-git-send-email-dros@netapp.com>
In-Reply-To: <1384355662-70913-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/11/13 10:14, Weston Andros Adamson wrote:
> The kernel understands text options of the form "v4.x" (ie "v4.1"), but
> mount.nfs does not and this leads to weird errors when the requested
> mount fails: a line in dmesg about version 3 not supporting minorversions
> and mount.nfs returning EINVAL no matter what the real error was.
> 
> This happens because mount.nfs thinks no version was specified so it starts
> probing other versions which conflicts with the v4.X option once it gets
> parsed by the kernel.
> 
> $ sudo mount -v -o v4.1 zero:/invalid_export /mnt
> mount.nfs: timeout set for Wed Nov 13 10:09:48 2013
> mount.nfs: trying text-based options 'v4.1,vers=4,addr=192.168.100.10,clientaddr=192.168.100.11'
> mount.nfs: mount(2): No such file or directory
> mount.nfs: trying text-based options 'v4.1,addr=192.168.100.10'
> mount.nfs: prog 100003, trying vers=3, prot=6
> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: prog 100005, trying vers=3, prot=17
> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
> mount.nfs: mount(2): Invalid argument
> mount.nfs: an incorrect mount option was specified
> 
> And you get this in dmesg:
> 
> NFS: mount option vers=3 does not support minorversion=1
> 
> but if you use another form of the same options, this doesn't happen:
> 
> $ sudo mount -v -o vers=4,minorversion=1 zero:/invalid_export /mnt
> mount.nfs: timeout set for Wed Nov 13 10:10:28 2013
> mount.nfs: trying text-based options 'vers=4,minorversion=1,addr=192.168.100.10,clientaddr=192.168.100.11'
> mount.nfs: mount(2): No such file or directory
> mount.nfs: mounting zero:/invalid_export failed, reason given by server: No such file or directory
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Committed (tag: nfs-utils-1-2-10-rc1)

steved.

> ---
>  utils/mount/network.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index e8e55a5..2853d00 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -92,6 +92,9 @@ static const char *nfs_version_opttbl[] = {
>  	"v4",
>  	"vers",
>  	"nfsvers",
> +	"v4.0",
> +	"v4.1",
> +	"v4.2",
>  	NULL,
>  };
>  
> @@ -1269,6 +1272,11 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
>  					progname);
>  			return 0;
>  		}
> +	case 5: /* v4.0 */
> +	case 6: /* v4.1 */
> +	case 7: /* v4.2 */
> +		*version = 4;
> +		return 1;
>  	}
>  
>  	/*
> 
