From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: should NLM locks send notifications after nfsd crash
Date: Thu, 31 Mar 2005 11:19:13 -0500
Message-ID: <1112285953.12388.17.camel@lade.trondhjem.org>
References: <20050331131327.GB1328@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DH2OP-0001PF-1g
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:19:37 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DH2ON-00019E-2D
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:19:36 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050331131327.GB1328@hmsendeavour.rdu.redhat.com>
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

to den 31.03.2005 Klokka 08:13 (-0500) skreiv Neil Horman:
> Hey all-
> 	I can't quite get my head around something.  I've ben asked a question
> regarding the behavior of NLM locks, and I'm not sure of what the right behavior
> is. If there are NFS clients which have issued monitor requests for various NLM
> locks to a server (rpc.statd), and the NFS server (rpc.nfsd) which serves the
> files for which the client is monitoring locks on, is stopped and started (some
> arbitrary time later), should notifications be sent to the monitoring
> clients?  I've been reading the opengourp definition for NLM and NSM, and
> section regarding the entrance of grace periods when the "server crashes" is
> just unclear to me.

Unlike NFSv2/v3, NLM involves the server keeping state in sync with the
client (both client and server have to agree at all times on which locks
are held by the client).
As recovery of state is client-driven, that means that the server is
responsible for notifying the clients upon any event which causes it to
lose track of that state. The clients are then responsible for to trying
to recover the state that they believe to be holding.

So if stopping and starting the server causes it to lose the NLM lock
information that it held, then it must notify the clients of this so
that they can take whatever action may be necessary to recover their
locks.
In order to ensure that this recovery can happen in an orderly fashion,
the server defines a "grace period", during which clients may not
actually set new locks, but they may reclaim locks which they held
before the event. (In order for this to work, the server has to trust
the clients not to lie about which locks they held before the
"reboot"...)

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
