From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 16:33:57 -0500
Message-ID: <1102628037.10668.86.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
	 <41B74551.5040908@sun.com>  <20041209113107.GE15055@suse.de>
	 <1102620880.3784.3.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, Mike Waychison <Michael.Waychison@sun.com>,  Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcVvQ-0000iM-Kc
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:34:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcVvP-0006xh-Ov
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:34:12 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1102620880.3784.3.camel@tesuji.nac.uci.edu>
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

to den 09.12.2004 Klokka 11:34 (-0800) skreiv Dan Stromberg:

> It'd probably be worthwhile to have options to make NFS (and my
> printsystem) generate any port (not just reserved ones), and accept only
> reserved ports - but the default probably should be to accept any port,
> and send only reserved ports - not because reserved ports are effective
> at all, but because it'll avoid never ending questions about why NFS
> isn't working.

Sure. The questions will no longer read "why isn't NFS working". They'll
read "why can any Tom, Dick and Harry suddenly read my private email
directly from the NFS server?". 8-)

The standard AUTH_SYS/AUTH_UNIX authentication scheme only checks the
source IP address, and trusts the client 100% when it comes to supplying
the correct uid/gid/.... (see RFC1831). By placing the additional
requirement that the source must be a privileged port, one is at least
able to prevent ordinary users on an authorized client from being able
to spoof NFS requests.

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
