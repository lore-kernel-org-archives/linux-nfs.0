From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 17:00:03 -0400
Message-ID: <EXNANE01XvpFVjCRGry00000a64@exnane01.hq.netapp.com>
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
	<1179950482.6707.51.camel@heimdal.trondhjem.org>
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
	id 1Hqxwp-00034D-Kh
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 14:00:44 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqxws-0004q0-Fh
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 14:00:46 -0700
In-Reply-To: <1179950482.6707.51.camel@heimdal.trondhjem.org>
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
	<1179950482.6707.51.camel@heimdal.trondhjem.org>
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

At 04:01 PM 5/23/2007, Trond Myklebust wrote:
>On Wed, 2007-05-23 at 14:59 -0400, Talpey, Thomas wrote:
>> Personally, I'm not completely sure I see the problem here. If an RDMA
>> adapter is going out to lunch and hanging what should be a very fast
>> operation (the RDMA Read data pull), then that's an adapter problem
>> which we should address in the adapter layer, or via some sort of interface
>> hardening between it and RPC. Trying to push the issue back down the RPC
>> pipe to the sending peer seems to me a very unworkable solution.
>
>AFAIK, the most common reason for wanting to defer a request is if the
>server needs to make an upcall in order to talk to mountd, or to resolve
>an NFSv4 name using idmapd. I don't think you really want to treat
>hardware failures by deferring requests...

Well, the most common occurrence would be a lost conenction, this
would prevent sending even nfserr_jukebox. I'm suggesting that if
we're concerned about using nfsd thread context to pull data, then
we should also be concerned about calling into filesystems, which might
hang on their storage adapters, or whatever just as easily.

Basically, I'm saying there shouldn't be any special handling for the
RDMA Reads used to pull write data. In the success case, they happen
quite rapidly (at wire speed), and in the failure case, there isn't any
peer to talk to anyway. So what are we protecting?

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
