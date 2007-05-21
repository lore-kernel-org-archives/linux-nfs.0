From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Mon, 21 May 2007 10:49:57 -0500
Message-ID: <1179762597.23385.231.camel@trinity.ogc.int>
References: <1179510331.23385.120.camel@trinity.ogc.int>
	<18001.17544.798341.277657@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqA93-0005xM-AP
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:50:01 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqA96-00028T-0Q
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:50:04 -0700
In-Reply-To: <18001.17544.798341.277657@notabene.brown>
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

On Mon, 2007-05-21 at 17:04 +1000, Neil Brown wrote:
> On Friday May 18, tom@opengridcomputing.com wrote:
> > Adds a call to the svc_makesock routine to create the RDMA transport. 
> > I think this should somehow be linked to the transport switch and the 
> > port mapper. 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/nfsd/nfssvc.c |   11 +++++++++++
> >  1 files changed, 11 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index d7759ce..4a7982e 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -254,6 +254,17 @@ #ifdef CONFIG_NFSD_TCP
> >  	if (error < 0)
> >  		return error;
> >  #endif
> > +#ifdef CONFIG_NFSD_RDMA
> > +	/* KLUDGE: The rpc.nfsd utility passes down the
> > +	 * port number when it opens the nfsd file. We are
> > +	 * going to ignore it here and force the RDMA port number
> > +	 * to 2050. This will allow the TCP transport to coexist
> > +	 * with the RDMA transport.
> > +	 */
> > +	error = svc_makesock(nfsd_serv, IPPROTO_MAX, 2050 /* port */, 0);
> > +	if (error < 0)
> > +		return error;
> > +#endif
> >  	return 0;
> >  }
> >  
> 
> As you say:  KLUDGE.
> 
> What is really going on here?  Why don't we have a protocol number,
> and why can't we use port 2049?
> 
> I don't know a lot about RDMA (feel free to educate me) but it seems
> that there is some connection to IP (is this IPoIB??) in that IP
> address seem to be available for the end points.

"RDMA" actually refers to two different transports: IB (not IPoIB), and
iWARP (RDDP on TCP). In the first case, IP is not the transport (so no
number), in the second case, TCP is actually the IP protocol, so there
is no RDMA-unique protocol number. I just stole IPPROTO_MAX as an ...
um ... workaround. 

What I think we need here is a "transport number". Transports that
register with the transport switch have a number that is passed in here
to create a listening endpoint of the appropriate type. This
infrastructure isn't there yet, but I believe Greg is noodling on a way
to do this.

> 
> Can you distinguish an RDMA connection from any other IP connection
> simply based on the interface it gets routed through?
> 

Unfortunately no for two reasons: iWARP interfaces support all of the
protocol types with the same IP address, therefore, the port number 2050
so we can distinguish between listening endpoints for TCP mounts vs.
iWARP mounts. Port number 2050 is being proposed in the IANA for the
NFS-RDMA service. 

> Can you actually get any sort of socket representing an RDMA
> connection?  I appreciate that normal sendmsg/recvmsg calls on the
> socket aren't going to work, but I'm dreaming that maybe a
> socket-level 'accept' could establish the connection.  Then we look at
> the connection, discover it is on a RDMA-capable device, and start
> using the RDMA interface to move data around.
> Does that make any sense at all, or am I totally off-beam?

No, you're right in the middle of it. The OFA API has a sockets-like
interface for connection management. The API has things like
rdma_create_id (socket), rdma_listen (listen), rdma_connect (connect),
etc... It is, however, not a socket. It is certainly possible to create
a sockets abstraction and in-fact it has been done, but the compromises
involved (no private data, no path record selection, etc...) were deemed
to onerous and they created there own.

Tom
> 
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
