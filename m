From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS4ERR_FILE_OPEN handling in Linux/NFS
Date: Fri, 20 Nov 2009 14:58:33 -0500
Message-ID: <1258747113.2494.81.camel@localhost>
References: <20091117042004.1563.95871.stgit@notabene.brown>
	 <20091117042123.1563.20912.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711AbZKTT6o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2009 14:58:44 -0500
In-Reply-To: <20091117042123.1563.20912.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-11-17 at 15:21 +1100, NeilBrown wrote: 
> NFS4ERR_FILE_OPEN is returned by the server when an operation cannot be
> performed because the file is currently open and local (to the server)
> semantics prohibit the operation while the file is open.
> A typical case is a RENAME operation on an MS-Windows platform, which
> prevents rename while the file is open.
> 
> While it is possible that such a condition is transitory, it is also
> very possible that the file will be held open for an extended period
> of time thus preventing the operation.
> 
> The current behaviour of Linux/NFS is to retry the operation
> indefinitely.  This is not appropriate - we do not expect a rename to
> take an arbitrary amount of time to complete.
> 
> Rather, an error should be returned.  The most obvious error code
> would be EBUSY, which is a legal at least for 'rename' and 'unlink',
> and accurately captures the reason for the error.
> 
> This patch allows a few retries until about 2 seconds have elapsed,
> then returns EBUSY.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  fs/nfs/nfs4proc.c |    5 +++++
>  fs/nfs/nfs4xdr.c  |    1 +
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ff37454..be26c0c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -275,6 +275,11 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
>  			/* FALLTHROUGH */
>  #endif /* !defined(CONFIG_NFS_V4_1) */
>  		case -NFS4ERR_FILE_OPEN:
> +			if (exception->timeout > HZ)
> +				/* We have retried a decent amount, time to
> +				 * fail
> +				 */
> +				break;
>  		case -NFS4ERR_GRACE:
>  		case -NFS4ERR_DELAY:
>  			ret = nfs4_delay(server->client, &exception->timeout);
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 20b4e30..e50246d 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5684,6 +5684,7 @@ static struct {
>  	{ NFS4ERR_SYMLINK,	-ELOOP		},
>  	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
>  	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
> +	{ NFS4ERR_FILE_OPEN,	-EBUSY		},
>  	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
>  						    * to be handled by a
>  						    * middle-layer.
> 
> 

If you add an entry for NFS4ERR_FILE_OPEN into nfs4_stat_to_errno(),
then the result of the RPC call will be -EBUSY rather than
NFS4ERR_FILE_OPEN.
In that case, I can't see how the NFS4ERR_FILE_OPEN is being propagated
to nfs4_handle_exception().

See
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=52567b03ca38b6e556ced450d64dba8d66e23b0e for how we fixed up a similar problem with NFS4ERR_RESOURCE...

Cheers
  Trond
