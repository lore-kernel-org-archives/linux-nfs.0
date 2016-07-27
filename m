Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583AbcG0A0i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2016 20:26:38 -0400
Date: Tue, 26 Jul 2016 20:26:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
Message-ID: <20160727002635.GA12218@fieldses.org>
References: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
 <20160726201947.GA8387@fieldses.org>
 <648c8dc8-85f9-0f90-0126-7316d7967691@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <648c8dc8-85f9-0f90-0126-7316d7967691@jp.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 27, 2016 at 08:57:26AM +0900, Seiichi Ikarashi wrote:
> Hi Bruce,
> 
> On 2016-07-27 05:19, J. Bruce Fields wrote:
> > Thanks for the report.
> > 
> > On Tue, Jul 26, 2016 at 11:38:11AM +0900, Seiichi Ikarashi wrote:
> >> If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
> >> nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
> >> actually occurred with a parallel distributed file system. It needs boundary
> >> checking.
> > 
> > This check might be useful as defensive programming, but the bug was
> > elsewhere.
> 
> Yah, I think the main factor exists in file system and/or VFS splice sides.
> But I also think that NFS should defend itself against overlimit pages
> because the limit is decided by NFS/SUNRPC, not by file system and others.
> 
> > 
> > In theory this should be prevented by the "maxcount" calculations in
> > nfsd4_encode_read().
> 
> The "maxcount" looks just limiting the read length from the file system.
> Is my understanding correct?

Right.

> 
> And the number of pages provided from the file system is up to the file system.
> The file system can split the read data into an arbitrary number of pages.

Oh, so if we ask the filesystem for 3 bytes it might potentially return
those in 3 separate pages?  Is that at all legal?

> > What version of the kernel did you see this happen on?  What was the
> > client, and what was it doing?  Any other hints on reproducing?
> 
> It was a NFSv3 read access from a client of maybe-Linux-based system
> against the server of RHEL6 system exporting a file system that I cannot
> access its source code. Sorry for lack of info.

OK, understood.

--b.

> 
> 
> Seiichi.
> 
> 
> > 
> > --b.
> > 
> >>
> >> v2: Fix semicolon-missing bug.
> >>
> >> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
> >>
> >> ---
> >>  fs/nfsd/vfs.c | 8 ++++++++
> >>  1 file changed, 8 insertions(+)
> >>
> >> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> >> index 6fbd81e..43393f3 100644
> >> --- a/fs/nfsd/vfs.c
> >> +++ b/fs/nfsd/vfs.c
> >> @@ -811,12 +811,20 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
> >>  	size = sd->len;
> >>  
> >>  	if (rqstp->rq_res.page_len == 0) {
> >> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
> >> +			WARN_ON(1);
> >> +			return -ENOMEM;
> >> +		}
> >>  		get_page(page);
> >>  		put_page(*rqstp->rq_next_page);
> >>  		*(rqstp->rq_next_page++) = page;
> >>  		rqstp->rq_res.page_base = buf->offset;
> >>  		rqstp->rq_res.page_len = size;
> >>  	} else if (page != pp[-1]) {
> >> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
> >> +			WARN_ON(1);
> >> +			return -ENOMEM;
> >> +		}
> >>  		get_page(page);
> >>  		if (*rqstp->rq_next_page)
> >>  			put_page(*rqstp->rq_next_page);
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > .
> > 
