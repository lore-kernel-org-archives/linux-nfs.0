From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 14:07:38 -0400
Message-ID: <1179943658.6707.19.camel@heimdal.trondhjem.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<20070523162908.GP14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Neil Brown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqvFY-0002yF-1A
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:07:52 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18cYt52acHTgn3K6QPEOis9ZELz2C20opE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqvFZ-0000He-79
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:07:55 -0700
In-Reply-To: <20070523162908.GP14076@sgi.com>
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

On Thu, 2007-05-24 at 02:29 +1000, Greg Banks wrote:
> On Wed, May 23, 2007 at 11:03:06AM -0400, Trond Myklebust wrote:
> > On NFSv4, dropping a request requires the server to also drop the
> > connection.
> 
> <pokes around in RFC3530>
> 
> Egads, you're right, there it is in section 3.1.1.  Oh I see, it's
> new since RFC 3010, the last nfs4 document I read.  I need to get up
> to date!
> 
> A quick look at the source seems to indicate that this is currently
> broken.  Neither nfsd4_proc_compound() nor nfsd_dispatch() do anything
> special for the (nfserr_dropit, vers=4) corner.  And I can see at least
> one path where nfserr_dropit can percolate back up to nfsd_dispatch().
> 
> Does the client obey RFC3530 and not retry?  If so we should expect
> to see file corruption doing pure WRITE workloads on NFSv4 when any
> of the server caches expires.

The client will eventually retry (after the 60 second delay), but the
convention is that it must break the connection before it does so.

> > Unless you are completely out of resources, you are
> > inevitably better off having the server return an NFS4ERR_DELAY or
> > something like that.
> 
> So we could translate nfserr_dropit -> nfserr_jukebox ?
> I notice that nfs4_new_open() does that.

Yes. For NFSv3 and NFSv4 that is infinitely better than dropping the
request, and will result in faster client recovery.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
