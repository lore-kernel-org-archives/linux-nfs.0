From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: inux-next: Tree for July 1
Date: Tue, 1 Jul 2008 20:32:11 -0700
Message-ID: <20080701203211.95244ebd.rdunlap@xenotime.net>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au>
	<200807012236.19400.rjw@sisk.pl>
	<1214959743.10317.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <kernel-testers-owner@vger.kernel.org>
In-Reply-To: <1214959743.10317.3.camel@localhost>
Sender: kernel-testers-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 01 Jul 2008 20:49:03 -0400 Trond Myklebust wrote:

> On Tue, 2008-07-01 at 22:36 +0200, Rafael J. Wysocki wrote:
> > I can't mount NFS shares with this kernel.  I get something of this sort in
> > dmesg and it seems to be 100% reproducible:
> > 
> > [  314.058858] RPC: Registered udp transport module.
> > [  314.058863] RPC: Registered tcp transport module.
> > [  314.490970] RPC: transport (0) not supported
> > [  319.246987] __ratelimit: 23 messages suppressed
> 
> Does this patch fix the problem for you?

Yes.  Thanks.


> -----------------------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> NFS: Fix the mount protocol defaults for binary mounts
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/super.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index e09b1c2..85fbb98 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1575,6 +1575,7 @@ static int nfs_validate_mount_data(void *options,
>  
>  		if (!(data->flags & NFS_MOUNT_TCP))
>  			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> +		nfs_set_transport_defaults(args);
>  		/* N.B. caller will free nfs_server.hostname in all cases */
>  		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
>  		args->namlen		= data->namlen;
> 
> 
> -- 

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
