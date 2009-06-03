From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [pnfs] [RFC 02/39] nfs41: Skip past the RPC call direction
Date: Wed, 3 Jun 2009 16:30:41 -0700
Message-ID: <273FE88A07F5D445824060902F7003440612B023@SACMVEXC1-PRD.hq.netapp.com>
References: <1244064624.5603.53.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36694 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbZFCXau convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2009 19:30:50 -0400
In-Reply-To: <1244064624.5603.53.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Wednesday, June 03, 2009 2:30 PM
> To: Benny Halevy
> Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: Re: [pnfs] [RFC 02/39] nfs41: Skip past the RPC call
direction
> 
> On Fri, 2009-05-01 at 02:19 +0300, Benny Halevy wrote:
> > From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> >
> > xs_tcp_read_calldir() is now responsible for reading the RPC call
> > direction and determining whether it is a reply or a callback
request.
> > The call to xdr_skb_read_bits() inside xs_tcp_read_calldir() moves
the
> > xdr_skb_reader offset past the RPC call direction (offset should be
> > equal to 8).  Therefore xs_tcp_read_common() called from
> > xs_tcp_ready_reply() should be copying the TCP buffer starting past
the
> > RPC call direction.  It is now necessary to read the RPC call
direction
> > earlier to determine whether to call the reply handler or the
callback
> > handler.
> >
> > call_verify() should therefore skip past the XID and call/reply
flag.
> >
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  net/sunrpc/clnt.c |   13 +++++++------
> >  1 files changed, 7 insertions(+), 6 deletions(-)
> >
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index d00e813..76d7d46 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1390,13 +1390,14 @@ rpc_verify_header(struct rpc_task *task)
> >  	}
> >  	if ((len -= 3) < 0)
> >  		goto out_overflow;
> > -	p += 1;	/* skip XID */
> >
> > -	if ((n = ntohl(*p++)) != RPC_REPLY) {
> > -		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
> > -				task->tk_pid, __func__, n);
> > -		goto out_garbage;
> > -	}
> > +	/*
> > +	 * Skip the XID and call direction.
> > +	 * The underlying transport has read the XID and RPC call
direction
> > +	 * to determine this is an RPC reply.
> > +	 */
> > +	p += 2;
> > +
> >  	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
> >  		if (--len < 0)
> >  			goto out_overflow;
> 
> Err... No... The above comment is true only for the case of TCP. Why
> don't you simply copy the RPC call direction into the buffer?

You're right.  We'll follow your suggestion to copy it into the buffer
and leave the processing as it originally was in rpc_verify_header().

- ricardo


> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
