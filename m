From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback address
	binding
Date: Tue, 3 Jul 2007 22:47:11 +0200
Message-ID: <20070703204711.GC16497@janus>
References: <20070702154918.GA543@janus>
	<1183424670.6479.38.camel@heimdal.trondhjem.org>
	<20070703070109.GA8558@janus>
	<1183464206.6494.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5pHF-0002As-Ln
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:47:14 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5pHH-0002EL-Ui
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:47:17 -0700
In-Reply-To: <1183464206.6494.9.camel@heimdal.trondhjem.org>
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

On Tue, Jul 03, 2007 at 08:03:26AM -0400, Trond Myklebust wrote:
> On Tue, 2007-07-03 at 09:01 +0200, Frank van Maarseveen wrote:
> 
> > > There is _NO_ way for the client to figure out what lock the granted
> > > request refers to if the server starts transmitting from random IP
> > > addresses.
> > >       * There is no universal namespace for filehandles that can be used
> > >         to identify which file the granted request is meant for
> > >       * The cookie is not guaranteed to be the same as that sent by the
> > >         client for the LOCK request
> > >       * There is nothing else in the nlm_lock that can be used to
> > >         identify which file we're talking about.
> > 
> > The svid/pid. See nlm_find_lockowner().
> 
> nlm_find_lockowner() allocates a svid/pid that is unique only on a
> per-server basis.

Reading code... hmm, yes. One global 32 bit pid instead of one per server
would remove that problem. Note that this is still a very theoretical
problem because of all the other checks (filehandle check being the most
important one probably).

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
