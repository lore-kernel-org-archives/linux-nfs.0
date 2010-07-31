From: "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 1/5] nfsd: bypass readahead cache when have struct file
Date: Sat, 31 Jul 2010 14:18:21 -0400
Message-ID: <20100731181820.GD3074@pad.home.fieldses.org>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
 <1280442084-17867-2-git-send-email-bfields@redhat.com>
 <20100730081041.GA4126@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214]:56486 "EHLO
	pad.home.fieldses.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751020Ab0HAQjY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 12:39:24 -0400
In-Reply-To: <20100730081041.GA4126@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 30, 2010 at 04:10:42AM -0400, Christoph Hellwig wrote:
> On Thu, Jul 29, 2010 at 06:21:20PM -0400, J. Bruce Fields wrote:
> > The readahead cache compensates for the fact that the NFS server
> > currently does an open and close on every IO operation in the NFSv2 and
> > NFSv3 case.
> > 
> > In the NFSv4 case we have long-lived struct files associated with client
> > opens, so there's no need for this.  In fact, concurrent IO's using
> > trying to modify the same file->f_ra may cause problems.
> 
> Interesting.  So why did we get these for v4, but not a file handle
> cache for v2 and v3 at the same time?

The cases are a little different as we have opens and closes in the v4
protocol to define the lifetime of the cached files.

> That would make life for the filesystems a lot easier.

What's the main issue for filesystems?  I'll see about updating Krishna
Kumar's filehandle cache patches from last year.

> >  		if (err)
> >  			goto out;
> >  		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
> > -	} else {
> > -		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
> > -		if (err)
> > -			goto out;
> > -		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
> > -		nfsd_close(file);
> > -	}
> > +	} else
> > +		err = nfsd_open_read(rqstp, fhp, offset, vec, vlen, count);
> 
> The callers of nfsd_read are:
> 
> fs/nfsd/nfs3proc.c:     nfserr = nfsd_read(rqstp, &resp->fh, NULL,
> fs/nfsd/nfs4proc.c:     /* no need to check permission - this will be done in nfsd_read() */
> fs/nfsd/nfs4xdr.c:      nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp, read->rd_filp,
> fs/nfsd/nfsproc.c:      nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
> 
> which suggests that we're better off just calling nfsd_open_read
> (possible with a better name) directly from fs/nfsd/nfs3proc.c and
> fs/nfsd/nfsproc.c and nfsd_vfs_read directly from fs/nfsd/nfs4proc.c
> and fs/nfsd/nfs4xdr.c instead of doing this conditional.

OK, that's a good idea.  Maybe nfsd_read() and nfsd_read_file() for the
names??

--b.
