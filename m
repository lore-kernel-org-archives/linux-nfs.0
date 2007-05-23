From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 11:37:19 -0400
Message-ID: <1179934639.6480.58.camel@heimdal.trondhjem.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<1179933123.9389.157.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>, Greg Banks <gnb@sgi.com>,
	Neil Brown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqsuC-0003Sd-EB
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:37:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19qP9M1d+loxkpfSO2K2OP5WCEy5qYzo1Y=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqsuD-0006rf-TV
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:37:43 -0700
In-Reply-To: <1179933123.9389.157.camel@trinity.ogc.int>
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

On Wed, 2007-05-23 at 10:12 -0500, Tom Tucker wrote:
> Ah, this is a very good point. So then I think we need a transport
> specific deferral mechanism. 

No. I'm not sure that justifies a transport specific mechanism. It
rather calls for a more clever algorithm for deferring. Both NFSv3 and
NFSv4 have generic error messages that state 'I'm busy now, please try
again later'. As I said earlier, returning those errors are inevitably
more efficient than dropping.
Even for NFSv3 over TCP, dropping a single WRITE request will typically
cause a 60 second flat holdup instead of the more desirable retry +
exponential backoff.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
