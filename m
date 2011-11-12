Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644Ab1KLA1z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 19:27:55 -0500
Message-ID: <1321057673.8733.13.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 5/7] Added VFH FHEXPIRED recovery functions.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Matthew Treinish <treinish@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 11 Nov 2011 19:27:53 -0500
In-Reply-To: <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> +static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
> +	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
> +{
> +	struct nfs4_exception exception = { };
> +	int err;
> +	do {
> +		int status;
> +
> +		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
> +		switch (status) {
> +		case -NFS4ERR_BADNAME:
> +			return -ENOENT;
> +		case -NFS4ERR_MOVED:
> +			err = nfs4_get_referral(dir, name, fattr, fhandle);
> +			break;
> +		case -NFS4ERR_FHEXPIRED:
> +			return -NFS4ERR_FHEXPIRED;
> +		case -NFS4ERR_WRONGSEC:
> +			nfs_fixup_secinfo_attributes(fattr, fhandle);

case -NFS4ERR_ACCESS:
                 ???????

> +		}
> +		err = nfs4_handle_exception(NFS_SERVER(dir),
> +					status, &exception);
> +	} while (exception.retry);
> +	return err;
> +}
> +

What execution context is this function going to be running under and
what guarantees that it actually has the right file access credentials
to allow it to perform a lookup?
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

