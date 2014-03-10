Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49429 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753823AbaCJT5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 15:57:20 -0400
Date: Mon, 10 Mar 2014 15:57:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Matthew Rahtz <mrahtz@rapitasystems.com>,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: warning in ext4_journal_start_sb on filesystem freeze
Message-ID: <20140310195709.GH28006@fieldses.org>
References: <217983071.143460.1385453196946.JavaMail.zimbra@rapitasystems.com>
 <1697998867.143517.1385454051031.JavaMail.zimbra@rapitasystems.com>
 <20131126125826.GA4503@quack.suse.cz>
 <622177618.727.1393062606061.JavaMail.zimbra@rapitasystems.com>
 <20140224095525.GA20532@quack.suse.cz>
 <20140224154532.GB11992@fieldses.org>
 <20140225102126.GB1669@quack.suse.cz>
 <20140304164306.GC12805@fieldses.org>
 <20140304190442.GE12805@fieldses.org>
 <20140310133451.GA17807@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310133451.GA17807@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 06:34:51AM -0700, Christoph Hellwig wrote:
> On Tue, Mar 04, 2014 at 02:04:42PM -0500, J. Bruce Fields wrote:
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 6d7be3f..eea5ad1 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -404,6 +404,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  	umode_t		ftype = 0;
> >  	__be32		err;
> >  	int		host_err;
> > +	bool		get_write_count;
> >  	int		size_change = 0;
> >  
> >  	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> > @@ -411,10 +412,18 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  	if (iap->ia_valid & ATTR_SIZE)
> >  		ftype = S_IFREG;
> >  
> > +	/* Callers that do fh_verify should do the fh_want_write: */
> > +	get_write_count = !fhp->fh_dentry;
> 
> Eww, this is nasty.  Given that there are only 6 callers of nfsd_setattr
> in total, and only half of these might cause size changes I'd rather
> deal with this properly, e.g. by taking both the fh_verify into the
> callers.

Maybe so.

(Size is irrelevant, though, right?  Won't any setattr need an elevated
write count?)

--b.
