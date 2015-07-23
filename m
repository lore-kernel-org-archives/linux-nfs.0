Return-Path: <Anna.Schumaker@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] NFSv4.2: handle NFS-specific llseek errors
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust
	<trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
References: <20150723150843.GA12894@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, Benjamin Coddington <bcodding@redhat.com>
Message-ID: <55B10763.3020203@Netapp.com>
Date: Thu, 23 Jul 2015 11:25:23 -0400
MIME-Version: 1.0
In-Reply-To: <20150723150843.GA12894@fieldses.org>
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On 07/23/2015 11:08 AM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Handle NFS-specific llseek errors instead of letting them leak out to
> userspace.
> 
> Reported-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfs/nfs42proc.c | 19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> I don't actually have a test case for this, but it looks right....
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index f486b80f927a..2fec410bc50f 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -135,7 +135,7 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
>  	return err;
>  }
>  
> -loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> +loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
>  {
>  	struct inode *inode = file_inode(filep);
>  	struct nfs42_seek_args args = {
> @@ -171,6 +171,23 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
>  	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
>  }
>  
> +loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> +{
> +	struct nfs_server *server = NFS_SERVER(file_inode(filep));
> +	struct nfs4_exception exception = { };
> +	int err;

Can you move the nfs_server_capable() check to before the do {} while loop?  I think it's cleaner if we check for support before ever trying to call _nfs42_proc_llseek().

> +
> +	do {
> +		err = _nfs42_proc_llseek(filep, offset, whence);
> +		if (err == -ENOTSUPP)
> +			return -EOPNOTSUPP;

With the change to check support moved to this function, we should also unset NFS_CAP_SEEK if we see -ENOTSUPP here.  I think you'll also need to change nfs4_file_llseek() (in nfs4file.c) to check for -EOPNOTSUPP instead of -ENOTSUPP.

Thanks,
Anna

> +		err = nfs4_handle_exception(server, err, &exception);
> +	} while (exception.retry);
> +
> +	return err;
> +}
> +
> +
>  static void
>  nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
>  {
> 
