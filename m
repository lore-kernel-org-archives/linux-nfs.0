Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53943 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839Ab1KLDp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 22:45:57 -0500
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 11 Nov 2011 22:45:40 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAC3jb3u297612
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 22:45:38 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAC3jaTS026067
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 20:45:36 -0700
Received: from malahal ([9.47.25.235])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id pAC3janJ026003
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 20:45:36 -0700
Date: Fri, 11 Nov 2011 19:45:34 -0800
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 5/7] Added VFH FHEXPIRED recovery functions.
Message-ID: <20111112034534.GB15724@us.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
 <1321057673.8733.13.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321057673.8733.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> > +static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
> > +	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
> > +{
> > +	struct nfs4_exception exception = { };
> > +	int err;
> > +	do {
> > +		int status;
> > +
> > +		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
> > +		switch (status) {
> > +		case -NFS4ERR_BADNAME:
> > +			return -ENOENT;
> > +		case -NFS4ERR_MOVED:
> > +			err = nfs4_get_referral(dir, name, fattr, fhandle);
> > +			break;
> > +		case -NFS4ERR_FHEXPIRED:
> > +			return -NFS4ERR_FHEXPIRED;
> > +		case -NFS4ERR_WRONGSEC:
> > +			nfs_fixup_secinfo_attributes(fattr, fhandle);
> 
> case -NFS4ERR_ACCESS:
>                  ???????
> 
> > +		}
> > +		err = nfs4_handle_exception(NFS_SERVER(dir),
> > +					status, &exception);
> > +	} while (exception.retry);
> > +	return err;
> > +}
> > +
> 
> What execution context is this function going to be running under and
> what guarantees that it actually has the right file access credentials
> to allow it to perform a lookup?

I imagine, it is in the context of the process that received FHEXPIRED
error. It may not have credentials to perform a lookup on parent
directories. If it doesn't, that would end up with ESTALE with Matt's
patches, right Matt?

--Malahal.

