From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback
	address	binding
Date: Mon, 02 Jul 2007 21:04:30 -0400
Message-ID: <1183424670.6479.38.camel@heimdal.trondhjem.org>
References: <20070702154918.GA543@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5Wot-0006FV-T9
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 18:04:44 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+FiVbEPfcIaN1o/s53C/gu3FmsxdSX53Q=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5Wov-000334-Lo
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 18:04:47 -0700
In-Reply-To: <20070702154918.GA543@janus>
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

On Mon, 2007-07-02 at 17:49 +0200, Frank van Maarseveen wrote:

> At first I thought fixing the server is the right thing to do because
> the server behavior is arguably incorrect. Not easy but certainly doable
> (I'd do it if it has a chance of being accepted). It might also help
> NATting NFS traffic in some cases. However:
> 
> -	I'm not sure if an address check such as in nlmclnt_grant()
> 	is actually buying us anything.

Exactly how else is the client going to figure out which lock this
corresponds to?

> -	clients requiring a correct callback src address might not
> 	work with other NFS server implementations and/or (future?)
> 	concepts for clustering/load balancing.

NFSv3 development is dead. NLM locking development is doubly so...

> -	Multiple IP addresses may be a workaround for reserved port
> 	shortage.

There is _NO_ way for the client to figure out what lock the granted
request refers to if the server starts transmitting from random IP
addresses.
      * There is no universal namespace for filehandles that can be used
        to identify which file the granted request is meant for
      * The cookie is not guaranteed to be the same as that sent by the
        client for the LOCK request
      * There is nothing else in the nlm_lock that can be used to
        identify which file we're talking about.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
