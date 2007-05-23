From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 16:01:22 -0400
Message-ID: <1179950482.6707.51.camel@heimdal.trondhjem.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<20070523162908.GP14076@sgi.com>
	<EXNANE01KMnap2SAWQ800000a62@exnane01.hq.netapp.com>
	<1179945437.6707.36.camel@heimdal.trondhjem.org>
	<EXNANE01FRaqbC8wSA100000a63@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Greg Banks <gnb@sgi.com>, Neil Brown <neilb@suse.de>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqx1d-0005yI-9J
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 13:01:37 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Hjz4LapCHdPhLUkUasKE3m/XeNcSQb+E=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hqx1f-0007E3-H9
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 13:01:40 -0700
In-Reply-To: <EXNANE01FRaqbC8wSA100000a63@exnane01.hq.netapp.com>
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

On Wed, 2007-05-23 at 14:59 -0400, Talpey, Thomas wrote:
> Personally, I'm not completely sure I see the problem here. If an RDMA
> adapter is going out to lunch and hanging what should be a very fast
> operation (the RDMA Read data pull), then that's an adapter problem
> which we should address in the adapter layer, or via some sort of interface
> hardening between it and RPC. Trying to push the issue back down the RPC
> pipe to the sending peer seems to me a very unworkable solution.

AFAIK, the most common reason for wanting to defer a request is if the
server needs to make an upcall in order to talk to mountd, or to resolve
an NFSv4 name using idmapd. I don't think you really want to treat
hardware failures by deferring requests...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
