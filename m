From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 16:46:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094676419.8363.42.camel@lade.trondhjem.org>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
	 <1094662327.9493.42.camel@lade.trondhjem.org> <413F5127.5030008@bluewin.ch>
	 <1094673208.8363.21.camel@lade.trondhjem.org> <413F668D.4060601@bluewin.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C59Lb-0007XF-EV
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 13:47:19 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C59LZ-00006k-H1
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 13:47:19 -0700
To: Bernd Nies <bnies@bluewin.ch>
In-Reply-To: <413F668D.4060601@bluewin.ch>
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

P=E5 on , 08/09/2004 klokka 16:07, skreiv Bernd Nies:

> Are you sure it reads the same directory twice? A ls -lR shouldn't do=20

Yes. Check the tcpdumps.

> this and I ran it only once per traffic capture. Between the UDP and
NFS=20
> traffics I unmounted the directory. The share contains directories which=20
> contents are sometimes similar.

Huh? Of course the client may end up reading in the directory multiple
times.

Unless you have allocated a large buffer for it, readdir() will end up
calling multiple times down into the kernel, so the read of an entire
directory is NOT going to be atomic.
If the mtime on the directory has changed in the meantime, the cached
version may be flushed out, and the directory read in again. If the
server has screwed up the cookies, then that will confuse the client.

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
