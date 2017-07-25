Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38082 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdGYTwj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jul 2017 15:52:39 -0400
Received: by mail-io0-f195.google.com with SMTP id l7so9936147iof.5
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jul 2017 12:52:39 -0700 (PDT)
Subject: Re: [4.13-rc2 regression] NFSv4 fails file permission tests in
 fstests generic/126
To: Eryu Guan <eguan@redhat.com>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
References: <20170724141935.GF9167@eguan.usersys.redhat.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <2a18fac0-1b5c-e3d7-43b6-d932709e7655@gmail.com>
Date: Tue, 25 Jul 2017 15:52:36 -0400
MIME-Version: 1.0
In-Reply-To: <20170724141935.GF9167@eguan.usersys.redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Eryu,

On 07/24/2017 10:19 AM, Eryu Guan wrote:
> Hi all,
> 
> I saw a new NFS failure in 4.13-rc2 kernel when running fstests
> generic/126 on NFSv4 mounts, 4.13-rc1 kernel passed the same test.
> 
> git bisect pointed the first bad to commit bd8b2441742b.
> 
> commit bd8b2441742b49c76bec707757bd9c028ea9838e
> Author: Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   Tue Jul 11 17:54:34 2017 -0400
> 
>     NFS: Store the raw NFS access mask in the inode's access cache
>     
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> I can reproduce it manually with these steps:
> 
> mount -t nfs -o vers=4.1 server:/export /mnt/nfs
> cp /usr/bin/ls /mnt/nfs
> chmod 001 /mnt/nfs/ls
> chown 99:99 /mnt/nfs/ls
> su testuser -c "/mnt/nfs/ls"
> 
> (testuser uid and gid are not 99.)
> 
> The last command got permission denied with 4.13-rc2.

Thanks for letting me know!  I think I see the problem: the patch changed how the
access system call is cached but didn't update caching for NFSv4 opens (which is why
v3 still passes).  Does this patch help?


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1a26c653e78..4893c9f9829b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2250,16 +2250,16 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
         */
        if (openflags & __FMODE_EXEC) {
                /* ONLY check for exec rights */
-               mask = MAY_EXEC;
+               mask = NFS4_ACCESS_EXECUTE;
        } else if ((fmode & FMODE_READ) && !opendata->file_created)
-               mask = MAY_READ;
+               mask = NFS4_ACCESS_READ;
 
        cache.cred = cred;
        cache.jiffies = jiffies;
        nfs_access_set_mask(&cache, opendata->o_res.access_result);
        nfs_access_add_cache(state->inode, &cache);
 
-       if ((mask & ~cache.mask & (MAY_READ | MAY_EXEC)) == 0)
+       if ((mask & ~cache.mask & (NFS4_ACCESS_READ | NFS4_ACCESS_EXECUTE)) == 0)
                return 0;
 
        return -EACCES;


> 
> Thanks,
> Eryu
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
