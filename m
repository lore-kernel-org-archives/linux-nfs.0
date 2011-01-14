Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64213 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab1ANITI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 03:19:08 -0500
Message-ID: <4D3007A1.6030405@cn.fujitsu.com>
Date: Fri, 14 Jan 2011 16:21:53 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: break lease on unlink, link, and rename
References: <1294853809-10732-1-git-send-email-bfields@redhat.com> <1294853809-10732-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294853809-10732-3-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> Any change to any of the links pointing to an entry should also break
> delegations.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/vfs.c |   27 +++++++++++++++++++++++----
>  1 files changed, 23 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 839ed88..f31321a 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -272,6 +272,13 @@ out:
>  	return err;
>  }
>  
> +static int nfsd_break_lease(struct inode *inode)
> +{
> +	if (!S_ISREG(inode->i_mode))
> +		return 0;
> +	return break_lease(inode, O_WRONLY | O_NONBLOCK);

Hi Bruce,

break_lease will return -EWOULDBLOCK here if break success, not 0.
  at __break_lease:
   
    1193  */
    1194 int __break_lease(struct inode *inode, unsigned int mode)
    1195 {
         ... ...  
    1253         if (i_have_this_lease || (mode & O_NONBLOCK)) {
    1254                 error = -EWOULDBLOCK;
    1255                 goto out;
    1256         }
          ... ... 
    1283 out:
    1284         unlock_flocks();
    1285         if (!IS_ERR(new_fl))
    1286                 locks_free_lock(new_fl);
    1287         return error;
    1288 }

If we just return the error -EWOULDBLOCK (which mapped to -EAGAIN) at
nfsd_break_lease(), the NFS request will be drop for -EAGAIN is mapped
to nfserr_dropit at nfserrno(). As that, client will hang up about 60s
until a retry success.

Maybe we should have a check here as:

-       return break_lease(inode, O_WRONLY | O_NONBLOCK);
+       int status = break_lease(inode, O_WRONLY | O_NONBLOCK);
+       return -EWOULDBLOCK == status ? 0 : status;

-- 
----
thanks
Mi Jinlong


