Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:38981 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147AbaIIMVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 08:21:16 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so1730634qgd.41
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 05:21:15 -0700 (PDT)
Date: Tue, 9 Sep 2014 08:21:11 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v3 4/8] nfsd: add a v4_end_grace file to /proc/fs/nfsd
Message-ID: <20140909082111.44854912@tlielax.poochiereds.net>
In-Reply-To: <1410187609-10319-5-git-send-email-jlayton@primarydata.com>
References: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
	<1410187609-10319-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon,  8 Sep 2014 10:46:45 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> Allow a privileged userland process to end the v4 grace period early.
> Any write to the file will cause the v4 grace period to be lifted.
> The basic idea with this will be to allow the userland client tracking
> program to lift the grace period once it knows that no more clients
> will be reclaiming state.
> 

Oof...sorry!

The patch does what you requested, (accept only "Y", "y" or "1" as a
sign to lift the grace period), but I missed updating the patch
description above. If there's another respin needed for other reasons,
then I'll fix the text in it. Otherwise, let me know if you want me to
resend.

> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c |  2 +-
>  fs/nfsd/nfsctl.c    | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/state.h     |  3 +++
>  3 files changed, 49 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 422b1df4bb00..ae380e90e372 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4109,7 +4109,7 @@ out:
>  	return status;
>  }
>  
> -static void
> +void
>  nfsd4_end_grace(struct nfsd_net *nn)
>  {
>  	/* do nothing if grace period already ended */
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 4e042105fb6e..ca73ca79a0ee 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -49,6 +49,7 @@ enum {
>  	NFSD_Leasetime,
>  	NFSD_Gracetime,
>  	NFSD_RecoveryDir,
> +	NFSD_V4EndGrace,
>  #endif
>  };
>  
> @@ -68,6 +69,7 @@ static ssize_t write_maxconn(struct file *file, char *buf, size_t size);
>  static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
>  static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
>  static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
> +static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size);
>  #endif
>  
>  static ssize_t (*write_op[])(struct file *, char *, size_t) = {
> @@ -84,6 +86,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
>  	[NFSD_Leasetime] = write_leasetime,
>  	[NFSD_Gracetime] = write_gracetime,
>  	[NFSD_RecoveryDir] = write_recoverydir,
> +	[NFSD_V4EndGrace] = write_v4_end_grace,
>  #endif
>  };
>  
> @@ -1077,6 +1080,47 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
>  	return rv;
>  }
>  
> +/**
> + * write_v4_end_grace - release grace period for nfsd's v4.x lock manager
> + *
> + * Input:
> + *			buf:		ignored
> + *			size:		zero
> + * OR
> + *
> + * Input:
> + * 			buf:		any value
> + *			size:		non-zero length of C string in @buf
> + * Output:
> + *			passed-in buffer filled with "Y" or "N" with a newline
> + *			and NULL-terminated C string. This indicates whether
> + *			the grace period has ended in the current net
> + *			namespace. Return code is the size in bytes of the
> + *			string. Writing a string that starts with 'Y', 'y', or
> + *			'1' to the file will end the grace period for nfsd's v4
> + *			lock manager.
> + */
> +static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
> +{
> +	struct net *net = file->f_dentry->d_sb->s_fs_info;
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +
> +	if (size > 0) {
> +		switch(buf[0]) {
> +		case 'Y':
> +		case 'y':
> +		case '1':
> +			nfsd4_end_grace(nn);
> +			break;
> +		default:
> +			return -EINVAL;
> +		}
> +	}
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%c\n",
> +			 nn->grace_ended ? 'Y' : 'N');
> +}
> +
>  #endif
>  
>  /*----------------------------------------------------------------------------*/
> @@ -1110,6 +1154,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
>  		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
> +		[NFSD_V4EndGrace] = {"v4_end_grace", &transaction_ops, S_IWUSR|S_IRUGO},
>  #endif
>  		/* last one */ {""}
>  	};
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 5f8a500a58bf..10bfda710f71 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -544,6 +544,9 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
>  							struct nfsd_net *nn);
>  extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
>  
> +/* grace period management */
> +void nfsd4_end_grace(struct nfsd_net *nn);
> +
>  /* nfs4recover operations */
>  extern int nfsd4_client_tracking_init(struct net *net);
>  extern void nfsd4_client_tracking_exit(struct net *net);


-- 
Jeff Layton <jlayton@poochiereds.net>
