From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 13:15:24 -0600
Message-ID: <1200942924.11003.58.camel@trinity.ogc.int>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
	 <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
	 <20080121183557.GK17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:59162 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbYAUTIA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 14:08:00 -0500
In-Reply-To: <20080121183557.GK17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 13:35 -0500, J. Bruce Fields wrote:
> On Mon, Jan 21, 2008 at 12:47:08PM -0500, Chuck Lever wrote:
> > Hi Tom-
> >
> > On Jan 21, 2008, at 12:11 PM, Tom Tucker wrote:
> >> Modify the svc_create_xprt function to take a sockaddr instead of just
> >> a port. This approach allows a single transport class,
> >> "tcp" for example, to support both IPv4 and IPv6 connections since
> >> this information is now provided in the sockaddr when the endpoint
> >> is created.  This also allows RPC servers to create listening  
> >> endpoints
> >> on a specific interface.
> >
> > I assume this goes along with the server-side rpcb_register_v3 patches I 
> > proposed last week?
> >
> >> Also modify the svc_xprt_find function to search based on sockaddr so
> >> interface specific endpoints can be searched for.
> >>
> >> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >> ---
> >>
> >>  fs/lockd/svc.c                  |   16 +++--
> >>  fs/nfs/callback.c               |    8 ++
> >>  fs/nfsd/nfsctl.c                |  135 ++++++++++++++++++++++++++++ 
> >> +----------
> >>  fs/nfsd/nfssvc.c                |   11 +++
> >>  include/linux/sunrpc/svc_xprt.h |    4 +
> >>  net/sunrpc/svc_xprt.c           |   96 ++++++++++++++++++++++------
> >>  6 files changed, 206 insertions(+), 64 deletions(-)
> >>
> >> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> >> index 0822646..89e40fb 100644
> >> --- a/fs/lockd/svc.c
> >> +++ b/fs/lockd/svc.c
> >> @@ -229,19 +229,27 @@ static int make_socks(struct svc_serv *serv, int 
> >> proto)
> >>  	static int warned;
> >>  	struct svc_xprt *xprt;
> >>  	int err = 0;
> >> +	struct sockaddr_in sin = {
> >> +		.sin_family = AF_INET,
> >> +		.sin_addr = { INADDR_ANY }
> >> +	};
> >>
> >>  	if (proto == IPPROTO_UDP || nlm_udpport) {
> >> -		xprt = svc_find_xprt(serv, "udp", 0, 0);
> >> +		sin.sin_port = htons(nlm_udpport);
> >> +		xprt = svc_find_xprt(serv, "udp", NULL);
> >>  		if (!xprt)
> >> -			err = svc_create_xprt(serv, "udp", nlm_udpport,
> >> +			err = svc_create_xprt(serv, "udp",
> >> +					      (struct sockaddr *)&sin,
> >>  					      SVC_SOCK_DEFAULTS);
> >>  		else
> >>  			svc_xprt_put(xprt);
> >>  	}
> >>  	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
> >> -		xprt = svc_find_xprt(serv, "tcp", 0, 0);
> >> +		sin.sin_port = htons(nlm_tcpport);
> >> +		xprt = svc_find_xprt(serv, "tcp", NULL);
> >>  		if (!xprt)
> >> -			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
> >> +			err = svc_create_xprt(serv, "tcp",
> >> +					      (struct sockaddr *)&sin,
> >>  					      SVC_SOCK_DEFAULTS);
> >>  		else
> >>  			svc_xprt_put(xprt);
> >
> > This is sort of a generic question.
> >
> > The server-side interface appears to be using strings to identify  
> > transports ("tcp"), but the client-side is still using numbers  
> > (XPRT_TRANSPORT_TCP).  There are one or two sticky issues to fix before 
> > the client-side can use strings, but...
> >
> > Should the server-side use netids instead of arbitrary strings?  I guess 
> > that would be a little awkward because you'd need to use "udp6" for UDP 
> > on IPv6, and so on.
> >
> > In any event, should we use macros for these instead of open-coded  
> > strings?
> 
> If you're proposing something like
> 
> 	#define TCP "tcp"
> 
> I think that's unnecessary obfuscation.

I think the idea was that these strings may change when we normalize the
client and server side, so placing them in a header where they could be
shared might be a good thing.

The name would likely be something like SVC_TCP_CLASS or something. If
we don't ever do that, then yes ... it just obfuscation.

> 
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

