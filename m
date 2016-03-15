Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60138 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbcCOOqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 10:46:38 -0400
Date: Tue, 15 Mar 2016 10:46:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH v3 3/3] NFSD: Implement the COPY call
Message-ID: <20160315144637.GC419@fieldses.org>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1457474158-16050-4-git-send-email-Anna.Schumaker@Netapp.com>
 <20160314213426.GC22276@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160314213426.GC22276@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 14, 2016 at 05:34:26PM -0400, J. Bruce Fields wrote:
> On Tue, Mar 08, 2016 at 04:55:57PM -0500, Anna Schumaker wrote:
> > From: Anna Schumaker <Anna.Schumaker@netapp.com>
> >  static __be32
> > +nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > +		struct nfsd4_copy *copy)
> > +{
> > +	struct file *src, *dst;
> > +	__be32 status;
> > +	ssize_t bytes;
> > +	loff_t max;
> > +
> > +	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
> > +				   &copy->cp_dst_stateid, &dst);
> > +	if (status)
> > +		goto out;
> > +
> > +	max = i_size_read(file_inode(src));
> > +	if ((copy->cp_src_pos + copy->cp_count) > max) {
> > +		status = nfserr_inval;
> > +		goto out_put;
> > +	}
> 
> If we care about the race between this check and the copy, then we need
> some locking.  If we don't, then a comment explaining why not would be
> useful here.
> 
> (Looks like this check, and the INVAL error, are both mandated by the
> spec.  The behavior looks wrong to me--usually EINVAL's reserved for
> things the client had to know was a problem, but here the client doesn't
> necessarily know the file size.  I would have expected just success and
> a short read.)

Now that I look at it, that behavior's what's documented for the system
call too; from the man page:

	EINVAL Requested range extends beyond the end of the  source
	file;  or the flags argument is not 0.

Still seems like really strange behavior to me.

But if that's what we chose, then I think vfs_copy_range should be doing
that check for us.

--b.
