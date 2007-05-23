From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 10:03:42 -0500
Message-ID: <1179932622.9389.153.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqsNN-00083h-S2
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:03:46 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqsNQ-0004qR-I6
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:03:48 -0700
In-Reply-To: <20070523145557.GN14076@sgi.com>
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

On Thu, 2007-05-24 at 00:55 +1000, Greg Banks wrote:
> On Wed, May 23, 2007 at 09:43:30AM -0500, Tom Tucker wrote:
> > 
> > > Tom, just curious but in the November there was actually a difference
> > > between the sockets and RDMA versions, the latter didn't have this
> > > line:
> > > 
> > >         rqstp->rq_res.buflen = PAGE_SIZE;
> > 
> > I changed the defer logic quite a bit. In fact, I don't think it worked
> > last November when you got the code originally. The latest code is at
> > linux-nfs.org/~tomtucker/linux-nfs-2.6.git
> 
> Thanks.  I have a checkout from there as of several days ago but
> I haven't ported all my patches to use it yet.
> 
> > > So perhaps a better approach would be to slightly tweak the existing
> > > generic defer & revisit logic to allow a transport to specify how
> > > many bytes of transport header need to be preserved.  Then the
> > > transport-specific code needs very little code to support defer &
> > > revisit, and doesn't duplicate multiple complex and subtle functions
> > > which mess with svc_sock internals.
> > 
> > The svcsock defer logic only supports a simple RPC without a page list.
> > The logic even has a comment that says "FIX ME". So I assumed that in
> > the fullness of time, any RPC could be deferred. If this is in fact the
> > case, then I believe it is better to have a separate method. If it is
> > not the case, then the defer logic can be made generic.  
> 
> I'm not sure what you mean here.
> 
> Currently neither svc_defer() nor svc_rdma_defer() support calls longer
> than just the head, meaning that WRITE RPCs (only) are dropped and
> retried instead of deferred.  This doesn't seem to be too much of a
> problem; deferral happens so infrequently anyway.
> 
> If for some reason the svc_defer() was to have the "FIXME" actually
> implemented, WRITE RPCs would magically start to be deferred rather
> than dropped, for the sockets case and presumably also for the
> RDMA case.  Is this a problem?
> 

That's what I'm asking. I don't think it is, and if not, then I concur
we can normalize the defer logic.


> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
