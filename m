Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824Ab1KLRQz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 12:16:55 -0500
Message-ID: <1321118198.7782.5.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 5/7] Added VFH FHEXPIRED recovery functions.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Sat, 12 Nov 2011 12:16:38 -0500
In-Reply-To: <20111112034534.GB15724@us.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321057673.8733.13.camel@lade.trondhjem.org>
	 <20111112034534.GB15724@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 19:45 -0800, Malahal Naineni wrote: 
> Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> > > +static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
> > > +	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
> > > +{
> > > +	struct nfs4_exception exception = { };
> > > +	int err;
> > > +	do {
> > > +		int status;
> > > +
> > > +		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
> > > +		switch (status) {
> > > +		case -NFS4ERR_BADNAME:
> > > +			return -ENOENT;
> > > +		case -NFS4ERR_MOVED:
> > > +			err = nfs4_get_referral(dir, name, fattr, fhandle);
> > > +			break;
> > > +		case -NFS4ERR_FHEXPIRED:
> > > +			return -NFS4ERR_FHEXPIRED;
> > > +		case -NFS4ERR_WRONGSEC:
> > > +			nfs_fixup_secinfo_attributes(fattr, fhandle);
> > 
> > case -NFS4ERR_ACCESS:
> >                  ???????
> > 
> > > +		}
> > > +		err = nfs4_handle_exception(NFS_SERVER(dir),
> > > +					status, &exception);
> > > +	} while (exception.retry);
> > > +	return err;
> > > +}
> > > +
> > 
> > What execution context is this function going to be running under and
> > what guarantees that it actually has the right file access credentials
> > to allow it to perform a lookup?
> 
> I imagine, it is in the context of the process that received FHEXPIRED
> error. It may not have credentials to perform a lookup on parent
> directories. If it doesn't, that would end up with ESTALE with Matt's
> patches, right Matt?

My point is that if you don't have the ability to pass a credential as
an argument, then you won't be able to recover from something like an
OPEN, READ or WRITE, which all happen in the rpciod context, nor can you
recover from the state recovery thread context.

Note also that you are doing synchronous I/O, and so you will need a
recovery thread context anyway in order to recover from stuff running in
the rpciod context...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

