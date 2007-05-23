From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 11:02:44 -0500
Message-ID: <1179936164.9389.165.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<1179933123.9389.157.camel@trinity.ogc.int>
	<1179934639.6480.58.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>, Greg Banks <gnb@sgi.com>,
	Neil Brown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqtIW-000661-54
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:02:48 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqtIY-0008CI-TT
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 09:02:51 -0700
In-Reply-To: <1179934639.6480.58.camel@heimdal.trondhjem.org>
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

On Wed, 2007-05-23 at 11:37 -0400, Trond Myklebust wrote:
> On Wed, 2007-05-23 at 10:12 -0500, Tom Tucker wrote:
> > Ah, this is a very good point. So then I think we need a transport
> > specific deferral mechanism. 
> 
> No. I'm not sure that justifies a transport specific mechanism. It
> rather calls for a more clever algorithm for deferring. Both NFSv3 and
> NFSv4 have generic error messages that state 'I'm busy now, please try
> again later'. As I said earlier, returning those errors are inevitably
> more efficient than dropping.
> Even for NFSv3 over TCP, dropping a single WRITE request will typically
> cause a 60 second flat holdup instead of the more desirable retry +
> exponential backoff.

Understood. My concern is very simple. I don't want to copy the data and
to avoid this I need to have a way to save off the data for later
processing in a transport specific way. All of my data is sitting in
this rdma_context structure. 

The current svcsock approach just does a kmalloc and a memcpy. This is
not a good approach for a 1MB NFS WRITE. 

An approach that allows a transport to give a "data cookie" to the
deferral mechanism for later recovery would allow all the complexity to
be centralized, but still allow the transport to keep the data around in
it's own way.

> 
> Trond
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
