From: Bernd Nies <bnies@bluewin.ch>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 22:07:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413F668D.4060601@bluewin.ch>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>	 <1094662327.9493.42.camel@lade.trondhjem.org> <413F5127.5030008@bluewin.ch> <1094673208.8363.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C58jZ-0007CD-Pk
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 13:08:01 -0700
Received: from mail5.bluewin.ch ([195.186.1.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C58jY-0003tB-82
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 13:08:01 -0700
Received: from bluewin.ch (62.203.51.60) by mail5.bluewin.ch (Bluewin AG 7.0.030.2)
        id 412F8F2D0017FC4D for nfs@lists.sourceforge.net; Wed, 8 Sep 2004 20:07:42 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <1094673208.8363.21.camel@lade.trondhjem.org>
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



Trond Myklebust wrote:

> As far as I can see from your traces, 2 consecutive READDIRs on the same
> directory is giving totally different results...
> 
> In your TCP file, the first time the Linux client reads through the
> directory which begins with "Autorun.inf", the entry "install.sh" (for
> instance) has cookie 292. The second time round, it has cookie 252.
> 
> Our client will not work with such a server.

Are you sure it reads the same directory twice? A ls -lR shouldn't do 
this and I ran it only once per traffic capture. Between the UDP and NFS 
traffics I unmounted the directory. The share contains directories which 
contents are sometimes similar.

The server is working fine. Only on about one of thousand directories 
the client loops and if Client A loops over one directory, client B does 
not.

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
