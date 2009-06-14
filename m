From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 11/14] SQUASHME: Moves embedded #ifdefs into #ifdef
 function blocks
Date: Sun, 14 Jun 2009 12:55:06 -0400
Message-ID: <1244998506.5298.2.camel@heimdal.trondhjem.org>
References: <> <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1244786060-2200-12-git-send-email-Ricardo.Labiaga@netapp.com>
	 <4A350B99.90104@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29691 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbZFNQzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Jun 2009 12:55:05 -0400
In-Reply-To: <4A350B99.90104@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-06-14 at 10:39 -0400, Benny Halevy wrote:
> On Jun. 12, 2009, 1:54 -0400, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> > [squash with: nfs41: New xs_tcp_read_data()]
> > 
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > ---
> >  net/sunrpc/xprtsock.c |   28 ++++++++++++++++++----------
> >  1 files changed, 18 insertions(+), 10 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index fe57ebd..c6f24c0 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1207,6 +1207,23 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
> >  
> >  	return 0;
> >  }
> > +
> > +static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
> > +					struct xdr_skb_reader *desc)
> > +{
> > +	struct sock_xprt *transport =
> > +				container_of(xprt, struct sock_xprt, xprt);
> > +
> > +	return (transport->tcp_flags & TCP_RPC_REPLY) ?
> > +		xs_tcp_read_reply(xprt, desc) :
> > +		xs_tcp_read_callback(xprt, desc);
> > +}
> > +#else
> > +static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
> > +					struct xdr_skb_reader *desc)
> > +{
> > +	return xs_tcp_read_reply(xprt, desc);
> > +}
> >  #endif /* CONFIG_NFS_V4_1 */
> 
> Again, I'd be inclined to avoid duplicating code.
> If we want still to use an #ifdef (and in this case
> we might as well just always check the tcp_flags)
> the I'd suggest to code this as follows:
> 
> static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
> 				    struct xdr_skb_reader *desc)
> {
> #ifdef /* CONFIG_NFS_V4_1 */
> 	struct sock_xprt *transport =
> 				container_of(xprt, struct sock_xprt, xprt);
> 
> 	if (!(transport->tcp_flags & TCP_RPC_REPLY))
> 		return xs_tcp_read_callback(xprt, desc);
> #ifdef /* CONFIG_NFS_V4_1 */
> 
> 	return xs_tcp_read_reply(xprt, desc);
> }
> 
> Benny
> 
> >  
> >  /*
> > @@ -1218,17 +1235,8 @@ static void xs_tcp_read_data(struct rpc_xprt *xprt,
> >  {
> >  	struct sock_xprt *transport =
> >  				container_of(xprt, struct sock_xprt, xprt);
> > -	int status;
> > -
> > -#if defined(CONFIG_NFS_V4_1)
> > -	status = (transport->tcp_flags & TCP_RPC_REPLY) ?
> > -		xs_tcp_read_reply(xprt, desc) :
> > -		xs_tcp_read_callback(xprt, desc);
> > -#else
> > -	status = xs_tcp_read_reply(xprt, desc);
> > -#endif /* CONFIG_NFS_V4_1 */
> >  
> > -	if (status == 0)
> > +	if (_xs_tcp_read_data(xprt, desc) == 0)
> >  		xs_tcp_check_fraghdr(transport);
> >  	else {
> >  		/*
> 

NO! Just put the bits that are v4.1 specific in a function (make said
function empty in the !v4.1 case, and call it from the common code.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
