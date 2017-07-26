Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdGZFCU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jul 2017 01:02:20 -0400
Date: Wed, 26 Jul 2017 13:02:18 +0800
From: Eryu Guan <eguan@redhat.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [4.13-rc2 regression] NFSv4 fails file permission tests in
 fstests generic/126
Message-ID: <20170726050218.GS9167@eguan.usersys.redhat.com>
References: <20170724141935.GF9167@eguan.usersys.redhat.com>
 <2a18fac0-1b5c-e3d7-43b6-d932709e7655@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2a18fac0-1b5c-e3d7-43b6-d932709e7655@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:52:36PM -0400, Anna Schumaker wrote:
> Hi Eryu,
> 
> On 07/24/2017 10:19 AM, Eryu Guan wrote:
> > Hi all,
> > 
> > I saw a new NFS failure in 4.13-rc2 kernel when running fstests
> > generic/126 on NFSv4 mounts, 4.13-rc1 kernel passed the same test.
> > 
> > git bisect pointed the first bad to commit bd8b2441742b.
> > 
> > commit bd8b2441742b49c76bec707757bd9c028ea9838e
> > Author: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date:   Tue Jul 11 17:54:34 2017 -0400
> > 
> >     NFS: Store the raw NFS access mask in the inode's access cache
> >     
> >     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > 
> > I can reproduce it manually with these steps:
> > 
> > mount -t nfs -o vers=4.1 server:/export /mnt/nfs
> > cp /usr/bin/ls /mnt/nfs
> > chmod 001 /mnt/nfs/ls
> > chown 99:99 /mnt/nfs/ls
> > su testuser -c "/mnt/nfs/ls"
> > 
> > (testuser uid and gid are not 99.)
> > 
> > The last command got permission denied with 4.13-rc2.
> 
> Thanks for letting me know!  I think I see the problem: the patch changed how the
> access system call is cached but didn't update caching for NFSv4 opens (which is why
> v3 still passes).  Does this patch help?

Yes, this patch solved generic/126 failure, I tested with nfsv4.0/1/2
and nfsv3, all passed now. But I didn't do further tests against this
patch.

Thanks!

Eryu

> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e1a26c653e78..4893c9f9829b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2250,16 +2250,16 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
>          */
>         if (openflags & __FMODE_EXEC) {
>                 /* ONLY check for exec rights */
> -               mask = MAY_EXEC;
> +               mask = NFS4_ACCESS_EXECUTE;
>         } else if ((fmode & FMODE_READ) && !opendata->file_created)
> -               mask = MAY_READ;
> +               mask = NFS4_ACCESS_READ;
>  
>         cache.cred = cred;
>         cache.jiffies = jiffies;
>         nfs_access_set_mask(&cache, opendata->o_res.access_result);
>         nfs_access_add_cache(state->inode, &cache);
>  
> -       if ((mask & ~cache.mask & (MAY_READ | MAY_EXEC)) == 0)
> +       if ((mask & ~cache.mask & (NFS4_ACCESS_READ | NFS4_ACCESS_EXECUTE)) == 0)
>                 return 0;
>  
>         return -EACCES;
> 
> 
> > 
> > Thanks,
> > Eryu
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
