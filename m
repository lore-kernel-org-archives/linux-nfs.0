From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read-error on utmp file
Date: Mon, 06 Sep 2004 13:04:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094490287.8342.69.camel@lade.trondhjem.org>
References: <41383991.1020108@bio.ifi.lmu.de>
	 <1094230320.8196.32.camel@lade.trondhjem.org>
	 <413C0F25.9010206@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4MvQ-0004Cd-Ne
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 10:05:04 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4MvN-0004wO-UL
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 10:05:03 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <413C0F25.9010206@bio.ifi.lmu.de>
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

P=E5 m=E5 , 06/09/2004 klokka 03:17, skreiv Frank Steiner:

> tcpdump -s 9000 -w <file> host curry & while runlevel /boot/utmp; do true=
; done; killall tcpdump
>=20
> and started the second loop in another window which caused this first loo=
p
> to fail and stop the tcpdump...

Ah, right... Sorry, my head hasn't been screwed on correctly...

Although we wait on writes, we don't bother to wait on all *reads* to
complete when closing the file. This means that readahead (which can
schedule extra pageins asynchronously) may end up causing the file to be
kept open for longer.

That is why you are seeing sillyrenames here...

Now what I still don't understand is why they are being left behind, and
not cleaned up. That should normally only occur under the situations I
described earlier.

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
