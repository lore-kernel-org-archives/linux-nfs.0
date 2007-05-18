From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC, PATCH 4/15] knfsd: map null socket to
	SOCK_STREAM	in	svc_max_payload
Date: Fri, 18 May 2007 13:40:40 -0500
Message-ID: <1179513640.23385.137.camel@trinity.ogc.int>
References: <1179510307.23385.117.camel@trinity.ogc.int>
	<20070518182850.GA4843@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7Nc-00078z-5M
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:40:44 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp7Ne-0000KV-LW
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:40:47 -0700
In-Reply-To: <20070518182850.GA4843@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 14:28 -0400, J. Bruce Fields wrote:
> On Fri, May 18, 2007 at 12:45:07PM -0500, Tom Tucker wrote:
> > 
> > The svc_max_payload function looks into the sk_sock structure to determine
> > what the reported max payload should be. For RDMA, there is no socket. This 
> > change effectively maps a NULL sk_sock to SOCK_STREAM.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  net/sunrpc/svc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index 9fec17d..b343db8 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1024,7 +1024,7 @@ u32 svc_max_payload(const struct svc_rqs
> >  {
> >  	int max = RPCSVC_MAXPAYLOAD_TCP;
> >  
> > -	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> > +	if (rqstp->rq_sock->sk_sock && rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> >  		max = RPCSVC_MAXPAYLOAD_UDP;
> >  	if (rqstp->rq_server->sv_max_payload < max)
> >  		max = rqstp->rq_server->sv_max_payload;
> 
> Don't you want to use Greg's sko_max_payload() (or whatever it ends up
> being) for this?

Yes, however, we don't know what it's going to end up being yet and I'd
like to get this code reviewed, so I can work the issues in parallel.
BTW, the current transport switch (before the mods) is up and running in
several locations. 

> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
