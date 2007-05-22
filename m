From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 5/14] knfsd: max_payload per transport
Date: Tue, 22 May 2007 17:16:17 +1000
Message-ID: <20070522071617.GE1202@sgi.com>
References: <20070516192306.GK9626@sgi.com>
	<17996.12194.801580.925774@notabene.brown>
	<1179415386.23385.5.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqObc-0003Wu-Uf
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 00:16:29 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HqObd-0006Af-Mg
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 00:16:31 -0700
In-Reply-To: <1179415386.23385.5.camel@trinity.ogc.int>
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

On Thu, May 17, 2007 at 10:23:06AM -0500, Tom Tucker wrote:
> On Thu, 2007-05-17 at 20:34 +1000, Neil Brown wrote:
> > On Thursday May 17, gnb@sgi.com wrote:
> > > 
> > > Make svc_max_payload() delegate to a new method in svc_sock_ops
> > > instead of reaching into the socket (beause later the NFS/RDMA
> > > transport will not even have a socket).
> > > 
> > > Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> > > Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> > ..
> > >  
> > > +static u32 svc_tcp_max_payload(struct svc_sock *svsk)
> > > +{
> > > +	return RPCSVC_MAXPAYLOAD_TCP;
> > > +}
> > > +
> > 
> > Seeing these are implementation (or protocol) defined constants, do we
> > really need a function call?  How about a
> > 	int max_payload;
> > in struct svc_sock_ops??  Or is it tacky to put an integer in a *_ops
> > structure? 
> 
> I think if we called it a "svc_transport" structure instead of a
> "svc_sock_ops" structure, it removes the tackiness. It's also more
> accurate since "svc_sock_ops" implies these are socket ops which they
> are not.

I like this idea, so I renamed

svc_sock_ops -> svc_transport_type
sko_foo -> st_foo
sk_ops -> sk_type

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
