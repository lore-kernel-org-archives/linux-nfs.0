From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Wed, 24 Nov 2004 19:15:22 -0500
Message-ID: <1101341722.11478.13.camel@lade.trondhjem.org>
References: <OF162DDA42.A33FBC24-ON88256F56.007F17EA-88256F56.0082DED2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX7IW-00059V-1r
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 16:15:44 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CX7IU-0000cc-Co
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 16:15:43 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF162DDA42.A33FBC24-ON88256F56.007F17EA-88256F56.0082DED2@us.ibm.com>
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

on den 24.11.2004 Klokka 15:49 (-0800) skreiv Marc Eshel:

> In the solution I am considering, there is no transfer of state; the
> clients are responsible for recovering lock (and other in case of v4) state
> after IP takeover. The patch only allows grace period to be set through an
> external proc interface. This enables other machines in the cluster that
> must block lock activity until recovery is complete.

The same model is valid for NFSv4 clients (unless there exists some
other method for directly transferring state between the servers).

> Do you think that the existing NLM/lockd interfaces should be used control
> NFSv4 grace period or do we need a new interface that will be common for
> all NFS versions?

So I'm an advocate of moving towards a common interface for grace period
management for the reasons I stated in the earlier mails.

Since the NFSv4 state model is by and large a superset of what lockd
has, I'd argue that we should move the lockd grace stuff into the NFSv4
interface rather than the opposite.

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
