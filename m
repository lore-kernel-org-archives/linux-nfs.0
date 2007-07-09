From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.22 [PATCH 0/3] NLM: fix source address in
	server	callbacks
Date: Mon, 09 Jul 2007 18:23:21 -0400
Message-ID: <1184019801.6468.67.camel@heimdal.trondhjem.org>
References: <20070709201913.GA3970@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>,
	Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I81di-0006JJ-9c
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:23:31 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18fzfWfqxr4KeKmTdqAOzrBmU6/bF5HB9s=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I81dl-0004Mg-Fz
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:23:33 -0700
In-Reply-To: <20070709201913.GA3970@janus>
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

On Mon, 2007-07-09 at 22:19 +0200, Frank van Maarseveen wrote:
> Here's the patchset again but this time for 2.6.22 (verified) and based on
> the earlier cleanup patch for creating a SUNRPC transport.  The xs_bind
> (formerly xs_bindresvport) function slightly been recoded to make more
> clear what it does.
> 
> The first patch changes the TCP server socket code to save the socket
> name right after an accept(). This local address of a connection
> (destination address of a request) is needed for connecting back when
> doing the callback later. For UDP the address was already saved for RPC
> replies because UDP is connectionless. This patch is IPv6 clean.
> 
> The second patch changes the NFS client code to be able to bind not only
> to a privileged port but also to bind to a specific local address. The
> client code is used by the server for callbacks.
> 
> The third patch is the actual NLM fix.

I've appended them to the NFS_ALL and the git tree. Unless Neil objects,
I propose that we just shove them in together with the existing NFS
merge.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
