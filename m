From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] SUNRPC client: add interface for binding to	a
	local address
Date: Fri, 06 Jul 2007 11:05:15 -0400
Message-ID: <1183734315.6463.67.camel@heimdal.trondhjem.org>
References: <20070705152634.GC6603@janus>
	<1183729576.6463.29.camel@heimdal.trondhjem.org>
	<20070706145026.GA18242@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6pN8-0007hn-Mx
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:05:26 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1++tpWAJfovRmbFaE9O2LP1p/ZmiQksbXo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6pNA-0005hw-FL
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:05:30 -0700
In-Reply-To: <20070706145026.GA18242@janus>
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

On Fri, 2007-07-06 at 16:50 +0200, Frank van Maarseveen wrote:
> On Fri, Jul 06, 2007 at 09:46:16AM -0400, Trond Myklebust wrote:
> > On Thu, 2007-07-05 at 17:26 +0200, Frank van Maarseveen wrote:
<snip>
> > > -struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t size, struct rpc_timeout *to)
> > > +struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap,
> > > +				       size_t size, struct sockaddr *saddr,
> > > +				       struct rpc_timeout *to)
> > 
> > Urgh... It might be time to fold all these arguments into a "struct
> > rpc_xprtsock_create" instead of copying them on the stack.
> 
> Can be done before or after this patch. Or combined, just tell me.

It should definitely be a separate patch. Ideally we should perhaps do
it before this patch since it is a nice cleanup that stands on its own
merits.

<snip>
> > > -	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
> > > +	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %d\n",
> > > +		NIPQUAD(myaddr.sin_addr), port, err);
> > 
> > Hmm... I though you said this was IPv6 clean :-)
> 
> Only the server socket handling code. The other files are not IPv6 clean
> to begin with (I have some ideas for this).

I think Chuck is working on this as part of his IPv6 patchsets.

<snip>
> > Is it safe to assume that the source and destination sockaddr structures
> > are always the same size?
> 
> Well, yes unless there are plans for AF_UNIX support. Look into socket
> getname(), e.g. inet_getname() and inet6_getname(): both addresses of
> a connection must belong to the same address family.

OK.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
