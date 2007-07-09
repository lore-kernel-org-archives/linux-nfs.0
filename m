From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.22 [PATCH 0/3] NLM: fix source address
	in	server	callbacks
Date: Tue, 10 Jul 2007 08:48:13 +1000
Message-ID: <18066.47917.169001.877808@notabene.brown>
References: <20070709201913.GA3970@janus>
	<1184019801.6468.67.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>,
	Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I821p-0000Gx-IJ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:48:26 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I821r-00044V-OS
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:48:29 -0700
In-Reply-To: message from Trond Myklebust on Monday July 9
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

On Monday July 9, trond.myklebust@fys.uio.no wrote:
> On Mon, 2007-07-09 at 22:19 +0200, Frank van Maarseveen wrote:
> > Here's the patchset again but this time for 2.6.22 (verified) and based on
> > the earlier cleanup patch for creating a SUNRPC transport.  The xs_bind
> > (formerly xs_bindresvport) function slightly been recoded to make more
> > clear what it does.
> > 
> > The first patch changes the TCP server socket code to save the socket
> > name right after an accept(). This local address of a connection
> > (destination address of a request) is needed for connecting back when
> > doing the callback later. For UDP the address was already saved for RPC
> > replies because UDP is connectionless. This patch is IPv6 clean.
> > 
> > The second patch changes the NFS client code to be able to bind not only
> > to a privileged port but also to bind to a specific local address. The
> > client code is used by the server for callbacks.
> > 
> > The third patch is the actual NLM fix.
> 
> I've appended them to the NFS_ALL and the git tree. Unless Neil objects,
> I propose that we just shove them in together with the existing NFS
> merge.

No objection from me - I support your proposal!

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
