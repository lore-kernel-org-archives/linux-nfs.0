From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: Bug starting 2.6.16 - rpc: bad TCP reclen
Date: Thu, 20 Jul 2006 10:38:16 +0200
Message-ID: <200607201038.16637.bernd-schubert@gmx.de>
References: <44BCC7A1.30104@plutohome.com> <44BE5538.4080508@plutohome.com>
	<17599.1679.768863.576310@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3U0e-0000qm-Js
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 01:35:52 -0700
Received: from mail.gmx.de ([213.165.64.21] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G3U0d-0002CG-C4
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 01:35:53 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <17599.1679.768863.576310@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

> The message means that data on the TCP connection is corrupted.
> With tcp, every RPC message is prefixed by a 4 byte header.
> The msb of this number is set to one to show it is the last of a
> sequence of fragments (we don't support multiple rpc-fragments).  The
> rest of the number is the number of bytes in the RPC message.
> This should be less than about 32000 as we don't support any messages
> bigger than this.  You are seeing number with the msb clear, and
> numbers bigger than 32000.
>
> It is very probably that this is not the first corruption in the TCP
> stream, just the first that is being reported.  I have no idea where
> the corruption could be coming from.
>

Wouldn't tcp errors corrected get corrected by the tcp checksum (retransmit=
)? =

At least thats what my text book is saying.

We are occasionally seeing those messages, too. Don't know how to reproduce =

it, though. =


on our fileserver fileserver: RPC: bad TCP reclen 0x040d0a0d (non-terminal)=
  =

on our compute cluster server: RPC: bad TCP reclen 0x2dacc6c9 (large)

Here its not related to 2.6.16 only. The compute cluster server shows those =

messages - both server and clients are using 2.6.15. Until recently it run =

2.6.11 and we never had those messages that time.
Our main fileserver is running 2.6.13, most clients still 2.6.11 and some =

clients 2.6.16. As far as I remember, those messages began when we updated =

the clients from 2.6.11 to 2.6.16.

Thanks,
	Bernd

-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
