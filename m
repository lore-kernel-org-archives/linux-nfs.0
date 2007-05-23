From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 14:19:17 -0400
Message-ID: <EXNANE01KMnap2SAWQ800000a62@exnane01.hq.netapp.com>
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
Cc: Neil Brown <neilb@suse.de>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqvQl-00048B-Cb
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:19:27 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqvQn-0003T9-7T
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:19:30 -0700
In-Reply-To: <20070523162908.GP14076@sgi.com>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<20070523162908.GP14076@sgi.com>
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

At 12:29 PM 5/23/2007, Greg Banks wrote:
>So we could translate nfserr_dropit -> nfserr_jukebox ?
>I notice that nfs4_new_open() does that.

If WRITEs start returning nfserr_jukebox because there happens to
be a large-ish number of them in progress at the server, then that
server's throughput is going to be in a world of hurt. Clients will be
forced to back off in herds, and herds don't back off well.

I feel strongly that we need a good, workable defer mechanism
that actually defers. Yes, it's maybe hard. But it's important!

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
