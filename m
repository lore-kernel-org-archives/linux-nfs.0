Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52762 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbdITSPo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 14:15:44 -0400
Date: Wed, 20 Sep 2017 14:15:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: RPC_MAX_AUTH_SIZE is in bytes
Message-ID: <20170920181544.GH14329@fieldses.org>
References: <20170920164213.GF14329@fieldses.org>
 <20170920164951.GG14329@fieldses.org>
 <A05B2A66-4E15-4294-9110-215A62DE3F91@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A05B2A66-4E15-4294-9110-215A62DE3F91@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 20, 2017 at 12:56:07PM -0400, Chuck Lever wrote:
> 
> > On Sep 20, 2017, at 12:49 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Wed, Sep 20, 2017 at 12:42:13PM -0400, bfields wrote:
> >> From: "J. Bruce Fields" <bfields@redhat.com>
> >> 
> >> The units of RPC_MAX_AUTH_SIZE is bytes, not 4-byte words.  This causes
> >> the client to request a larger-than-necessary session replay slot size.
> > 
> > By the way, the client's still asking for 3428 bytes after that, which
> > seems high.  It's mostly the fault of NFS4_MAXLABELLEN, which is 2048.
> 
> The maximum size of NFSv4 LOOKUP replies is also quite large, thanks
> to label support (IIRC). It would be nicer for NFS/RDMA, at least, if
> the maximum reply sizes of common operations were small (say, less
> than 1024 bytes).
> 
> 
> > I haven't spotted an improvement there yet.
> 
> I haven't either.

Session (and I assume RDMA) limits have to be negotiated pretty early,
before we know server capabilities.  And even if we renegotiated
later--I think security label support is per-filesystem, while the
connection parameters are server-wide.

So, I dunno, all I can think of is putting off fetching the security
label till it's needed, but maybe that's not practical--I don't know
where it's used.

Well, whatever, we can live with it.

--b.

> 
> 
> > Noticed because knfsd was hitting session drc cache limits much to early
> > and failing CREATE_SESSION (hence mount).  The main trouble is on the
> > server side, so I'm relaxing the limits there (and revisiting Trond's
> > dynamic slot renegotiation patches).  But I thought I should check for
> > any easy improvements here too.
> > 
> > --b.
> > 
> >> 
> >> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >> ---
> >> fs/nfs/nfs4xdr.c | 4 ++--
> >> 1 file changed, 2 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> >> index 37c8af003275..14ed9791ec9c 100644
> >> --- a/fs/nfs/nfs4xdr.c
> >> +++ b/fs/nfs/nfs4xdr.c
> >> @@ -1842,8 +1842,8 @@ static void encode_create_session(struct xdr_stream *xdr,
> >> 	 * Assumes OPEN is the biggest non-idempotent compound.
> >> 	 * 2 is the verifier.
> >> 	 */
> >> -	max_resp_sz_cached = (NFS4_dec_open_sz + RPC_REPHDRSIZE +
> >> -			      RPC_MAX_AUTH_SIZE + 2) * XDR_UNIT;
> >> +	max_resp_sz_cached = (NFS4_dec_open_sz + RPC_REPHDRSIZE + 2)
> >> +				* XDR_UNIT + RPC_MAX_AUTH_SIZE;
> >> 
> >> 	encode_op_hdr(xdr, OP_CREATE_SESSION, decode_create_session_maxsz, hdr);
> >> 	p = reserve_space(xdr, 16 + 2*28 + 20 + clnt->cl_nodelen + 12);
> >> -- 
> >> 2.13.5
> >> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
