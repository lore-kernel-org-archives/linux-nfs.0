From: Bernd Nies <bnies@bluewin.ch>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 23:51:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413F7EF6.9050005@bluewin.ch>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>	 <1094662327.9493.42.camel@lade.trondhjem.org> <413F5127.5030008@bluewin.ch>	 <1094673208.8363.21.camel@lade.trondhjem.org> <413F668D.4060601@bluewin.ch> <1094676419.8363.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5AMO-0004Ie-EM
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 14:52:12 -0700
Received: from mail6.bluewin.ch ([195.186.4.229])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5AMM-0000Sm-Dz
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 14:52:11 -0700
Received: from bluewin.ch (62.203.51.60) by mail6.bluewin.ch (Bluewin AG 7.0.030.2)
        id 412F8F4C0018752E for nfs@lists.sourceforge.net; Wed, 8 Sep 2004 21:51:57 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <1094676419.8363.42.camel@lade.trondhjem.org>
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


> Unless you have allocated a large buffer for it, readdir() will end up
> calling multiple times down into the kernel, so the read of an entire
> directory is NOT going to be atomic.
> If the mtime on the directory has changed in the meantime, the cached
> version may be flushed out, and the directory read in again. If the
> server has screwed up the cookies, then that will confuse the client.

OK, right. I tracked down one incident captured here:

http://www.nies.ch/download/apple-nfs-loop-1dir.dump.gz

A READDIRPLUS reports a directory entry "." with cookie 276 (Frame 157) 
and the next READDIRPLUS reports a file "package-use.html" with same 
cookie 276 (Frame 161). This is WRONG by the server, right?

But why is it working then without problems on a Solaris NFS client?

Well, seems that I have to call Apple support and listen to one hour 
iTunes again ...

Thanks a lot.

Regards,
Bernd


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
