From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS Client mounts hang when exported directory do not
 exist
Date: Fri, 11 Apr 2008 12:22:04 -0400
Message-ID: <47FF902C.40301@oracle.com>
References: <47FF7FCC.2050403@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070801090407090903050202"
Cc: Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <fedora-kernel-list-bounces@redhat.com>
In-Reply-To: <47FF7FCC.2050403-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-kernel-list>
List-Post: <mailto:fedora-kernel-list@redhat.com>
List-Help: <mailto:fedora-kernel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=subscribe>
Sender: fedora-kernel-list-bounces@redhat.com
Errors-To: fedora-kernel-list-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070801090407090903050202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> This patch fixes a regression that was introduced by the string based mounts. 
> 
> nfs_mount() statically returns -EACCES for every error returned
> by the remote mounted. This is incorrect because -EACCES is
> an non-fatal error to the mount.nfs command. This error causes
> mount.nfs to retry the mount even in the case when the exported
> directory does not exist. 

I don't doubt this is the case, but I'd like to see a few real world 
examples (maybe even add them as documentary comments in mount.nfs or in 
the kernel).

> This patch maps the errors returned by the remote mountd into
> valid errno values, exactly how it was done pre-string based 
> mounts. By returning the correct errno enables mount.nfs 
> to do the right thing.  
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> 
> diff -up linux/fs/nfs/mount_clnt.c.orig linux/fs/nfs/mount_clnt.c
> --- linux/fs/nfs/mount_clnt.c.orig	2008-04-09 08:32:43.000000000 -0400
> +++ linux/fs/nfs/mount_clnt.c	2008-04-11 11:01:39.000000000 -0400
> @@ -21,6 +21,49 @@
>  
>  static struct rpc_program	mnt_program;
>  
> +static struct {
> +	enum nfs_stat stat;
> +	int errnum;
> +} mnt_errtbl[] = {
> +	{ NFS_OK,		0		},
> +	{ NFSERR_PERM,		EPERM		},
> +	{ NFSERR_NOENT,		ENOENT		},
> +	{ NFSERR_IO,		EIO		},
> +	{ NFSERR_NXIO,		ENXIO		},
> +	{ NFSERR_ACCES,		EACCES		},
> +	{ NFSERR_EXIST,		EEXIST		},
> +	{ NFSERR_NODEV,		ENODEV		},
> +	{ NFSERR_NOTDIR,	ENOTDIR		},
> +	{ NFSERR_ISDIR,		EISDIR		},
> +#ifdef NFSERR_INVAL
> +	{ NFSERR_INVAL,		EINVAL		},	/* that Sun forgot */
> +#endif
> +	{ NFSERR_FBIG,		EFBIG		},
> +	{ NFSERR_NOSPC,		ENOSPC		},
> +	{ NFSERR_ROFS,		EROFS		},
> +	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
> +	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
> +	{ NFSERR_DQUOT,		EDQUOT		},
> +	{ NFSERR_STALE,		ESTALE		},
> +#ifdef EWFLUSH
> +	{ NFSERR_WFLUSH,	EWFLUSH		},
> +#endif
> +	/* Throw in some NFSv3 values for even more fun (HP returns these) */
> +	{ 71,			EREMOTE		},
> +};
> +static int mnt_errtbl_sz = sizeof(mnt_errtbl)/sizeof(mnt_errtbl[0]);
> +
> +static inline int mnt_err_map(int stat)
> +{
> +	int i;
> +
> +	for (i = 0; i < mnt_errtbl_sz; i++) {
> +		if (mnt_errtbl[i].stat == stat)
> +			return -mnt_errtbl[i].errnum;
> +	}
> +	return -EACCES;
> +}
> +

This probably isn't necessary.  It looks like nfs_stat_to_errno() 
already does everything you want.

>  struct mnt_fhstatus {
>  	u32 status;
>  	struct nfs_fh *fh;
> @@ -98,7 +141,7 @@ out_call_err:
>  
>  out_mnt_err:
>  	dprintk("NFS: MNT server returned result %d\n", result.status);
> -	status = -EACCES;
> +	status = mnt_err_map(result.status);

The question here is whether nfs_mount's other caller (NFSROOT) can 
handle error codes other than EACCES.

>  	goto out;
>  }

--------------070801090407090903050202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Fedora-kernel-list mailing list
Fedora-kernel-list@redhat.com
https://www.redhat.com/mailman/listinfo/fedora-kernel-list

--------------070801090407090903050202--
