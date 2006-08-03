From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Thu, 3 Aug 2006 09:52:20 -0700
Message-ID: <76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
References: <20060803110538.GA17173@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8gQu-0006YW-Tq
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 09:52:38 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8gQu-0002KW-U2
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 09:52:29 -0700
Received: by nf-out-0910.google.com with SMTP id l36so928909nfa
	for <nfs@lists.sourceforge.net>; Thu, 03 Aug 2006 09:52:21 -0700 (PDT)
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20060803110538.GA17173@suse.de>
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
> Subject: Add /proc/sys/fs/nfs sysctls to nfsd module
>
>   This patch adds the plumbing for adding nfs-specific sysctls to fs/nfs,
>   and makes the max size of a readdirplus reply tunable.
>
>   The reason for this is that we found that some clients do not seem
>   to grok readdirplus replies larger than 4K. Rather than reducing the
>   overall number this sysctl allows admins to work around these clients.
>
> Signed-off-by: Olaf Kirch <okir@suse.de>
>
>  fs/nfsd/nfs3xdr.c         |    5 ++++-
>  fs/nfsd/nfsctl.c          |   28 ++++++++++++++++++++++++++++
>  include/linux/nfsd/xdr3.h |    4 ++++
>  3 files changed, 36 insertions(+), 1 deletion(-)
>
> Index: linux-2.6.18/fs/nfsd/nfsctl.c
> ===================================================================
> --- linux-2.6.18.orig/fs/nfsd/nfsctl.c
> +++ linux-2.6.18/fs/nfsd/nfsctl.c
> @@ -31,6 +31,7 @@
>  #include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/cache.h>
>  #include <linux/nfsd/xdr.h>
> +#include <linux/nfsd/xdr3.h>
>  #include <linux/nfsd/syscall.h>
>  #include <linux/nfsd/interface.h>
>
> @@ -507,8 +508,28 @@ static struct file_system_type nfsd_fs_t
>         .kill_sb        = kill_litter_super,
>  };
>
> + /*
> + * NFS sysctls
> + */
> +static struct ctl_table_header *nfsd_sysctl_table;
> +
> +static ctl_table nfsd_sysctls[] = {
> +       {
> +               .ctl_name       = -2,
> +               .procname       = "nfsd_readdirplus_max",
> +               .data           = &nfsd_readdirplus_max,
> +               .maxlen         = sizeof(nfsd_readdirplus_max),
> +               .mode           = 0644,
> +               .proc_handler   = &proc_dointvec_minmax,
> +               .extra1         = &nfsd_readdirplus_max_lb,
> +               .extra2         = &nfsd_readdirplus_max_ub,
> +       },
> +       { .ctl_name = 0 }
> +};
> +
>  static int __init init_nfsd(void)
>  {
> +       struct ctl_path ctl_path[] = { { CTL_FS, "fs", 0555 }, { -2, "nfs", 0555 }, { 0 } };
>         int retval;
>         printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
>
> @@ -518,6 +539,7 @@ static int __init init_nfsd(void)
>         nfsd_lockd_init();      /* lockd->nfsd callbacks */
>         nfs4_state_init();      /* NFSv4 locking state */
>         nfsd_idmap_init();      /* Name to ID mapping */
> +       nfsd_sysctl_table = register_sysctl_table_path(nfsd_sysctls, ctl_path);
>         if (proc_mkdir("fs/nfs", NULL)) {
>                 struct proc_dir_entry *entry;
>                 entry = create_proc_entry("fs/nfs/exports", 0, NULL);
> @@ -532,6 +554,9 @@ static int __init init_nfsd(void)
>                 remove_proc_entry("fs/nfs", NULL);
>                 nfsd_stat_shutdown();
>                 nfsd_lockd_shutdown();
> +               if (nfsd_sysctl_table)
> +                       unregister_sysctl_table(nfsd_sysctl_table);
> +               nfsd_sysctl_table = NULL;
>         }
>         return retval;
>  }
> @@ -546,6 +571,9 @@ static void __exit exit_nfsd(void)
>         nfsd_lockd_shutdown();
>         nfsd_idmap_shutdown();
>         unregister_filesystem(&nfsd_fs_type);
> +       if (nfsd_sysctl_table)
> +               unregister_sysctl_table(nfsd_sysctl_table);
> +       nfsd_sysctl_table = NULL;
>  }
>
>  MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
> Index: linux-2.6.18/fs/nfsd/nfs3xdr.c
> ===================================================================
> --- linux-2.6.18.orig/fs/nfsd/nfs3xdr.c
> +++ linux-2.6.18/fs/nfsd/nfs3xdr.c
> @@ -28,6 +28,9 @@
>  # define inline
>  #endif
>
> +unsigned int   nfsd_readdirplus_max = NFSSVC_MAXBLKSIZE;
> +unsigned int   nfsd_readdirplus_max_lb = 512;
> +unsigned int   nfsd_readdirplus_max_ub = NFSSVC_MAXBLKSIZE;
>
>  /*
>   * Mapping of S_IF* types to NFS file types
> @@ -573,7 +576,7 @@ nfs3svc_decode_readdirplusargs(struct sv
>         args->dircount = ntohl(*p++);
>         args->count    = ntohl(*p++);
>
> -       len = (args->count > NFSSVC_MAXBLKSIZE) ? NFSSVC_MAXBLKSIZE :
> +       len = (args->count > nfsd_readdirplus_max) ? nfsd_readdirplus_max :
>                                                   args->count;
>         args->count = len;
>
> Index: linux-2.6.18/include/linux/nfsd/xdr3.h
> ===================================================================
> --- linux-2.6.18.orig/include/linux/nfsd/xdr3.h
> +++ linux-2.6.18/include/linux/nfsd/xdr3.h
> @@ -268,6 +268,10 @@ union nfsd3_xdrstore {
>
>  #define NFS3_SVC_XDRSIZE               sizeof(union nfsd3_xdrstore)
>
> +extern unsigned int                    nfsd_readdirplus_max;
> +extern unsigned int                    nfsd_readdirplus_max_ub;
> +extern unsigned int                    nfsd_readdirplus_max_lb;
> +
>  int nfs3svc_decode_fhandle(struct svc_rqst *, u32 *, struct nfsd_fhandle *);
>  int nfs3svc_decode_sattrargs(struct svc_rqst *, u32 *,
>                                 struct nfsd3_sattrargs *);

I don't recall the history of /proc/sys/fs -- is there also a
/proc/sys/fs/nfsd directory, and wouldn't it be better to add this
particular sysctl in there?

Any thoughts about providing a mechanism for tuning or disabling
readdirplus on the client as well?  If we provided such a mechanism,
would it not collide with the server tunable in /proc/sys/fs/nfs ?

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
