From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback
	address	binding
Date: Tue, 03 Jul 2007 17:32:15 -0400
Message-ID: <1183498335.6494.58.camel@heimdal.trondhjem.org>
References: <20070702154918.GA543@janus>
	<1183424670.6479.38.camel@heimdal.trondhjem.org>
	<20070703070109.GA8558@janus>
	<1183464206.6494.9.camel@heimdal.trondhjem.org>
	<20070703204711.GC16497@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5pys-00077h-GP
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 14:32:18 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX188nvgu4J1oIih4BvdZ4HMXe1sS1VNEizk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5pyu-0006tI-52
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 14:32:21 -0700
In-Reply-To: <20070703204711.GC16497@janus>
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

On Tue, 2007-07-03 at 22:47 +0200, Frank van Maarseveen wrote
> Reading code... hmm, yes. One global 32 bit pid instead of one per server
> would remove that problem. Note that this is still a very theoretical
> problem because of all the other checks (filehandle check being the most
> important one probably).

Fix the server instead... There is absolutely no reason to be accepting
GRANTED calls from random IP addresses.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
