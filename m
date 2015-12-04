Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756204AbbLDROH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2015 12:14:07 -0500
Date: Fri, 4 Dec 2015 12:14:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH v1 2/3] NFSD: Implement the COPY call
Message-ID: <20151204171406.GB27725@fieldses.org>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20151204154549.GD26898@fieldses.org>
 <5661B604.1010402@Netapp.com>
 <20151204164944.GA27725@fieldses.org>
 <5661C7C1.9010002@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5661C7C1.9010002@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 04, 2015 at 12:05:05PM -0500, Anna Schumaker wrote:
> On 12/04/2015 11:49 AM, J. Bruce Fields wrote:
> > On Fri, Dec 04, 2015 at 10:49:24AM -0500, Anna Schumaker wrote:
> >> On 12/04/2015 10:45 AM, J. Bruce Fields wrote:
> >>> On Thu, Dec 03, 2015 at 03:55:35PM -0500, Anna Schumaker wrote:
> >>>> @@ -498,6 +499,22 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >>>>  }
> >>>>  #endif
> >>>>  
> >>>> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
> >>>> +		       struct file *dst, u64 dst_pos,
> >>>> +		       u64 count)
> >>>> +{
> >>>> +	ssize_t bytes;
> >>>> +	u64 limit = 0x10000000;
> >>>
> >>> Why that value?  Could I get a comment here?
> >>
> >> Whoops!  I had a comment there at one point, but I must have deleted it :(.  That value is to cap copies to 256MB.
> > 
> > Could you include some justification for the choice of that particular
> > value?
> 
> Yeah, I can run tests with different values and include the results in v2.
> 
> > 
> >>>> +	if (count > limit)
> >>>> +		count = limit;
> >>>> +
> >>>> +	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
> >>>
> >>> Sorry, I lost track of the copy discussions: does this only work on
> >>> filesystems with special support, or does it fall back on doing the copy
> >>> by hand?  Which filesystems (of the exportable filesystems) support
> >>> this?
> >>
> >> The system call falls back on doing the copy by hand if there is no filesystem acceleration.
> > 
> > Is this practical?  It means a huge range in possible latency of the
> > single COPY call depending on filesystem.
> 
> That's why I'm breaking copies into smaller chunks, rather than doing everything at once.
> 
> > 
> > I guess I can live with it and we can see if people run into problems in
> > practice.  But let's make sure this is documented.
> 
> Okay.  I'll add documentation about this!

OK, thanks.  I think those are my only concerns, good to see that this
is all the new code we need now.--b.
