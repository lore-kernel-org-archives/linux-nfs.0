Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:61003 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbaGJPFK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 11:05:10 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so6986198qac.21
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 08:05:10 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 11:05:08 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 014/100] nfsd: set stateid access and deny bits in
 nfs4_get_vfs_file
Message-ID: <20140710110508.569885db@tlielax.poochiereds.net>
In-Reply-To: <20140710083406.GA1805@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-15-git-send-email-jlayton@primarydata.com>
	<20140710083406.GA1805@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 01:34:06 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > @@ -3343,20 +3347,15 @@ out:
> >  static __be32
> >  nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
> >  {
> > -	u32 op_share_access = open->op_share_access;
> >  	__be32 status;
> >  
> > -	if (!test_access(op_share_access, stp))
> > -		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
> > +	if (!test_access(open->op_share_access, stp))
> > +		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
> >  	else
> >  		status = nfsd4_truncate(rqstp, cur_fh, open);
> >  
> >  	if (status)
> >  		return status;
> > -
> > -	/* remember the open */
> > -	set_access(op_share_access, stp);
> > -	set_deny(open->op_share_deny, stp);
> >  	return nfs_ok;
> 
> This function is trivial enough now to be merged into the only caller,
> especially as that open actually has another call to nfs4_get_vfs_file
> right next to it in another branch.
> 

Yes, but in two patches (nfsd: make deny mode enforcement more
efficient and close races in it) we add some complexity back in here
and at that point I think we'll want this in a separate function. So I
think we shouldn't fold that into the caller since it'll just increase
the churn.

> 
> >  	} else {
> > -		status = nfs4_get_vfs_file(rqstp, fp, current_fh, open);
> > -		if (status)
> > -			goto out;
> >  		stp = open->op_stp;
> >  		open->op_stp = NULL;
> >  		init_open_stateid(stp, fp, open);
> > +		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
> > +		if (status) {
> > +			release_open_stateid(stp);
> > +			goto out;
> > +		}
> 
> I can't find a place where we set the access bits before here.
> 

Correct, we don't. That's not a problem though, AFAICT.

The idea here is to go ahead and hash the stateid and then try to get
the access to the file. If that fails, we unhash it and free the
stateid.

In a later patch we'll need to do that anyway to ensure that the
fi_deny_mode is properly handled if it needs to be recalculated while
we're trying to get a new filp for the file.

-- 
Jeff Layton <jlayton@primarydata.com>
