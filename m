From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: fragment flooding and self-configuring clients
Date: Thu, 27 Jun 2002 09:17:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D041@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, "'Benjamin LaHaise'" <bcrl@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Nbxy-0006J7-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 09:17:54 -0700
To: "'Trond Myklebust'" <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> > the issue i have with the implementation you have chosen in
> > the rpc_tweak patch is that the socket buffer size it computes
> > is often too large.  for instance, why (server->rsize + 1024) ?
> > the real size of a full-sized read request is probably closer to
> > (server->rsize + 160).  then, after all the multiplication
> 
> Actually, the RPC code can in principle be around 600 bytes 
> long. Don't 
> forget, the authentication code alone can in principle be 408 
> bytes long 
> (although AUTH_SYS is of course significantly shorter).
> In addition, the socket code likes a bit of padding of its 
> own. It needs to be 
> able to split up skbs, juggle them around etc.
> 
> > in xprt_set_sockbufsize, it is possible to get an excessively
> > large buffer size.  there is no cap for this value, and i'm
> > sure there is a reasonable maximum.  on one of my systems, the
> > computed value was over 3 megabytes.  might this cause some
> > kind of data corruption if a buffer of that size can't actually
> > be allocated?

another thought occurred to me.  the interface to all this should
allow the socket layer to limit rsize and wsize if there isn't
enough space to allocate a buffer large enough.  instead of this:

   xprt_setbufsize(xprt, server->wsize + 1024, server->rsize + 1024);

the interface should look like:

    xprt_setbufsize(xprt, server);

and if the socket layer needs to, it can lower the wsize and rsize
values accordingly.  (the magic overhead numbers should probably be
determined by the RPC layer anyway, not by the NFS client).

just a thought.


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
