From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Wed, 24 Nov 2004 11:21:44 -0500
Message-ID: <1101313304.11743.4.camel@lade.trondhjem.org>
References: <OF52F55A44.344CB7E1-ON88256F56.001C6CDC-88256F56.001EB19E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWzu5-0001wj-Hz
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 08:22:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWzu4-00027J-NT
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 08:22:01 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF52F55A44.344CB7E1-ON88256F56.001C6CDC-88256F56.001EB19E@us.ibm.com>
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

ty den 23.11.2004 Klokka 21:35 (-0800) skreiv Marc Eshel:

> What I am trying to do is deny lock requests from all nodes in an HA
> environment on nodes that are not part of the failure or takeover until
> failover is complete and clients of the failed node have had a chance to
> reclaim their locks. The rest of the clients are just temporarily blocked.
> They will NOT have to reclaim locks and they should not be notified of a
> reboot.

> Can you say more on how NFSv4 state recovery and lockd be used in this
> situation ?

You are missing the point. If you want to fail your NFS over from one
server to another, then *ALL* the state has to be transferred. That
means NFSv2/v3 locking state AND NFSv4 open owner+locks+delegation+...

Setting up an interface that allows you to transfer one but not the
other is just poor design.

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
