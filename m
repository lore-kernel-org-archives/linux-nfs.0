From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 15/20] svc: transport file implementation
Date: Tue, 10 Jul 2007 19:30:40 -0400
Message-ID: <1184110240.6480.40.camel@heimdal.trondhjem.org>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
	<20070710053451.28979.70442.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8PAP-00019q-6X
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:30:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19sKobRmXUyzAo6ZRDw8I4WMWewxp496ls=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8PAR-00055G-6q
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:30:52 -0700
In-Reply-To: <20070710053451.28979.70442.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-07-10 at 00:34 -0500, Tom Tucker wrote:
> Create a proc/sys/sunrpc/transport file that contains information 
> about the currently registered transports.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/debug.h |    1 +
>  net/sunrpc/svcsock.c         |   28 ++++++++++++++++++++++++++++
>  net/sunrpc/sysctl.c          |   40 +++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 68 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
> index d5edad6..4c847d4 100644
> --- a/include/linux/sunrpc/debug.h
> +++ b/include/linux/sunrpc/debug.h
> @@ -88,6 +88,7 @@ enum {
>  	CTL_SLOTTABLE_TCP,
>  	CTL_MIN_RESVPORT,
>  	CTL_MAX_RESVPORT,
> +	CTL_TRANSPORTS,
>  };
>  
>  #endif /* _LINUX_SUNRPC_DEBUG_H_ */
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 2583623..33aff99 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -139,6 +139,34 @@ int svc_unregister_transport(struct svc_
>  }
>  EXPORT_SYMBOL(svc_unregister_transport);
>  
> +/* 
> + * Format the transport list for printing
> + */
> +int svc_print_transports(char *buf, int maxlen) 
> +{
> +	struct list_head *le;
> +	char tmpstr[80];
> +	int len = 0;
> +	buf[0] = '\0';
> +
> +	spin_lock(&svc_transport_lock);
> +	list_for_each(le, &svc_transport_list) {
> +		int slen;
> +		struct svc_sock_ops *op = 
> +			list_entry(le, struct svc_sock_ops, sko_list);
> +		
> +		sprintf(tmpstr, "%s %d\n", op->sko_name, op->sko_max_payload);
> +		slen = strlen(tmpstr);
> +		if (len + slen > maxlen)
> +			break;
> +		len += slen;
> +		strcat(buf, tmpstr);
> +	}
> +	spin_unlock(&svc_transport_lock);
> +
> +	return len;
> +}

You're probably better off doing this using a seq_file.

> +
>  /* apparently the "standard" is that clients close
>   * idle connections after 5 minutes, servers after
>   * 6 minutes
> diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> index 738db32..683cf90 100644
> --- a/net/sunrpc/sysctl.c
> +++ b/net/sunrpc/sysctl.c
> @@ -27,6 +27,9 @@ unsigned int	nfs_debug;
>  unsigned int	nfsd_debug;
>  unsigned int	nlm_debug;
>  
> +/* Transport string */
> +char 		xprt_buf[128];
> +
>  #ifdef RPC_DEBUG
>  
>  static struct ctl_table_header *sunrpc_table_header;
> @@ -48,6 +51,34 @@ rpc_unregister_sysctl(void)
>  	}
>  }
>  
> +int svc_print_transports(char *buf, int maxlen);
> +static int proc_do_xprt(ctl_table *table, int write, struct file *file,
> +			void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	char tmpbuf[128];
> +	int len;
> +	if ((*ppos && !write) || !*lenp) {
> +		*lenp = 0;
> +		return 0;
> +	}
> +
> +	if (write) 
> +		return -EINVAL;
> +	else {
> +
> +		len = svc_print_transports(tmpbuf, 128);
> +		if (!access_ok(VERIFY_WRITE, buffer, len))
> +			return -EFAULT;
> +
> +		if (__copy_to_user(buffer, tmpbuf, len))
> +			return -EFAULT;
> +	}
> +
> +	*lenp -= len;
> +	*ppos += len;
> +	return 0;
> +}
> +
>  static int
>  proc_dodebug(ctl_table *table, int write, struct file *file,
>  				void __user *buffer, size_t *lenp, loff_t *ppos)
> @@ -111,7 +142,6 @@ done:
>  	return 0;
>  }
>  
> -
>  static ctl_table debug_table[] = {
>  	{
>  		.ctl_name	= CTL_RPCDEBUG,
> @@ -145,6 +175,14 @@ static ctl_table debug_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dodebug
>  	},
> +	{
> +		.ctl_name	= CTL_TRANSPORTS,
> +		.procname	= "transports",
> +		.data		= xprt_buf,
> +		.maxlen		= sizeof(xprt_buf),
> +		.mode		= 0444,
> +		.proc_handler	= &proc_do_xprt,
> +	},
>  	{ .ctl_name = 0 }
>  };
>  
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
