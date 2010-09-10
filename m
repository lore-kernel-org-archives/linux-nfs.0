Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59709 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045Ab0IJEZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 00:25:05 -0400
Date: Fri, 10 Sep 2010 14:24:56 +1000
From: Neil Brown <neilb@suse.de>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make
 locks local
Message-ID: <20100910142456.387c9fbb@notabene>
In-Reply-To: <4C89AF05.408@suse.de>
References: <4C893746.6090202@suse.de>
	<20100909162037.20c4ebec@tlielax.poochiereds.net>
	<4C896A59.8060903@suse.de>
	<1284083063.2764.12.camel@heimdal.trondhjem.org>
	<4C89AF05.408@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 10 Sep 2010 09:37:33 +0530
Suresh Jayaraman <sjayaraman@suse.de> wrote:

> On 09/10/2010 07:14 AM, Trond Myklebust wrote:
> > On Fri, 2010-09-10 at 04:44 +0530, Suresh Jayaraman wrote:
> >> On 09/10/2010 01:50 AM, Jeff Layton wrote:
> >>> On Fri, 10 Sep 2010 01:06:38 +0530
> >>> Suresh Jayaraman <sjayaraman@suse.de> wrote:
> >>>
> >>>> NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
> >>>> locks. Due to this, some windows applications which seem to use both flock
> >>>> (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
> >>>> the same file, can't lock as they falsely assume the file is already locked.
> >>>> The problem was reported on a setup with windows clients accessing excel files
> >>>> on a Samba exported share which is originally a NFS mount from a NetApp filer.
> >>>>
> >>>> Older NFS clients (< 2.6.12) did not see this problem as flock locks were
> >>>> considered local. To support legacy flock behavior, this patch adds a mount
> >>>> option "-olocal_lock=" which can take the following values:
> >>>>
> >>>>    'none'  		- Neither flock locks or fcntl/posix locks are local
> >>>>    'flock'/'posix' 	- flock locks are local
> >>> 	^^^^^^^
> >>> "posix" ought to be synonymous with "fcntl". "flock" was a BSD-ism.
> >>
> >> Oops, that should have read 'fcntl/posix' (though the code gets it right)..
> > 
> > Yup. It appears to be a changelog bug...
> > 
> >>> It may be better to keep it simple though and drop either "posix" or
> >>> "fcntl". No need to add unneeded synonyms on a brand new mount option.
> >>
> >> Makes sense.. Trond: which one is more consistent?
> > 
> > I have a slight preference for 'posix'. fcntl is an extensible
> 
> Ok, how about this one?
> 
> ---
> From: Suresh Jayaraman <sjayaraman@suse.de>
> Subject: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks local
> 
> NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
> locks. Due to this, some windows applications which seem to use both flock
> (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
> the same file, can't lock as they falsely assume the file is already locked.
> The problem was reported on a setup with windows clients accessing excel files
> on a Samba exported share which is originally a NFS mount from a NetApp filer.
> 
> Older NFS clients (< 2.6.12) did not see this problem as flock locks were
> considered local. To support legacy flock behavior, this patch adds a mount
> option "-olocal_lock=" which can take the following values:
> 
>    'none'  		- Neither flock locks nor POSIX locks are local
>    'flock' 		- flock locks are local
>    'posix' 		- fcntl/POSIX locks are local
>    'all'		- Both flock locks and POSIX locks are local
> 
> Testing:
> 
> This patch was tested by using -olocal_lock option with different values and
> the NLM calls were noted from the network packet captured.
> 
>    'none'  - NLM calls were seen during both flock() and fcntl(), flock lock
>    	     was granted, fcntl was denied
>    'flock' - no NLM calls for flock(), NLM call was seen for fcntl(),
>    	     granted
>    'posix' - NLM call was seen for flock() - granted, no NLM call for fcntl()
>    'all'   - no NLM calls were seen during both flock() and fcntl()
> 
> Cc: Neil Brown <neilb@suse.de>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
>  fs/nfs/client.c           |    6 +++-
>  fs/nfs/file.c             |   35 +++++++++++++++++++++++----------
>  fs/nfs/super.c            |   46 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs_mount.h |    5 +++-
>  4 files changed, 78 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 4e7df2a..5f01f42 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -635,7 +635,8 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
>   */
>  static void nfs_destroy_server(struct nfs_server *server)
>  {
> -	if (!(server->flags & NFS_MOUNT_NONLM))
> +	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
> +			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>  		nlmclnt_done(server->nlm_host);
>  }
>  
> @@ -657,7 +658,8 @@ static int nfs_start_lockd(struct nfs_server *server)
>  
>  	if (nlm_init.nfs_version > 3)
>  		return 0;
> -	if (server->flags & NFS_MOUNT_NONLM)
> +	if ((server->flags & NFS_MOUNT_LOCAL_FLOCK) &&
> +			(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>  		return 0;
>  
>  	switch (clp->cl_proto) {
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index eb51bd6..e338d37 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -684,7 +684,8 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>  	return ret;
>  }
>  
> -static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
> +static int
> +do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int status = 0;
> @@ -699,7 +700,7 @@ static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
>  	if (nfs_have_delegation(inode, FMODE_READ))
>  		goto out_noconflict;
>  
> -	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) || is_local)
>  		goto out_noconflict;

I cannot figure out why this isn't simply
        if (is_local)
		goto out_noconflict;

what am I missing?

Thanks,
NeilBrown
