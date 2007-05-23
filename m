From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 11:03:06 -0400
Message-ID: <1179932586.6480.53.camel@heimdal.trondhjem.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
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
	id 1HqsMz-00083A-FE
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:03:27 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18OPuOOma66e4GGGVGc8AgEThfxSmjC4NA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqsN2-00024B-1w
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:03:24 -0700
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
> Currently neither svc_defer() nor svc_rdma_defer() support calls longer
> than just the head, meaning that WRITE RPCs (only) are dropped and
> retried instead of deferred.  This doesn't seem to be too much of a
> problem; deferral happens so infrequently anyway.

That still isn't a good tactic.

On NFSv4, dropping a request requires the server to also drop the
connection. Unless you are completely out of resources, you are
inevitably better off having the server return an NFS4ERR_DELAY or
something like that.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
