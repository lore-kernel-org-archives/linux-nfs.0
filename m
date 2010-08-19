Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33864 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab0HSWVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 18:21:15 -0400
Date: Thu, 19 Aug 2010 18:19:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Server should allow offset larger than LLONG_MAX at
 commit procedure
Message-ID: <20100819221903.GB9275@fieldses.org>
References: <4C6B9538.2020608@cn.fujitsu.com>
 <20100819001647.GD18367@fieldses.org>
 <4C6CA739.5030504@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4C6CA739.5030504@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 19, 2010 at 11:38:33AM +0800, Bian Naimeng wrote:
> 
> 
> J. Bruce Fields 写道:
> > On Wed, Aug 18, 2010 at 04:09:28PM +0800, Bian Naimeng wrote:
> >> When offset larger than LLONG_MAX, it's better to sync all the data of file
> >> than return nfserr_inval.
> > 
> > I believe the current behavior is correct.
> > 
> > See http://marc.info/?l=linux-nfs&m=128200558207974&w=2 for a pynfs-side
> > fix.
> > 
> 
>   Thanks.
> 
>   But why we must return nfserr_inval at nfs layer, the commitarg.offset and
>   writearg.offset are the U64 type, i think maybe we should set the vfs as the
>   authority not nfs for whether the offset is valid when it over 2^63-1.

Hm, good question.  I took a quick look at vfs_fsync_range() and its
other callers but couldn't immediately tell whether checking the
validity of the range is its responsibility or the caller's.

If you can demonstrate that vfs_fsync_range() takes responsibility for
the range-checking, then I'd be fine with removing the checks here.

>   Maybe some day, VFS can support lager offset,

But then I think LLONG_MAX and/or the definition of loff_t would have to
change.

--b.

> we need modify our nfs code again
>   to fit it. So i think which check offset at nfsd4_write and nfsd4_commit is 
>   unnecessary, looks like VFS can return EINVAL for it.


> 
> -- 
> Regards
> Bian Naimeng
> 
> > --b.
> > 
> >> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> >>
> >> ---
> >>  fs/nfsd/vfs.c |   14 ++++++++------
> >>  1 files changed, 8 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> >> index 96360a8..f67fe31 100644
> >> --- a/fs/nfsd/vfs.c
> >> +++ b/fs/nfsd/vfs.c
> >> @@ -1174,20 +1174,23 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >>  {
> >>  	struct file	*file;
> >>  	loff_t		end = LLONG_MAX;
> >> -	__be32		err = nfserr_inval;
> >> +	__be32		err;
> >> +
> >> +	if ((u64)count > ‾(u64)offset)
> >> +		return nfserr_inval;
> >>  
> >>  	if (offset < 0)
> >> -		goto out;
> >> -	if (count != 0) {
> >> +		offset = 0;
> >> +	else if (count != 0) {
> >>  		end = offset + (loff_t)count - 1;
> >>  		if (end < offset)
> >> -			goto out;
> >> +			end = LLONG_MAX;
> >>  	}
> >>  
> >>  	err = nfsd_open(rqstp, fhp, S_IFREG,
> >>  			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &file);
> >>  	if (err)
> >> -		goto out;
> >> +		return err;
> >>  	if (EX_ISSYNC(fhp->fh_export)) {
> >>  		int err2 = vfs_fsync_range(file, offset, end, 0);
> >>  
> >> @@ -1198,7 +1201,6 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >>  	}
> >>  
> >>  	nfsd_close(file);
> >> -out:
> >>  	return err;
> >>  }
> >>  #endif /* CONFIG_NFSD_V3 */
> >> -- 
> >> 1.6.5.2
> 
> 
> -- 
> Regards
> Bian Naimeng
> 
