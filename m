From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Thu, 24 May 2007 02:29:08 +1000
Message-ID: <20070523162908.GP14076@sgi.com>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Neil Brown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqti9-0000L0-VJ
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:29:18 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HqtiC-0007BE-N7
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:29:21 -0700
In-Reply-To: <1179932586.6480.53.camel@heimdal.trondhjem.org>
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

On Wed, May 23, 2007 at 11:03:06AM -0400, Trond Myklebust wrote:
> On Thu, 2007-05-24 at 00:55 +1000, Greg Banks wrote:
> > Currently neither svc_defer() nor svc_rdma_defer() support calls longer
> > than just the head, meaning that WRITE RPCs (only) are dropped and
> > retried instead of deferred.  This doesn't seem to be too much of a
> > problem; deferral happens so infrequently anyway.
> 
> That still isn't a good tactic.
> 
> On NFSv4, dropping a request requires the server to also drop the
> connection.

<pokes around in RFC3530>

Egads, you're right, there it is in section 3.1.1.  Oh I see, it's
new since RFC 3010, the last nfs4 document I read.  I need to get up
to date!

A quick look at the source seems to indicate that this is currently
broken.  Neither nfsd4_proc_compound() nor nfsd_dispatch() do anything
special for the (nfserr_dropit, vers=4) corner.  And I can see at least
one path where nfserr_dropit can percolate back up to nfsd_dispatch().

Does the client obey RFC3530 and not retry?  If so we should expect
to see file corruption doing pure WRITE workloads on NFSv4 when any
of the server caches expires.

One more thing to fix.

> Unless you are completely out of resources, you are
> inevitably better off having the server return an NFS4ERR_DELAY or
> something like that.

So we could translate nfserr_dropit -> nfserr_jukebox ?
I notice that nfs4_new_open() does that.

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
