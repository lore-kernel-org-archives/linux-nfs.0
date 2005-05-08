From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 8 May 2005 16:37:54 +0200
Message-ID: <20050508143754.GA492@fox>
References: <20050508113343.GA629@fox> <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox> <1115560765.11308.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DUmuy-0001LD-WA
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 07:38:04 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DUmux-0002zz-Ad
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 07:38:04 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DUmus-0005F8-T6
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 16:37:58 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DUmuq-00067H-SA
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 16:37:56 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1115560765.11308.6.camel@lade.trondhjem.org>
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

Trond,

> Anyhow, try turning oplocks off in smb.conf and see if the hangs
> disappear.

Still hangs.  I also tried enabling fake oplocks, but that didn't
make any difference either.  Just so you know:  I made sure to stop
all Samba processes (service smb stop) so I /know/ that the new
oplock settings were in effect.

-- 
 Haakon


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
