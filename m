Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:58724 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaHRMGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2014 08:06:08 -0400
Received: by mail-qg0-f53.google.com with SMTP id z60so1002202qgd.12
        for <linux-nfs@vger.kernel.org>; Mon, 18 Aug 2014 05:06:07 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id v14sm29417063qaj.22.2014.08.18.05.06.06
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Aug 2014 05:06:07 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 18 Aug 2014 08:06:05 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: [kernel RFC PATCH 2/4] nfsd: add a v4_end_grace file to
 /proc/fs/nfsd
Message-ID: <20140818080605.2712c342@tlielax.poochiereds.net>
In-Reply-To: <1408113880-5489-3-git-send-email-jlayton@primarydata.com>
References: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
	<1408113880-5489-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Aug 2014 10:44:38 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> Allow a privileged userland process to end the v4 grace period early.
> Any write to the file will cause the v4 grace period to be lifted.
> 
> The basic idea with this will be to allow the userland client tracking
> program to lift the grace period once it knows that no more clients
> will be reclaiming state.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c |  2 +-
>  fs/nfsd/nfsctl.c    | 35 +++++++++++++++++++++++++++++++++++
>  fs/nfsd/state.h     |  3 +++
>  3 files changed, 39 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5c5873811bd9..de6bea769b24 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4123,7 +4123,7 @@ out:
>  	return status;
>  }
>  
> -static void
> +void
>  nfsd4_end_grace(struct nfsd_net *nn)
>  {
>  	/* do nothing if grace period already ended */
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 4e042105fb6e..99044e237861 100644
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
> @@ -1077,6 +1080,37 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
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
> + *			string. Writing to the file will end the grace period
> + *			for nfsd's v4 lock manager.
> + */
> +static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
> +{
> +	struct net *net = file->f_dentry->d_sb->s_fs_info;
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +
> +	if (size > 0)
> +		nfsd4_end_grace(nn);
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%c\n",
> +			 nn->grace_ended ? 'Y' : 'N');
> +}
> +
>  #endif
>  
>  /*----------------------------------------------------------------------------*/
> @@ -1110,6 +1144,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
>  		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
> +		[NFSD_V4EndGrace] = {"v4_end_grace", &transaction_ops, S_IWUSR|S_IRUGO},
>  #endif
>  		/* last one */ {""}
>  	};
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 4a89e00d7461..ecf579904892 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -545,6 +545,9 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
>  							struct nfsd_net *nn);
>  extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
>  
> +/* grace period management */
> +void nfsd4_end_grace(struct nfsd_net *nn);
> +
>  /* nfs4recover operations */
>  extern int nfsd4_client_tracking_init(struct net *net);
>  extern void nfsd4_client_tracking_exit(struct net *net);

FWIW, I think the right thing to do here might be to drop this patch
and instead have the nfsdcltrack "init" and "create" upcalls return a
distinct error code that means "all reclaims are finished".

This is complicated a bit by the fact that older kernels treat any
non-zero return from "init" as an error, but I think we can just ensure
that we only return "0" to kernels that don't pass down the environment
variables that nfsdcltrack needs to determine whether reclaims are
complete or not.

-- 
Jeff Layton <jlayton@primarydata.com>
