Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60261 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753324Ab1KNVMt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 16:12:49 -0500
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 14 Nov 2011 16:12:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAELCFTm329316
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:12:16 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAELCEP6016512
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:12:14 -0500
Date: Mon, 14 Nov 2011 16:12:13 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 5/7] Added VFH FHEXPIRED recovery functions.
Message-ID: <20111114211213.GA3747@Gelgoog.pok.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
 <1321057673.8733.13.camel@lade.trondhjem.org>
 <20111112034534.GB15724@us.ibm.com>
 <1321118198.7782.5.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321118198.7782.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 12, 2011 at 12:16:38PM -0500, Trond Myklebust wrote:
> > > > +static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
> > > > +	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
> > > > +{
> > > > +	struct nfs4_exception exception = { };
> > > > +	int err;
> > > > +	do {
> > > > +		int status;
> > > > +
> > > > +		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
> > > > +		switch (status) {
> > > > +		case -NFS4ERR_BADNAME:
> > > > +			return -ENOENT;
> > > > +		case -NFS4ERR_MOVED:
> > > > +			err = nfs4_get_referral(dir, name, fattr, fhandle);
> > > > +			break;
> > > > +		case -NFS4ERR_FHEXPIRED:
> > > > +			return -NFS4ERR_FHEXPIRED;
> > > > +		case -NFS4ERR_WRONGSEC:
> > > > +			nfs_fixup_secinfo_attributes(fattr, fhandle);
> > > 
> > > case -NFS4ERR_ACCESS:
> > >                  ???????
> > > 
> > > > +		}
> > > > +		err = nfs4_handle_exception(NFS_SERVER(dir),
> > > > +					status, &exception);
> > > > +	} while (exception.retry);
> > > > +	return err;
> > > > +}
> > > > +
> > > 
> > > What execution context is this function going to be running under and
> > > what guarantees that it actually has the right file access credentials
> > > to allow it to perform a lookup?
> > 
> > I imagine, it is in the context of the process that received FHEXPIRED
> > error. It may not have credentials to perform a lookup on parent
> > directories. If it doesn't, that would end up with ESTALE with Matt's
> > patches, right Matt?
Yes, the current code should be run in the context of the process that 
received the FHEXPIRED. I think that if the server returns NFS4ERR_ACCESS
(or EACCESS?) that my patches will keep that error. The only time my patches
return ESTALE right now is if either the mount option is not used, or the 
server doesn't use NFS4_FH_VOLATILE_ANY. Any other errors received during 
recovery are returned like they normally would be.

> 
> My point is that if you don't have the ability to pass a credential as
> an argument, then you won't be able to recover from something like an
> OPEN, READ or WRITE, which all happen in the rpciod context, nor can you
> recover from the state recovery thread context.
> 
> Note also that you are doing synchronous I/O, and so you will need a
> recovery thread context anyway in order to recover from stuff running in
> the rpciod context...
> 

Hmm, I didn't even think about that when I wrote this... 

So, how would you suggest I go about correcting this? Should I add a rpc_cred
argument to the vfh lookup and then try to switch the context on ACCESS errors?

Thanks,

Matt Treinish

