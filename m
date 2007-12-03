From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 34/38] svc: Add /proc/sys/sunrpc/transport files
Date: Mon, 3 Dec 2007 11:44:15 -0500
Message-ID: <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224105.14563.48684.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53241 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbXLCQob (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 11:44:31 -0500
In-Reply-To: <20071129224105.14563.48684.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:41 PM, Tom Tucker wrote:
> Add a file that when read lists the set of registered svc
> transports.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc_xprt.h |    2 ++
>  net/sunrpc/svc_xprt.c           |   28 ++++++++++++++++++++++++++++
>  net/sunrpc/sysctl.c             |   31 ++++++++++++++++++++++++++++ 
> +++
>  3 files changed, 61 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index 36f8b09..c2fa41d 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -79,11 +79,13 @@ void	svc_xprt_copy_addrs(struct svc_rqst  
> *rqstp, struct svc_xprt *xprt);
>  void	svc_xprt_enqueue(struct svc_xprt *xprt);
>  int	svc_port_is_privileged(struct sockaddr *sin);
>  void	svc_delete_xprt(struct svc_xprt *xprt);
> +int	svc_print_xprts(char *buf, int maxlen);
>
>  static inline void svc_xprt_get(struct svc_xprt *xprt)
>  {
>  	kref_get(&xprt->xpt_ref);
>  }
> +
>  static inline void svc_xprt_set_local(struct svc_xprt *xprt,
>  				      struct sockaddr *sa, int salen)
>  {
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index b31ba0e..7416e66 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -93,6 +93,34 @@ int svc_unreg_xprt_class(struct svc_xprt_class  
> *xcl)
>  }
>  EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
>
> +/*
> + * Format the transport list for printing
> + */
> +int svc_print_xprts(char *buf, int maxlen)

One last one, then I will crawl back into my hole.

Arguments and variables that handle string lengths should be of type  
size_t (or at the very least, should be unsigned).

Otherwise, I don't see any architectural problems with the patch series.

> +{
> +	struct list_head *le;
> +	char tmpstr[80];
> +	int len = 0;
> +	buf[0] = '\0';
> +
> +	spin_lock(&svc_xprt_class_lock);
> +	list_for_each(le, &svc_xprt_class_list) {
> +		int slen;
> +		struct svc_xprt_class *xcl =
> +			list_entry(le, struct svc_xprt_class, xcl_list);
> +
> +		sprintf(tmpstr, "%s %d\n", xcl->xcl_name, xcl->xcl_max_payload);
> +		slen = strlen(tmpstr);
> +		if (len + slen > maxlen)
> +			break;
> +		len += slen;
> +		strcat(buf, tmpstr);
> +	}
> +	spin_unlock(&svc_xprt_class_lock);
> +
> +	return len;
> +}
> +
>  static void svc_xprt_free(struct kref *kref)
>  {
>  	struct svc_xprt *xprt =
> diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> index 2be714e..fd7cf59 100644
> --- a/net/sunrpc/sysctl.c
> +++ b/net/sunrpc/sysctl.c
> @@ -18,6 +18,7 @@
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/sched.h>
>  #include <linux/sunrpc/stats.h>
> +#include <linux/sunrpc/svc_xprt.h>
>
>  /*
>   * Declare the debug flags here
> @@ -48,6 +49,30 @@ rpc_unregister_sysctl(void)
>  	}
>  }
>
> +static int proc_do_xprt(ctl_table *table, int write, struct file  
> *file,
> +			void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	char tmpbuf[256];
> +	int len;
> +	if ((*ppos && !write) || !*lenp) {
> +		*lenp = 0;
> +		return 0;
> +	}
> +	if (write)
> +		return -EINVAL;
> +	else {
> +		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
> +		if (!access_ok(VERIFY_WRITE, buffer, len))
> +			return -EFAULT;
> +
> +		if (__copy_to_user(buffer, tmpbuf, len))
> +			return -EFAULT;
> +	}
> +	*lenp -= len;
> +	*ppos += len;
> +	return 0;
> +}
> +
>  static int
>  proc_dodebug(ctl_table *table, int write, struct file *file,
>  				void __user *buffer, size_t *lenp, loff_t *ppos)
> @@ -140,6 +165,12 @@ static ctl_table debug_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dodebug
>  	},
> +	{
> +		.procname	= "transports",
> +		.maxlen		= 256,
> +		.mode		= 0444,
> +		.proc_handler	= &proc_do_xprt,
> +	},
>  	{ .ctl_name = 0 }
>  };


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
