From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: read-error on utmp file
Date: Mon, 06 Sep 2004 09:17:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413C0F25.9010206@bio.ifi.lmu.de>
References: <41383991.1020108@bio.ifi.lmu.de> <1094230320.8196.32.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4DlK-0005Uu-QE
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 00:18:02 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4DlI-0007v8-KJ
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 00:18:02 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094230320.8196.32.camel@lade.trondhjem.org>
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

> Binary "tcpdump -s 9000" please?

I did a "tcpdump -s 9000 -w <file> host <server>" on the client and accordingly on
the server. Hope this was ok. The client log should stop right after
the error, because I executed this on the client:

tcpdump -s 9000 -w <file> host curry & while runlevel /boot/utmp; do true; done; killall tcpdump

and started the second loop in another window which caused this first loop
to fail and stop the tcpdump...

The logs are here (1.5 and 3 MB, so I didn't want to mail them):
http://www.bio.ifi.lmu.de/~steiner/tcpdump.utmp.read.error.client
http://www.bio.ifi.lmu.de/~steiner/tcpdump.utmp.read.error.server

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
