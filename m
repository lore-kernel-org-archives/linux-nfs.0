From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 14:59:27 -0400
Message-ID: <EXNANE01FRaqbC8wSA100000a63@exnane01.hq.netapp.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Greg Banks <gnb@sgi.com>, Neil Brown <neilb@suse.de>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqw3e-0008K1-Oc
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:59:40 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqw3h-0000LF-Fz
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:59:41 -0700
In-Reply-To: <1179945437.6707.36.camel@heimdal.trondhjem.org>
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

At 02:37 PM 5/23/2007, Trond Myklebust wrote:
>On Wed, 2007-05-23 at 14:19 -0400, Talpey, Thomas wrote:
>> I feel strongly that we need a good, workable defer mechanism
>> that actually defers. Yes, it's maybe hard. But it's important!
>
>Unless you have a way of capping the number of requests that are
>deferred, you can quickly end up turning this into a resource issue.

Agreed, and I will add that it's because of the thread-based nfsd
architecture. The nfsd threads can't afford to wait (though frankly
they do today, in the filesystem vfs calls and also in write gathering).

>On TCP sockets you can probably set a per-socket limit on the number of
>deferrals. As soon as you hit that number, then just stop handling any
>further requests on that particular socket (i.e. leave any further data
>queued in the socket buffer and let the server thread go to work on
>another socket) until a sufficient number of deferrals have been cleared
>out.
>I assume that you could devise a similar scheme with RDMA pretty much by
>substituting the word 'slot' for 'socket' in the previous paragraph,
>right?

Yes, absolutely the simplest aproach is to stop processing of new requests
when the nfsd's back up. The apparent latency will rise, but the clients will
become flow controlled due to the RDMA credits, and this in turn will push
back to their RPC stream.

Personally, I'm not completely sure I see the problem here. If an RDMA
adapter is going out to lunch and hanging what should be a very fast
operation (the RDMA Read data pull), then that's an adapter problem
which we should address in the adapter layer, or via some sort of interface
hardening between it and RPC. Trying to push the issue back down the RPC
pipe to the sending peer seems to me a very unworkable solution.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
