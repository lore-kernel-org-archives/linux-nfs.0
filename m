From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 2/4] Add /proc/sys/fs/nfs sysctls to nfs module
Date: Thu, 3 Aug 2006 09:49:16 -0700
Message-ID: <76bd70e30608030949gc1f1e0bw978dde7f198c42d8@mail.gmail.com>
References: <20060803110538.GA17168@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8gNt-0006Hx-FI
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 09:49:21 -0700
Received: from wr-out-0506.google.com ([64.233.184.225])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8gNt-0002uC-HR
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 09:49:22 -0700
Received: by wr-out-0506.google.com with SMTP id 69so481445wri
	for <nfs@lists.sourceforge.net>; Thu, 03 Aug 2006 09:49:18 -0700 (PDT)
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20060803110538.GA17168@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 8/3/06, Olaf Kirch <okir@suse.de> wrote:
> From: okir@suse.de
> Subject: Add /proc/sys/fs/nfs sysctls to nfs module
>
> This patch adds the plumbing for adding nfs-specific sysctls to
> fs/nfs, and makes nfs_max_readahead tunable as suggested.
>
> Signed-off-by: okir@suse.de
>
>  fs/nfs/inode.c |   48 +++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 41 insertions(+), 7 deletions(-)
>
> Index: linux-2.6.18/fs/nfs/inode.c
> ===================================================================
> --- linux-2.6.18.orig/fs/nfs/inode.c
> +++ linux-2.6.18/fs/nfs/inode.c
> @@ -33,6 +33,7 @@
>  #include <linux/lockd/bind.h>
>  #include <linux/smp_lock.h>
>  #include <linux/seq_file.h>
> +#include <linux/sysctl.h>
>  #include <linux/mount.h>
>  #include <linux/nfs_idmap.h>
>  #include <linux/vfs.h>
> @@ -48,13 +49,15 @@
>  #define NFSDBG_FACILITY                NFSDBG_VFS
>  #define NFS_PARANOIA 1
>
> -/* Maximum number of readahead requests
> - * FIXME: this should really be a sysctl so that users may tune it to suit
> - *        their needs. People that do NFS over a slow network, might for
> - *        instance want to reduce it to something closer to 1 for improved
> - *        interactive response.
> +/* Maximum number of readahead requests.
> + *
> + * People who do NFS over a slow network may want to reduce it to
> + * something closer to 1 for improved interactive response.
>   */
> -#define NFS_MAX_READAHEAD      (RPC_DEF_SLOT_TABLE - 1)
> +static unsigned int    nfs_max_readahead = RPC_DEF_SLOT_TABLE - 1;
> +static unsigned int    nfs_max_readahead_min = 0;
> +static unsigned int    nfs_max_readahead_max = RPC_MAX_SLOT_TABLE - 1;
> +
>
>  static void nfs_invalidate_inode(struct inode *);
>  static int nfs_update_inode(struct inode *, struct nfs_fattr *);
> @@ -341,7 +344,7 @@ nfs_sb_init(struct super_block *sb, rpc_
>                 server->acdirmin = server->acdirmax = 0;
>                 sb->s_flags |= MS_SYNCHRONOUS;
>         }
> -       server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
> +       server->backing_dev_info.ra_pages = server->rpages * nfs_max_readahead;
>
>         sb->s_maxbytes = fsinfo.maxfilesize;
>         if (sb->s_maxbytes > MAX_LFS_FILESIZE)
> @@ -2289,12 +2292,35 @@ static void nfs_destroy_inodecache(void)
>  }
>
>  /*
> + * NFS sysctls
> + */
> +static struct ctl_table_header *nfs_sysctl_table;
> +
> +static ctl_table nfs_sysctls[] = {
> +       {
> +               .ctl_name       = -2,
> +               .procname       = "nfs_max_readahead",
> +               .data           = &nfs_max_readahead,
> +               .maxlen         = sizeof(unsigned int),
> +               .mode           = 0644,
> +               .proc_handler   = &proc_dointvec_minmax,
> +               .strategy       = &sysctl_intvec,
> +               .extra1         = &nfs_max_readahead_min,
> +               .extra2         = &nfs_max_readahead_max
> +       },
> +       { .ctl_name = 0 }
> +};
> +
> +/*
>   * Initialize NFS
>   */
>  static int __init init_nfs_fs(void)
>  {
> +       struct ctl_path ctl_path[] = { { CTL_FS, "fs", 0555 }, { -2, "nfs", 0555 }, { 0 } };
>         int err;
>
> +       nfs_sysctl_table = register_sysctl_table_path(nfs_sysctls, ctl_path);
> +
>         err = nfs_init_nfspagecache();
>         if (err)
>                 goto out4;
> @@ -2342,6 +2368,10 @@ out2:
>  out3:
>         nfs_destroy_nfspagecache();
>  out4:
> +       if (nfs_sysctl_table)
> +               unregister_sysctl_table(nfs_sysctl_table);
> +       nfs_sysctl_table = NULL;
> +
>         return err;
>  }
>
> @@ -2359,6 +2389,10 @@ static void __exit exit_nfs_fs(void)
>  #endif
>         unregister_filesystem(&nfs_fs_type);
>         unregister_nfs4fs();
> +
> +       if (nfs_sysctl_table)
> +               unregister_sysctl_table(nfs_sysctl_table);
> +       nfs_sysctl_table = NULL;
>  }
>
>  /* Not quite true; I just maintain it */

At first I saw this and thought "coolness!"  Then the caffeine takes effect....

Do you have any performance measurements that suggest the default is
not "good enough"?
Have you found particular settings that have a positive (or negative)
impact for particular workloads?

Generally I've found that on systems where you want to tune
read-ahead, you need different settings for different mount points.
Fortunately we already have the ability to tune read-ahead behavior on
a per-file basis via madvise() and posix_fadvise(), which is probably
the most flexible approach for basing read-ahead on application
behavior.  But we also need to tune it based on how far away the
server is -- if read latency is high, generally more read-ahead is
desired.

I don't like the 2.6 method of providing the read-ahead parameters to
the VFS.  It's very block-file-system centric.  Distributed file
systems don't use block devices, but do still need read-ahead; so to
use the 2.6 read-ahead mechanism, they have to provide a dummy backing
device.  This method also doesn't allow unique read-ahead values for
each mount point.

The slot table size is actually no longer fixed (there is a sysctl
that changes it).  I even have patches that eliminate the slot table
entirely.  In that case, how should we determine the maximum (or even
the default) read-ahead value for NFS mounts?

I think it was Neil or Greg who recently said that adding more
tunables often brings more pain than gain.  I'm certainly not against
exploring read-ahead behavior, but I'd love to see a lot more testing
before we decide providing a single tunable is the best approach.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
