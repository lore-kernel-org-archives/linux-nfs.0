From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback address
	binding
Date: Tue, 3 Jul 2007 09:01:10 +0200
Message-ID: <20070703070109.GA8558@janus>
References: <20070702154918.GA543@janus>
	<1183424670.6479.38.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5cNq-00023p-0N
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 00:01:10 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5cNr-0001eA-K9
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 00:01:13 -0700
In-Reply-To: <1183424670.6479.38.camel@heimdal.trondhjem.org>
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

On Mon, Jul 02, 2007 at 09:04:30PM -0400, Trond Myklebust wrote:
> On Mon, 2007-07-02 at 17:49 +0200, Frank van Maarseveen wrote:
> 
> > At first I thought fixing the server is the right thing to do because
> > the server behavior is arguably incorrect. Not easy but certainly doable
> > (I'd do it if it has a chance of being accepted). It might also help
> > NATting NFS traffic in some cases. However:
> > 
> > -	I'm not sure if an address check such as in nlmclnt_grant()
> > 	is actually buying us anything.
> 
> Exactly how else is the client going to figure out which lock this
> corresponds to?

The filehandle + pid/svid + lock start + lock end as it is doing right
now. Filehandles offer a pretty strong check already because they are
designed to handle inode reuse too.

The 32 bit pid/svid/lockowner number is conclusive.


> 
> > -	clients requiring a correct callback src address might not
> > 	work with other NFS server implementations and/or (future?)
> > 	concepts for clustering/load balancing.
> 
> NFSv3 development is dead. NLM locking development is doubly so...

Not everyone is using (or can use) NFSv4. This is not about developing
NFSv3 but about optimizing/fixing it in its current deployment.


> 
> > -	Multiple IP addresses may be a workaround for reserved port
> > 	shortage.
> 
> There is _NO_ way for the client to figure out what lock the granted
> request refers to if the server starts transmitting from random IP
> addresses.
>       * There is no universal namespace for filehandles that can be used
>         to identify which file the granted request is meant for
>       * The cookie is not guaranteed to be the same as that sent by the
>         client for the LOCK request
>       * There is nothing else in the nlm_lock that can be used to
>         identify which file we're talking about.

The svid/pid. See nlm_find_lockowner().

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
