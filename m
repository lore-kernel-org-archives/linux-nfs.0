From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback
	address	binding
Date: Tue, 03 Jul 2007 08:03:26 -0400
Message-ID: <1183464206.6494.9.camel@heimdal.trondhjem.org>
References: <20070702154918.GA543@janus>
	<1183424670.6479.38.camel@heimdal.trondhjem.org>
	<20070703070109.GA8558@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5mdX-0000dx-Rx
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 10:58:03 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+sC+Lm9+lDCRNcQyKkVOeuPDV4iAYXQXg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5mdb-0003ZM-3h
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 10:58:07 -0700
In-Reply-To: <20070703070109.GA8558@janus>
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

On Tue, 2007-07-03 at 09:01 +0200, Frank van Maarseveen wrote:

> > There is _NO_ way for the client to figure out what lock the granted
> > request refers to if the server starts transmitting from random IP
> > addresses.
> >       * There is no universal namespace for filehandles that can be used
> >         to identify which file the granted request is meant for
> >       * The cookie is not guaranteed to be the same as that sent by the
> >         client for the LOCK request
> >       * There is nothing else in the nlm_lock that can be used to
> >         identify which file we're talking about.
> 
> The svid/pid. See nlm_find_lockowner().

nlm_find_lockowner() allocates a svid/pid that is unique only on a
per-server basis.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
