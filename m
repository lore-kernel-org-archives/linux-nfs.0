Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52005 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbcFTPJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 11:09:07 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] NFS: Trim extra slash in v4 nfs_path
To: Benjamin Coddington <bcodding@redhat.com>, <linux-nfs@vger.kernel.org>
References: <1cb38ee043176bca8ded7e18120776f8cf6a722d.1466017326.git.bcodding@redhat.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-ID: <f4f47844-5a28-acbc-0779-fcd66ea6c028@Netapp.com>
Date: Mon, 20 Jun 2016 11:08:09 -0400
MIME-Version: 1.0
In-Reply-To: <1cb38ee043176bca8ded7e18120776f8cf6a722d.1466017326.git.bcodding@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On 06/15/2016 03:02 PM, Benjamin Coddington wrote:
> A NFSv4 mount of a subdirectory will show an extra slash (as in
> 'server://path') in proc's mountinfo which will not match the device name
> and path.  This can cause problems for programs searching for the mount.
> Fix this by checking for a leading slash in the dentry path, if so trim
> away any trailing slashes in the device name.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
> index c8162c660c44..5551e8ef67fd 100644
> --- a/fs/nfs/namespace.c
> +++ b/fs/nfs/namespace.c
> @@ -98,7 +98,7 @@ rename_retry:
>  		return end;
>  	}
>  	namelen = strlen(base);
> -	if (flags & NFS_PATH_CANONICAL) {
> +	if (*end == '/') {

Are we getting here through nfs_show_devname()?  Because it looks like that function is passing 0 for flags instead of NFS_PATH_CANONICAL.

Earlier in this function we have a check for:
    if ((flags & NFS_PATH_CANONICAL) && *end != '/')

Should we be checking if NFS_PATH_CANONICAL is set here, too?

Thanks,
Anna

>  		/* Strip off excess slashes in base string */
>  		while (namelen > 0 && base[namelen - 1] == '/')
>  			namelen--;
> 

