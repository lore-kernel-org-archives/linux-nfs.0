From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in
 encode_create_session and encode_sequence
Date: Fri, 14 Aug 2009 12:57:35 -0400
Message-ID: <1250269055.5476.11.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>
	 <1250259553-13672-1-git-send-email-bhalevy@panasas.com>
	 <9734995E-20F8-4E53-83CD-BA95145D15ED@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21725 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbZHNQ5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 12:57:35 -0400
In-Reply-To: <9734995E-20F8-4E53-83CD-BA95145D15ED@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-14 at 12:32 -0400, Chuck Lever wrote:
> On Aug 14, 2009, at 10:19 AM, Benny Halevy wrote:
> > Coalesce multilpe constant RESERVE_SPACEs into one
> >
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> > fs/nfs/nfs4xdr.c |   22 +++++-----------------
> > 1 files changed, 5 insertions(+), 17 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index 17915c8..d460d81 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -1562,17 +1562,15 @@ static void encode_create_session(struct  
> > xdr_stream *xdr,
> > 	uint32_t len;
> > 	struct nfs_client *clp = args->client;
> >
> > -	RESERVE_SPACE(4);
> > -	*p++ = cpu_to_be32(OP_CREATE_SESSION);
> > +	len = scnprintf(machine_name, sizeof(machine_name), "%s",
> > +			clp->cl_ipaddr);
> >
> > -	RESERVE_SPACE(8);
> > +	RESERVE_SPACE(20 + 2*28 + 20 + len + 12);
> 
> It would be nicer if we could use the foo_maxsz macros or "n *  
> sizeof(__be32)" here somehow instead of integers.

No. sizeof(__be32) is a constant == 4. Spelling it out in every
reserve_space would be bloat, not documentation.

foo_maxsz is something completely different: it spells out the maximum
possible buffer size. Please don't confuse that with the actual buffer
content size.

IOW: Please just leave the above as it is.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
