From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 15:53:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094673208.8363.21.camel@lade.trondhjem.org>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
	 <1094662327.9493.42.camel@lade.trondhjem.org> <413F5127.5030008@bluewin.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C58Vi-0003wq-CU
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 12:53:42 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C58Vg-0000ny-Vu
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 12:53:41 -0700
To: Bernd Nies <bnies@bluewin.ch>
In-Reply-To: <413F5127.5030008@bluewin.ch>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

As far as I can see from your traces, 2 consecutive READDIRs on the same
directory is giving totally different results...

In your TCP file, the first time the Linux client reads through the
directory which begins with "Autorun.inf", the entry "install.sh" (for
instance) has cookie 292. The second time round, it has cookie 252.

Our client will not work with such a server.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
