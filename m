From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Debian Bug#203077: Locks not released on NFS client
	reboot
Date: Fri, 14 Jan 2005 14:43:37 -0500
Message-ID: <1105731817.9604.11.camel@lade.trondhjem.org>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	 <20030727163124.GC19877@perlsupport.com>
	 <16164.29864.268358.781865@gargle.gargle.HOWL>
	 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
	 <16871.11926.507904.373575@cse.unsw.edu.au>
	 <Pine.LNX.4.60.0501140852070.11608@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpXMV-00070A-JK
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:43:59 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CpXMV-0000zb-22
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:43:59 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0501140852070.11608@harp.ngdc.noaa.gov>
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

fr den 14.01.2005 Klokka 09:05 (-0700) skreiv Ara.T.Howard:
> On Fri, 14 Jan 2005, Neil Brown wrote:
> 
> > So bligh, the client, is running statd (the "status" service), but mussel
> > can not talk to it.  This is a problem.
> 
> are you saying inbound rpc traffic flowing from server -> client MUST not be
> blocked by the firewall and that it is NOT sufficient to allow ONLY inbound
> rpc traffic client -> server?  sorry if this does not make sense - i'm a bit
> out of my domain here...

Bi-directional RPC traffic must be allowed if you plan on using NLM
locking, since it is callback based. A couple of issues that immediately
spring to mind in the case where the server cannot call the client are:

        - Blocking locks (F_SETLKW) will be hampered since the client
        expects the server's lockd daemon to call it back as soon as any
        conflicting locks have been released and the lock granted...

        - Server reboot recovery will be broken, since the server's
        rpc.statd daemon will be incapable of notifying the clients that
        their locks have been lost and need to be recovered.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
