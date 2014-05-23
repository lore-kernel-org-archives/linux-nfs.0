Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37378 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbaEWNPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 09:15:39 -0400
Date: Fri, 23 May 2014 09:15:36 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/52] nfsd4: READ, READDIR, etc., are idempotent
Message-ID: <20140523131536.GH25423@fieldses.org>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-2-git-send-email-bfields@redhat.com>
 <537EA2A2.2040907@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537EA2A2.2040907@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 09:21:38AM +0800, Kinglong Mee wrote:
> On 5/23/2014 03:31, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > OP_MODIFIES_SOMETHING flags operations that we should be careful not to
> > initiate without being sure we have the buffer space to encode a reply.
> > 
> > None of these ops fall into that category.
> > 
> > We could probably remove a few more, but this isn't a very important
> > problem at least for ops whose reply size is easy to estimate.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4proc.c | 13 +++----------
> >  1 file changed, 3 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index ac83778..4c4cd96 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1665,38 +1665,31 @@ static struct nfsd4_operation nfsd4_ops[] = {
> >  	[OP_PUTFH] = {
> >  		.op_func = (nfsd4op_func)nfsd4_putfh,
> >  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> > -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> > -				| OP_CLEAR_STATEID,
> > +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
> >  		.op_name = "OP_PUTFH",
> >  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
> >  	},
> >  	[OP_PUTPUBFH] = {
> >  		.op_func = (nfsd4op_func)nfsd4_putrootfh,
> >  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> > -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> > -				| OP_CLEAR_STATEID,
> > +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
> >  		.op_name = "OP_PUTPUBFH",
> >  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
> >  	},
> >  	[OP_PUTROOTFH] = {
> >  		.op_func = (nfsd4op_func)nfsd4_putrootfh,
> >  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> > -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> > -				| OP_CLEAR_STATEID,
> > +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
> >  		.op_name = "OP_PUTROOTFH",
> >  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
> >  	},
> >  	[OP_READ] = {
> >  		.op_func = (nfsd4op_func)nfsd4_read,
> > -		.op_flags = OP_MODIFIES_SOMETHING,
> > -		.op_name = "OP_READ",
> 
> Should not delete op_name.
> 
> >  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
> >  		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
> >  	},
> >  	[OP_READDIR] = {
> >  		.op_func = (nfsd4op_func)nfsd4_readdir,
> > -		.op_flags = OP_MODIFIES_SOMETHING,
> > -		.op_name = "OP_READDIR",
> 
> Same as above.
> 
> Because "[PATCH 03/52] nfsd4: fill in some missing op_name's" re-adds them.

Good grief--I should have checked when those op_name's diseappeared
before making the new patch.  Thanks.

--b.
