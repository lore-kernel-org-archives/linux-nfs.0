From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Mon, 09 May 2005 06:38:27 -0400
Message-ID: <1115635107.24625.0.camel@lade.trondhjem.org>
References: <20050508113343.GA629@fox>
	 <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox>
	 <1115560765.11308.6.camel@lade.trondhjem.org>  <20050508143754.GA492@fox>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DV5ey-0006zg-Sp
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 03:38:48 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DV5ew-0005Cq-5w
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 03:38:48 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DV5er-0007DL-2O
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 12:38:41 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050508143754.GA492@fox>
Sender: nfs-admin@lists.sourceforge.net
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

su den 08.05.2005 Klokka 16:37 (+0200) skreiv Haakon Riiser:
> Trond,
> 
> > Anyhow, try turning oplocks off in smb.conf and see if the hangs
> > disappear.
> 
> Still hangs.  I also tried enabling fake oplocks, but that didn't
> make any difference either.  Just so you know:  I made sure to stop
> all Samba processes (service smb stop) so I /know/ that the new
> oplock settings were in effect.

Do you have a tcpdump of the traffic?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
