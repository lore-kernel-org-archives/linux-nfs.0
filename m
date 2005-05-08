From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Sun, 08 May 2005 09:59:25 -0400
Message-ID: <1115560765.11308.6.camel@lade.trondhjem.org>
References: <20050508113343.GA629@fox>
	 <1115556864.11308.1.camel@lade.trondhjem.org>  <20050508132127.GA1744@fox>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DUmJq-0006vI-EY
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 06:59:42 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DUmJo-0000Ir-TU
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 06:59:42 -0700
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DUmJj-0002Gp-9Q
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 15:59:35 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050508132127.GA1744@fox>
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

su den 08.05.2005 Klokka 15:21 (+0200) skreiv Haakon Riiser:

> > Are oplocks enabled on the Samba server?
> 
> Probably.  I haven't touched the oplock setting, but according
> to smb.conf(5), kernel oplocks are enabled by default, and they
> translate to no-ops when the kernel doesn't support them.  How do
> I determine if I have kernel support?

Kernel support for oplocks has been in Linux since version 2.4 - see the
"lease" locks on the fcntl manpage. They haven't been maintained for
quite some while, though until Andy started working on the NFSv4 server
delegation code (in 2.6.11 or so).

Anyhow, try turning oplocks off in smb.conf and see if the hangs
disappear.

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
