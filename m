Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44403 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab1ARXTj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 18:19:39 -0500
Date: Tue, 18 Jan 2011 18:19:36 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: do common error handling in
 decode_cb_op_status
Message-ID: <20110118231936.GH10903@fieldses.org>
References: <4D2EC4AC.9090205@panasas.com>
 <1294910741-18407-1-git-send-email-bhalevy@panasas.com>
 <A454C748-0AA0-4380-961C-57ACD35F39BC@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A454C748-0AA0-4380-961C-57ACD35F39BC@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 18, 2011 at 05:20:41PM -0500, Chuck Lever wrote:
> 
> On Jan 13, 2011, at 4:25 AM, Benny Halevy wrote:
> 
> > Rather than handling the cb operation status in each and every
> > decode_cb_op_status's caller, just put the common code there.
> > 
> > If need be, and some caller really needs to see the original status
> > this patch can be reverted but right now there's no real need for the
> > abstract functionality.
> 
> a) all the other new status decoders do it the generic way, so this would be a special case.  We already know it's not needed here at this point, but it is consistent with the other decoders.
> 
> b) we lose the distinction between a returned status code and a decoding error.  I recall finding a few bugs in the other decoders where the two are conflated.
> 
> I'd rather not apply this one.  I think it's premature and unneeded optimization.  I'm sure I'll be voted down, though.

I think what you mean to say is: "if you vote me down, I shall become
more powerful than you can possibly imagine."

Anyway, I suppose if we fix the callback error handling soon (as we
should) then we'd be reverting this soon anyway, so I'll drop this one
for now.

--b.

> 
> > 
> > Cc: Chuck Lever <chuck.lever@oracle.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> > fs/nfsd/nfs4callback.c |   22 +++++++---------------
> > 1 files changed, 7 insertions(+), 15 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 5a6dcf8..6f69645 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -248,11 +248,11 @@ static int nfs_cb_stat_to_errno(int status)
> > 	return -status;
> > }
> > 
> > -static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
> > -			       enum nfsstat4 *status)
> > +static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected)
> > {
> > 	__be32 *p;
> > 	u32 op;
> > +	enum nfsstat4 status;
> > 
> > 	p = xdr_inline_decode(xdr, 4 + 4);
> > 	if (unlikely(p == NULL))
> > @@ -260,7 +260,9 @@ static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
> > 	op = be32_to_cpup(p++);
> > 	if (unlikely(op != expected))
> > 		goto out_unexpected;
> > -	*status = be32_to_cpup(p);
> > +	status = be32_to_cpup(p);
> > +	if (unlikely(status != NFS4_OK))
> > +		return nfs_cb_stat_to_errno(status);
> > 	return 0;
> > out_overflow:
> > 	print_overflow_msg(__func__, xdr);
> > @@ -469,22 +471,17 @@ out_overflow:
> > static int decode_cb_sequence4res(struct xdr_stream *xdr,
> > 				  struct nfsd4_callback *cb)
> > {
> > -	enum nfsstat4 nfserr;
> > 	int status;
> > 
> > 	if (cb->cb_minorversion == 0)
> > 		return 0;
> > 
> > -	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &nfserr);
> > +	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE);
> > 	if (unlikely(status))
> > 		goto out;
> > -	if (unlikely(nfserr != NFS4_OK))
> > -		goto out_default;
> > 	status = decode_cb_sequence4resok(xdr, cb);
> > out:
> > 	return status;
> > -out_default:
> > -	return nfs_cb_stat_to_errno(nfserr);
> > }
> > 
> > /*
> > @@ -547,7 +544,6 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
> > 				  struct nfsd4_callback *cb)
> > {
> > 	struct nfs4_cb_compound_hdr hdr;
> > -	enum nfsstat4 nfserr;
> > 	int status;
> > 
> > 	status = decode_cb_compound4res(xdr, &hdr);
> > @@ -560,11 +556,7 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
> > 			goto out;
> > 	}
> > 
> > -	status = decode_cb_op_status(xdr, OP_CB_RECALL, &nfserr);
> > -	if (unlikely(status))
> > -		goto out;
> > -	if (unlikely(nfserr != NFS4_OK))
> > -		status = nfs_cb_stat_to_errno(nfserr);
> > +	status = decode_cb_op_status(xdr, OP_CB_RECALL);
> > out:
> > 	return status;
> > }
> > -- 
> > 1.7.3.4
> > 
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
