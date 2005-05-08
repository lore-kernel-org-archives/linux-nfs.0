From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 8 May 2005 15:21:27 +0200
Message-ID: <20050508132127.GA1744@fox>
References: <20050508113343.GA629@fox> <1115556864.11308.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DUlj5-0000Mu-CP
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 06:21:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DUlj3-0000zS-Q7
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 06:21:43 -0700
Received: from mail-mx1.uio.no ([129.240.10.29])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DUlix-0006bV-Jb
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 15:21:35 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx1.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DUliv-00029Y-CW
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 15:21:33 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1115556864.11308.1.camel@lade.trondhjem.org>
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

> su den 08.05.2005 Klokka 13:33 (+0200) skreiv Haakon Riiser:
> 
> > I have no idea how Samba + eMule's access patterns look like,
> > but I know with 100 % certainty that it is the cause.  If I move
> > the file in question out of eMule's shared directory, I can never
> > hang the NFS client no matter how long I run the above program.
> > If I move it back in, it hangs almost instantly. :-(
> 
> Are oplocks enabled on the Samba server?

Probably.  I haven't touched the oplock setting, but according
to smb.conf(5), kernel oplocks are enabled by default, and they
translate to no-ops when the kernel doesn't support them.  How do
I determine if I have kernel support?

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
