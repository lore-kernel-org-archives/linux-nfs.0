From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 10:30:35 -0500
Message-ID: <1108913435.27120.40.camel@lade.trondhjem.org>
References: <20050220111312.GA3974@s>
	 <1108908221.27120.26.camel@lade.trondhjem.org>  <20050220141037.GA7686@s>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ttx0eaY547NRvZSSmlFE"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2t2q-0004ot-Ty
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 07:30:52 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2t2p-0001q1-5w
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 07:30:52 -0800
To: Haakon Riiser <haakon.riiser@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20050220141037.GA7686@s>
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


--=-ttx0eaY547NRvZSSmlFE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

su den 20.02.2005 Klokka 15:10 (+0100) skreiv Haakon Riiser:
> > rpc.statd needs some ports for communication with the portmapper
> > and the lockd manager on the loopback net, and this is probably
> > what you are seeing. There should be nothing that needs to be
> > allowed firewall access, though.
> 
> Actually, I wanted to /block/ this port in the firewall, not open
> for external access.  My firewall allows everything by default, and
> has rules to block ports that shouldn't be visible to the world.
> Should I be concerned about this port being unblocked?

The ports for portmapper registration are destroyed after they are used.
The only port that is of worry is the one used for outgoing
communications (controlled by the "-o" option).

.... and of course, that control mechanism appears to be borken...

See if the attached patch doesn't fix things so that your 3rd rpc.statd
port stays on the port specified by "-o"...

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-ttx0eaY547NRvZSSmlFE
Content-Disposition: inline; filename=nfs-utils-1.0.7-fix_outgoing_port.dif
Content-Type: text/plain; name=nfs-utils-1.0.7-fix_outgoing_port.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

 Ehem...
  1) sin.sin_port is supposed to be in network order.
  2) bindresvport() is used to automatically choose the port for you.
     if you want to set the port yourself, use bind()
---
 rmtcall.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

Index: nfs-utils/utils/statd/rmtcall.c
===================================================================
--- nfs-utils.orig/utils/statd/rmtcall.c
+++ nfs-utils/utils/statd/rmtcall.c
@@ -65,7 +65,7 @@ statd_get_socket(int port)
 
 	memset(&sin, 0, sizeof(sin));
 	sin.sin_family = AF_INET;
-	sin.sin_port = port;
+	sin.sin_addr.s_addr = INADDR_ANY;
 	/*
 	 * If a local hostname is given (-n option to statd), bind to the address
 	 * specified. This is required to support clients that ignore the mon_name in
@@ -76,7 +76,15 @@ statd_get_socket(int port)
 		if (hp)
 			sin.sin_addr = *(struct in_addr *) hp->h_addr;
 	}
-	if (bindresvport(sockfd, &sin) < 0) {
+	if (port != 0) {
+		sin.sin_port = htons(port);
+		if (bind(sockfd, &sin, sizeof(sin)) < 0) {
+			note(N_CRIT, "failed to bind to outgoing port, %d\n"
+					"falling back to randomly chosen port\n", port);
+			port = 0;
+		}
+	}
+	if (port == 0 && bindresvport(sockfd, &sin) < 0) {
 		dprintf(N_WARNING,
 			"process_hosts: can't bind to reserved port\n");
 	}

--=-ttx0eaY547NRvZSSmlFE--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
