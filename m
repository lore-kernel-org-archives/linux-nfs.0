From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Wed, 24 Nov 2004 15:49:27 -0800
Message-ID: <OF162DDA42.A33FBC24-ON88256F56.007F17EA-88256F56.0082DED2@us.ibm.com>
References: <1101313304.11743.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX6xZ-0008Hj-8W
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:54:05 -0800
Received: from e2.ny.us.ibm.com ([32.97.182.142])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CX6xX-0004vP-VQ
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:54:05 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iAONroFt016794
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 18:53:50 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAONroL8247258
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 18:53:50 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAONroCI000902
	for <nfs@lists.sourceforge.net>; Wed, 24 Nov 2004 18:53:50 -0500
In-Reply-To: <1101313304.11743.4.camel@lade.trondhjem.org>
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



Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 11/24/2004 08:21:44
AM:

> ty den 23.11.2004 Klokka 21:35 (-0800) skreiv Marc Eshel:

> > What I am trying to do is deny lock requests from all nodes in an HA
> > environment on nodes that are not part of the failure or takeover until
> > failover is complete and clients of the failed node have had a chance
to
> > reclaim their locks. The rest of the clients are just temporarily
blocked.
> > They will NOT have to reclaim locks and they should not be notified of
a
> > reboot.

> > Can you say more on how NFSv4 state recovery and lockd be used in this
> > situation ?

> You are missing the point. If you want to fail your NFS over from one
> server to another, then *ALL* the state has to be transferred. That
> means NFSv2/v3 locking state AND NFSv4 open owner+locks+delegation+...

In the solution I am considering, there is no transfer of state; the
clients are responsible for recovering lock (and other in case of v4) state
after IP takeover. The patch only allows grace period to be set through an
external proc interface. This enables other machines in the cluster that
must block lock activity until recovery is complete.

Yes, you are right that I did not handle blocking of locks that might come
from NFSv4 clients. I was just extending existing lockd proc interface
(/proc/fs/nfs/nlm_grace_period allows setting grace period) to
enable/disable grace with /proc/fs/nfs/nlm_grace.

Do you think that the existing NLM/lockd interfaces should be used control
NFSv4 grace period or do we need a new interface that will be common for
all NFS versions?

Marc.

> Setting up an interface that allows you to transfer one but not the
> other is just poor design.

> Cheers,
> Trond
>
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
