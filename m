From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Tue, 23 Nov 2004 21:35:15 -0800
Message-ID: <OF52F55A44.344CB7E1-ON88256F56.001C6CDC-88256F56.001EB19E@us.ibm.com>
References: <1101270495.10964.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWpsT-0006l2-DC
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 21:39:41 -0800
Received: from e5.ny.us.ibm.com ([32.97.182.105])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CWpsS-0002Ft-Ag
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 21:39:41 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAO5dXHt735318
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 00:39:33 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAO5dXXb271952
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 00:39:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAO5dWXU003449
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 00:39:33 -0500
In-Reply-To: <1101270495.10964.22.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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



Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 11/23/2004 08:28:15
PM:

> ty den 23.11.2004 Klokka 19:38 (-0800) skreiv Marc Eshel:
> > Can you please consider adding this patch to lockd which is can be very
> > helpful for HA NFS.

> Why are you apparently inventing one system for NFSv2/v3 and a different
> one for NFSv4 here?

> The right way to do this is to have nfsd initiate NFSv4 state recovery,
> and have it call lockd back in order to notify it of the "reboot
> situation".

What I am trying to do is deny lock requests from all nodes in an HA
environment on nodes that are not part of the failure or takeover until
failover is complete and clients of the failed node have had a chance to
reclaim their locks. The rest of the clients are just temporarily blocked.
They will NOT have to reclaim locks and they should not be notified of a
reboot.
Can you say more on how NFSv4 state recovery and lockd be used in this
situation ?

Thanks, Marc.

> Cheers,
> Trond
> --
> Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
