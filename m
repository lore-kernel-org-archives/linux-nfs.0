From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Thu, 24 May 2007 02:35:58 +1000
Message-ID: <20070523163558.GQ14076@sgi.com>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<1179933123.9389.157.camel@trinity.ogc.int>
	<1179934639.6480.58.camel@heimdal.trondhjem.org>
	<1179936164.9389.165.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Neil Brown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqtoh-0000xN-5z
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:36:03 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+s/c+ZUDdBxq6cICCX21b+0MettMhJTiE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqtoj-0000hx-U5
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:36:06 -0700
In-Reply-To: <1179936164.9389.165.camel@trinity.ogc.int>
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

On Wed, May 23, 2007 at 11:02:44AM -0500, Tom Tucker wrote:
> On Wed, 2007-05-23 at 11:37 -0400, Trond Myklebust wrote:
> > On Wed, 2007-05-23 at 10:12 -0500, Tom Tucker wrote:
> > > Ah, this is a very good point. So then I think we need a transport
> > > specific deferral mechanism. 
> > 
> > No. I'm not sure that justifies a transport specific mechanism. It
> > rather calls for a more clever algorithm for deferring. Both NFSv3 and
> > NFSv4 have generic error messages that state 'I'm busy now, please try
> > again later'. As I said earlier, returning those errors are inevitably
> > more efficient than dropping.
> > Even for NFSv3 over TCP, dropping a single WRITE request will typically
> > cause a 60 second flat holdup instead of the more desirable retry +
> > exponential backoff.
> 
> Understood. My concern is very simple. I don't want to copy the data and
> to avoid this I need to have a way to save off the data for later
> processing in a transport specific way. All of my data is sitting in
> this rdma_context structure. 
> 
> The current svcsock approach just does a kmalloc and a memcpy. This is
> not a good approach for a 1MB NFS WRITE. 

Sure, but this is true regardless of the transport.

> An approach that allows a transport to give a "data cookie" to the
> deferral mechanism for later recovery would allow all the complexity to
> be centralized, but still allow the transport to keep the data around in
> it's own way.

I'm still confused.  Which data are you referring to?  Which
rdma_context structure, I don't see anything symbol like that in
the source?

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
