From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
Date: Wed, 23 Jun 2010 23:33:51 -0500
Message-ID: <20100624043351.GA6024@hallyn.com>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
 <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:52117 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab0FXEdT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jun 2010 00:33:19 -0400
In-Reply-To: <alpine.LRH.2.00.1006212128160.13583-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting James Morris (jmorris@namei.org):
...
> +int nfs3_proc_getxattr(struct inode *inode, const char *namespace,
> +		       const char *name, void *value, size_t size)
> +{
...
> +	res.xattr_val_len = size;
> +	res.xattr_val = kmalloc(size, GFP_KERNEL);
> +	if (!res.xattr_val)
> +		return -ENOMEM;
> +
> +	dprintk("NFS call getxattr %s%s %zd\n", namespace, name, size);
> +
> +	msg.rpc_proc = &server->client_xattr->cl_procinfo[XATTRPROC3_GETXATTR];
> +	nfs_fattr_init(&fattr);
> +	status = rpc_call_sync(server->client_xattr, &msg, 0);
> +
> +	dprintk("NFS reply getxattr: status=%d len=%d\n",
> +		status, res.xattr_val_len);
> +
> +	switch (status) {
> +	case 0:
> +		status = nfs_refresh_inode(inode, &fattr);
> +		break;
> +	case -EPFNOSUPPORT:
> +	case -EPROTONOSUPPORT:
> +		dprintk("NFS_V3_XATTR extension not supported; disabling\n");
> +		server->caps &= ~NFS_CAP_XATTR;
> +	case -ENOTSUPP:
> +		status = -EOPNOTSUPP;
> +	default:
> +		goto cleanup;
> +	}
> +
> +	status = res.xattr_val_len;
> +	if (status <= size)

res.xattr_val_len was set to size, as was status, and none of the
3 has been changed, so here status can't be > size can it?

Was this just a safety to prevent overrun, or did you mean to
do some other check?  (If a safety, then you'll still return
status > size, but with garbage in value, so i think you'd want
to also change status)

> +		memcpy(value, res.xattr_val, status);
