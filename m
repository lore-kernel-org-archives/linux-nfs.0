From: Daniel Ellard <ellard@eecs.harvard.edu>
Subject: incredible numbers of fsstats - why?
Date: Fri, 11 Jul 2003 15:48:30 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSF.4.51.0307111532150.74564@bowser.eecs.harvard.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bowser.eecs.harvard.edu
	([140.247.60.24] helo=mail.eecs.harvard.edu ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19b3sj-0004Ji-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 12:48:37 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.eecs.harvard.edu (Postfix) with ESMTP id 32FE654C442
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 15:48:30 -0400 (EDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


On one of the clients on my network, I'm seeing one (or more) fsstat
calls per NFS request.  (I don't mean only that there are
approximately the same number of fsstat calls as other calls -- I mean
that every "normal" call is accompanied by an fsstat call.)

The client in this case is a Mac running OSX.  We have a few other OSX
machines, but that don't seem to have this problem,  at least not
to this degree (although it might just be that they're idle enough
so that it's hard to notice).

Any idea why this would be happening, and/or how to make it stop?

Thanks,
	-Dan



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
