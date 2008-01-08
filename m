From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 8 Jan 2008 16:18:05 +1100
Message-ID: <18307.1933.159410.677626@notabene.brown>
References: <4781BB0D.90706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: wcheng@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58491 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbYAHFSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 00:18:13 -0500
In-Reply-To: message from Wendy Cheng on Monday January 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday January 7, wcheng@redhat.com wrote:
> We've implemented two new NFSD procfs files:
> 
> o /proc/fs/nfsd/unlock_ip
> o /proc/fs/nfsd/unlock_filesystem
> 
> They are intended to allow admin or user mode script to release NLM 
> locks based on either a path name or a server in-bound ip address (ipv4 
> for now)
> as;
> 
> shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
> shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem

I'm happy with this interface and the code looks credible, so 
  Acked-by: NeilBrown <neilb@suse.de>

however......
	

> --- linux-o/fs/nfsd/nfsctl.c	2008-01-04 10:01:08.000000000 -0500
> +++ linux/fs/nfsd/nfsctl.c	2008-01-06 15:27:34.000000000 -0500
> @@ -288,6 +295,56 @@ static ssize_t write_getfd(struct file *
>  	return err;
>  }
>  
> +extern __u32 in_aton(const char *str);

Bad.  It is "__be32" in linux/inet.h, and the difference an be
important.
Can you just #include <linux/inet.h> ???

> +
> +static
> +ssize_t failover_parse(int where, struct file *file, char *buf, size_t size)
> +{
> +	char *fo_path, *mesg;
> +	__be32 server_ip[4];

Why '4' ???

Also, fo_path is only sometimes a path, so the name choice could be
confusing.  You use "data" in the formal parameters for nfsd_fo_cmd,
which is more idiomatic at least.
Maybe we should have a 
union unlock_args {
	char *path;
	__be32 IPv4;
};
and pass around a pointer to such a union?
If you don't like that I would be happy with a 'void*', but not with a
'char *' called path.

> @@ -717,7 +776,6 @@ static void __exit exit_nfsd(void)
>  	nfsd4_free_slabs();
>  	unregister_filesystem(&nfsd_fs_type);
>  }
> -
>  MODULE_AUTHOR("Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>");
>  MODULE_LICENSE("GPL");
>  module_init(init_nfsd)

Any good reason for removing this blank line?


> +int nlmsvc_fo_match(struct nlm_host *dummy1, struct nlm_host *dummy2)
> +{
> +        return 1;
> +}

White space damage.  Did you run checkpatch.pl??

> +int
> +nlmsvc_fo_cmd(int cmd, void *datap, int grace_time)
> +{
> +	nlm_fo_cmd fo_cmd;
> +	int rc=-EINVAL;
> +
> +	fo_printk("lockd: nlmsvc_fo_cmd enter, cmd=%d, datap=0x%p, gp=%d\n",
> +		cmd, datap, grace_time);
> +
> +	fo_cmd.cmd   = cmd;
> +	fo_cmd.stat  = 0;
> +	fo_cmd.gp    = 0;
> +	fo_cmd.datap = datap;
> +
> +	/* "if" place holder for NFSD_FO_RESUME */
> +	{
> +		/* fo_start */
> +		rc = nlm_traverse_files((struct nlm_host*) &fo_cmd, 
> +					nlmsvc_fo_match);
> +		fo_printk("nlmsvc_fo_cmd rc=%d, stat=%d\n", rc, fo_cmd.stat);
> +	} 
> +
> +	return rc;
> +}
> +
> +EXPORT_SYMBOL(nlmsvc_fo_cmd);

I think today's convention it to not have a blank line before
EXPORT_SYMBOL.  checkpatch.pl should pick this up for you.

> --- linux-o/include/linux/lockd/lockd.h	2008-01-04 10:01:08.000000000 -0500
> +++ linux/include/linux/lockd/lockd.h	2008-01-06 15:14:55.000000000 -0500
> @@ -39,7 +39,7 @@
>  struct nlm_host {
>  	struct hlist_node	h_hash;		/* doubly linked list */
>  	struct sockaddr_in	h_addr;		/* peer address */
> -	struct sockaddr_in	h_saddr;	/* our address (optional) */
> +	struct sockaddr_in      h_saddr;        /* our address (optional) */
>  	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
>  	char *			h_name;		/* remote hostname */
>  	u32			h_version;	/* interface version */

This change is purely white-space breakage.


> @@ -214,6 +215,17 @@ void		  nlmsvc_mark_resources(void);
>  void		  nlmsvc_free_host_resources(struct nlm_host *);
>  void		  nlmsvc_invalidate_all(void);
>  
> +/* cluster failover support */
> +
> +typedef struct {
> +	int     cmd;
> +	int     stat;
> +	int     gp;
> +	void    *datap;
> +} nlm_fo_cmd;

gp???  I guess that means 'grace period'.  It isn't used at all in
this patch.  Ideally it should only be introduce in the patch which
uses it, but it definitely needs a better name - and preferably a
comment.

NeilBrown
