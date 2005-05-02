From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: The missing link -
Date: Mon, 02 May 2005 08:50:01 -0400
Message-ID: <1115038201.10853.1.camel@lade.trondhjem.org>
References: <4275DB78.8090603@catapult.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSaNd-0004y2-Vd
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 05:50:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DSaNR-0005pN-D1
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 05:50:33 -0700
To: David Cureton <david.cureton@catapult.com>
In-Reply-To: <4275DB78.8090603@catapult.com>
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

m=C3=A5 den 02.05.2005 Klokka 17:49 (+1000) skreiv David Cureton:

> However on occasion we have noticed that the /server/Staff link just
> disappears for some SuSE9.2 clients and the user no longer has access to
> there home directory. All other clients still have the link available
> and they are fine.

What kind of filesystem are you exporting?

When this behaviour happens, what does the client report when you do an
'ls -l' on /server/Staff?

Cheers,
  Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
