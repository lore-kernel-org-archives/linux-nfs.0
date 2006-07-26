From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 009 of 9] knfsd: Allow sockets to be passed to nfsd via
 'portlist'
Date: Tue, 25 Jul 2006 23:53:09 -0700
Message-ID: <20060725235309.8f30b28f.akpm@osdl.org>
References: <20060725114207.21779.patches@notabene>
	<1060725015508.22007@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030424AbWGZGxU@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060725015508.22007@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 25 Jul 2006 11:55:08 +1000
NeilBrown <neilb@suse.de> wrote:

> 
> Userspace should create and bind a socket (but not connectted)
> and write the 'fd' to portlist.  This will cause the nfs server
> to listen on that socket.
> 
> To close a socket, the name of the socket - as read from 'portlist'
> can be written to 'portlist' with a preceding '-'.
> 

ick.  Is that the best API we can come up with?

It's a privileged operation, but heck.  Do we perform validation on the fd
to make sure that it's refers to a socket and not to /dev/fb0?

>  static ssize_t write_ports(struct file *file, char *buf, size_t size)
>  {
> -	/* for now, ignore what was written and just
> -	 * return known ports
> -	 * AF proto address port
> +	if (size == 0) {
> +		int len = 0;
> +		lock_kernel();
> +		if (nfsd_serv)
> +			len = svc_sock_names(buf, nfsd_serv, NULL);
> +		unlock_kernel();
> +		return len;
> +	}
> +	/* Either a single 'fd' number is written, in which
> +	 * case it must be for a socket of a supported family/protocol,
> +	 * and we use it as an nfsd socket, or
> +	 * A '-' followed by the 'name' of a socket in which case
> +	 * we close the socket.
>  	 */
> -	int len = 0;
> -	lock_kernel();
> -	if (nfsd_serv)
> -		len = svc_sock_names(buf, nfsd_serv);
> -	unlock_kernel();
> -	return len;
> +	if (isdigit(buf[0])) {
> +		char *mesg = buf;
> +		int fd;
> +		int err;
> +		err = get_int(&mesg, &fd);
> +		if (err)
> +			return -EINVAL;
> +		if (fd < 0)
> +			return -EINVAL;
> +		err = nfsd_create_serv();
> +		if (!err) {
> +			int proto = 0;
> +			err = svc_addsock(nfsd_serv, fd, buf, &proto);
> +			/* Decrease the count, but don't shutdown the
> +			 * the service
> +			 */
> +			if (err >= 0)
> +				lockd_up(proto);
> +			nfsd_serv->sv_nrthreads--;
> +		}
> +		return err;
> +	}
> +	if (buf[0] == '-') {
> +		char *toclose = kstrdup(buf+1, GFP_KERNEL);
> +		int len = 0;
> +		if (!toclose)
> +			return -ENOMEM;
> +		lock_kernel();
> +		if (nfsd_serv)
> +			len = svc_sock_names(buf, nfsd_serv, toclose);
> +		unlock_kernel();
> +		kfree(toclose);
> +		return len;
> +	}
> +	return -EINVAL;
>  }

<checks>

OK, simple_transaction_get() guarantees that *buf is null-terminated.  It
might be worth a comment to stop code-reviewers from freaking out ;)
