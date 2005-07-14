From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 15:52:40 -0400
Message-ID: <1121370760.8049.197.camel@lade.trondhjem.org>
References: <20050714125536.788.qmail@web51609.mail.yahoo.com>
	 <1121347282.8202.49.camel@lade.trondhjem.org>
	 <1121368645.10126.193.camel@seki.nac.uci.edu>
	 <1121369838.8049.185.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt9lS-0007wu-E6
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:52:58 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt9lR-00023Y-61
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:52:58 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1121369838.8049.185.camel@lade.trondhjem.org>
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

to den 14.07.2005 Klokka 15:37 (-0400) skreiv Trond Myklebust:
> to den 14.07.2005 Klokka 12:17 (-0700) skreiv Dan Stromberg: 
> > > An NFSv4 client has no use for statd. The NFSv4 protocol has its own
> > > methods for tracking client and server reboots.
> > 
> > lockd too, I hope?
> 
> Yes. Lockd is gone too.
> 
> The only daemons you need to run on a client in order to get NFSv4
> working are
> 
>   - idmapd (for translating names/groups <-> uid/gid)
>   - rpc.gssd (only if you are using RPCSEC_GSS)

Oops. I forgot... You need to run the portmapper on the client too. The
reason is that the v4 delegation code needs to set up a server for the
callback channel, and the sunrpc code is still under the illusion that
we want it to register every server with portmap.

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
