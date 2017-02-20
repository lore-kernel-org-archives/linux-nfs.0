Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56690 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753669AbdBTQJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Feb 2017 11:09:43 -0500
Date: Mon, 20 Feb 2017 11:09:41 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Dros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
Message-ID: <20170220160940.GB12335@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com>
 <1D136924-2EC7-4CF3-8250-98799DFBEB3F@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1D136924-2EC7-4CF3-8250-98799DFBEB3F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 19, 2017 at 02:29:03PM -0500, Chuck Lever wrote:
> 
> > On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > From: Weston Andros Adamson <dros@netapp.com>
> > 
> > Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
> > allocate whatever pages we need on demand.  This is what the NFSv3 ACL
> > code does.
> 
> The patch description does not explain why this change is
> being done.

The only justification I see is avoiding allocating pages unnecessarily.
Without this patch, for each getacl, we allocate 17 pages (if I'm
calculating correctly) and probably rarely use most of them.

In the v3 case I think it's 7 pages instead of 17.

Do we have reason to believe that's actually a big deal?

--b.

> The matching hack in xprtrdma is in rpcrdma_convert_iovs().
> Note that those are GFP_ATOMIC allocations, whereas here
> they are GFP_KERNEL, and are thus more reliable.
> 
> IMO this is a step in the wrong direction. We should not be
> adding more upper layer dependencies on memory allocation
> in the transport layer.
> 
> I strongly prefer that rather the NFSACL code works the way
> this code currently does, and that the hacks be removed from
> the transport implementations.
> 
> 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> > fs/nfs/nfs4proc.c | 23 +++++++----------------
> > 1 file changed, 7 insertions(+), 16 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 3e3dbba4aa74..7842c73fddfc 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -5068,6 +5068,7 @@ static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
> > 	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
> > 	struct nfs_getaclargs args = {
> > 		.fh = NFS_FH(inode),
> > +		/* The xdr layer may allocate pages here. */
> 
> Sure, it is called xdr_partial_copy_from_skb, but that function
> lives in socklib.c and is invoked only from xprtsock.c. Also, a
> similar hack has to be done in xprtrdma.
> 
> So IMO this is a transport layer hack, and not part of the
> (generic) XDR layer.
> 
> 
> > 		.acl_pages = pages,
> > 	};
> > 	struct nfs_getaclres res = {
> > @@ -5079,32 +5080,22 @@ static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
> > 		.rpc_argp = &args,
> > 		.rpc_resp = &res,
> > 	};
> > -	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
> > -	int ret = -ENOMEM, i;
> > -
> > -	if (npages > ARRAY_SIZE(pages))
> > -		return -ERANGE;
> > -
> > -	for (i = 0; i < npages; i++) {
> > -		pages[i] = alloc_page(GFP_KERNEL);
> > -		if (!pages[i])
> > -			goto out_free;
> > -	}
> > +	int ret, i;
> > 
> > 	/* for decoding across pages */
> > 	res.acl_scratch = alloc_page(GFP_KERNEL);
> > 	if (!res.acl_scratch)
> > -		goto out_free;
> > +		return -ENOMEM;
> > 
> > -	args.acl_len = npages * PAGE_SIZE;
> > +	args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
> > 
> > -	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
> > -		__func__, buf, buflen, npages, args.acl_len);
> > +	dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
> > +		__func__, buf, buflen, args.acl_len);
> > 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> > 			     &msg, &args.seq_args, &res.seq_res, 0);
> > 	if (ret == 0)
> > 		ret = res.acl_len;
> > -out_free:
> > +
> > 	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
> > 		__free_page(pages[i]);
> > 	__free_page(res.acl_scratch);
> > -- 
> > 2.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
