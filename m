From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 08:36:55 -0500
Message-ID: <1102599415.24133.34.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
	 <41B74551.5040908@sun.com>  <20041209113107.GE15055@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Waychison <Michael.Waychison@sun.com>, Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcOTq-0005vg-Qk
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:37:14 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcOTq-0004nA-13
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:37:14 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041209113107.GE15055@suse.de>
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

to den 09.12.2004 Klokka 12:31 (+0100) skreiv Olaf Kirch:

> Shouldn't we allow NFS mounts to use non-privileged ports? Many
> environments don't really care about the "security" provided by privileged
> ports, but would be more than happy if they can run with a few hundred
> NFS mounts

Most AUTH_SYS based models still require it, however I agree that use of
strong security makes the privileged port totally redundant.

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
