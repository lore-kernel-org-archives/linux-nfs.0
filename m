From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] NFSD: fix wrong mnt_writer count in rename (MMOTM
	2007-11-10-19-05)
Date: Tue, 13 Nov 2007 09:39:41 -0800
Message-ID: <1194975581.7078.144.camel@localhost>
References: <200711130115.lAD1FBfG015626@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759243AbXKMRkI@vger.kernel.org>
In-Reply-To: <200711130115.lAD1FBfG015626@agora.fsl.cs.sunysb.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2007-11-12 at 20:15 -0500, Erez Zadok wrote:
> NFSD forgets to call mnt_drop_write after a successful rename.  Here's a
> fix.  (Ah, the curse of a stackable file system developer: you have to debug
> everyone else's too. :-)
> 
> One thing I wasn't sure is whether I could move the mnt_drop_write line a
> little above, just after the call to vfs_rename.  If we can drop the ref
> earlier, it could improve scalability/performance just a bit, no? (i.e.,
> what are the ramifications of holding on to this mnt writer ref longer than
> needed?)

I do see some write-ish things happening inside of the nfsd_sync_dir()
call chain: the fsync() and filemap_fdatawrite().

The danger here is that the moment you mnt_drop_write(), the filesystem
is mounted r/o by someone else, then those fsync() writes occur when
everyone thinks it is r/o.  So, I think your fix is the most
conservative, and the most correct.

> Signed-off-by: Erez Zadok <ezk@cs.sunysb.edu>
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 7dfde65..47aec49 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1693,6 +1693,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  		if (!host_err)
>  			host_err = nfsd_sync_dir(fdentry);
>  	}
> +	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
> 
>   out_dput_new:
>  	dput(ndentry);

Otherwise, looks good to me.  Thanks.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

-- Dave
