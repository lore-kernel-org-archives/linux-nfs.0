From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/22] NFSD: Add helper functions for __write_ports()
Date: Wed, 24 Dec 2008 23:15:23 -0500
Message-ID: <20081225041523.GA17998@fieldses.org>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215742.24332.36578.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYLYEP1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Dec 2008 23:15:27 -0500
In-Reply-To: <20081212215742.24332.36578.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 12, 2008 at 04:57:42PM -0500, Chuck Lever wrote:
> Clean up:  I'd like to refactor __write_ports() to make it easier to
> understand and maintain.  Introduce a set of helper functions to
> handle the details of the __write_ports() function.
> 
> New helpers are not used yet.

As stated in http://marc.info/?l=linux-nfs&m=122894134032274&w=2, I'd
prefer that new code be introduced with its callers where reasonable, so
in this case I'd rather this patch be combined with the following.

One question:

> +/*
> + * A single 'fd' number was written, in which case it must be for
> + * a socket of a supported family/protocol, and we use it as an
> + * nfsd listener.
> + */
> +static ssize_t __write_ports_addfd(char *buf, size_t size)
> +{
> +	char *mesg = buf;
> +	int fd, err;
> +
> +	err = get_int(&mesg, &fd);
> +	if (err || fd < 0)
> +		return -EINVAL;
> +
> +	err = nfsd_create_serv();
> +	if (err)
> +		return err;
> +
> +	err = svc_addsock(nfsd_serv, fd, buf);
> +	if (err < 0)
> +		return err;
> +
> +	err = lockd_up();
> +	if (err < 0)
> +		svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
> +
> +	/* Decrease the count, but don't shut down the the service */
> +	nfsd_serv->sv_nrthreads--;

Behavior on the error path seems slightly different here than in the
original code, which did the sv_nrthreads-- even when svc_addsock
failed.  Could you check which is right?  If the existing code is wrong,
could you break out the fix into a separate patch?

> +
> +	return err < 0 ? err : 0;
> +}
> +
> +/*
> + * A '-' followed by the 'name' of a socket means we close the socket.
> + */
> +static ssize_t __write_ports_delfd(char *buf, size_t size)
> +{
> +	char *toclose;
> +	int len = 0;
> +
> +	toclose = kstrdup(buf + 1, GFP_KERNEL);
> +	if (!toclose)
> +		return -ENOMEM;
> +
> +	if (nfsd_serv)
> +		len = svc_sock_names(buf, nfsd_serv, toclose);
> +	if (len >= 0)
> +		lockd_down();
> +
> +	kfree(toclose);
> +	return len;
> +}
> +
> +/*
> + * A transport listener is added by writing it's transport name and
> + * a port number
> + */
> +static ssize_t __write_ports_addxprt(char *buf, size_t size,
> +				     char *transport, unsigned short port)
> +{
> +	int err;
> +
> +	err = nfsd_create_serv();
> +	if (err)
> +		return err;
> +
> +	err = svc_create_xprt(nfsd_serv, transport, port, SVC_SOCK_ANONYMOUS);
> +	if (err == -ENOENT)
> +		/* Give a reasonable perror msg for
> +		 * bad transport string */
> +		err = -EPROTONOSUPPORT;
> +
> +	return err < 0 ? err : 0;
> +}
> +
> +/*
> + * A transport listener is removed by writing a "-", it's transport
> + * name, and it's port number
> + */
> +static ssize_t __write_ports_delxprt(char *buf, size_t size,
> +				     char *transport, int port)
> +{
> +	struct svc_xprt *xprt;
> +	int err = -EINVAL;
> +
> +	if (port == 0 || nfsd_serv == NULL)
> +		return err;
> +
> +	xprt = svc_find_xprt(nfsd_serv, transport, AF_UNSPEC, port);
> +	if (xprt) {
> +		svc_close_xprt(xprt);
> +		svc_xprt_put(xprt);
> +		err = 0;
> +	} else
> +		err = -ENOTCONN;
> +
> +	return err < 0 ? err : 0;

I understand it's inherited from the original code, but the
error-handling logic seems a bit silly; e.g., the "err" variable isn't
really used.  Why not:

	if (port == 0 || nfsd_serv == NULL)
		return -EINVAL;

	xprt = svc_find_xprt(...)
	if (!xprt)
		return -ENOTCONN;
	svc_close_xprt(xprt);
	svc_xprt_put(xprt);
	return 0;

?

This patch and the following look good otherwise.

--b.

> +}
> +
>  static ssize_t __write_ports(struct file *file, char *buf, size_t size)
>  {
>  	if (size == 0) {
> 
