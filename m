From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 15:37:18 -0400
Message-ID: <1121369838.8049.185.camel@lade.trondhjem.org>
References: <20050714125536.788.qmail@web51609.mail.yahoo.com>
	 <1121347282.8202.49.camel@lade.trondhjem.org>
	 <1121368645.10126.193.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt9Wa-0007QA-2A
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:37:36 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt9WY-0003sY-Mw
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:37:36 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1121368645.10126.193.camel@seki.nac.uci.edu>
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

to den 14.07.2005 Klokka 12:17 (-0700) skreiv Dan Stromberg: 
> > An NFSv4 client has no use for statd. The NFSv4 protocol has its own
> > methods for tracking client and server reboots.
> 
> lockd too, I hope?

Yes. Lockd is gone too.

The only daemons you need to run on a client in order to get NFSv4
working are

  - idmapd (for translating names/groups <-> uid/gid)
  - rpc.gssd (only if you are using RPCSEC_GSS)

On the server you have to be running

  - idmapd (for translating names/groups <-> uid/gid)
  - portmap (this requirement will hopefully go away soon)
  - rpc.svcgssd (only if you are exporting RPCSEC_GSS)
  - rpc.mountd (not used by clients, only by nfsd itself - feel free to
		firewall away the ports it sets up)

....  and the nfsd processes.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
