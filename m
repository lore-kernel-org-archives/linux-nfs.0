From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 11:20:10 -0500
Message-ID: <1102609210.10668.22.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
	 <41B74551.5040908@sun.com> <20041209113107.GE15055@suse.de>
	 <1102599415.24133.34.camel@lade.trondhjem.org>
	 <20041209134441.GB11998@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Waychison <Michael.Waychison@sun.com>, Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcRHc-0002ip-AL
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 08:36:48 -0800
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcRHa-0005pE-97
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 08:36:47 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041209134441.GB11998@suse.de>
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

to den 09.12.2004 Klokka 14:44 (+0100) skreiv Olaf Kirch:

> The Linux auth_sys works fine with unprivileged ports if you allow it to;
> so why shouldn't we make that configurable on the client too? It'd sure
> help some  installations who for some reason or other habe an excessive
> number of exported file systems (see .sig below :).

_Another_ mount option? Urgh... 8-)

Seriously: if you have 8000 NFS mount points, you do not want 8000
different superblocks, 8000 different RPC client structs, and 8000
different sockets.
Apart from being a ridiculous waste of resources, that does little to
pop the contention bubble. It just ends up pushing it down to the
(shared) device layer.

So while I am open to the idea of making use of unprivileged ports, I do
not accept it as a substitute for socket sharing.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
