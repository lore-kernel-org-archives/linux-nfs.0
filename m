From: <trond.myklebust@fys.uio.no>
Subject: Re: NFSv4 daemons...
Date: Fri, 9 Jan 2004 21:45:25 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32906.141.211.133.197.1073681125.squirrel@webmail.uio.no>
References: <1073621173.1398.55.camel@nidelv.trondhjem.org>
        <Pine.LNX.4.44.0401091803430.30771-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <trond.myklebust@fys.uio.no>, <hjl@users.sourceforge.net>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Af3Vi-0005qq-Pe
	for nfs@lists.sourceforge.net; Fri, 09 Jan 2004 12:45:38 -0800
To: <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0401091803430.30771-100000@kenzo.iwr.uni-heidelberg.de>
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

> On Thu, 8 Jan 2004, Trond Myklebust wrote:
>
>> The idmapper in particular is essential if you want to use NFSv4.
>
> Is there already a well agreed way and place (init scripts) to
> start/stop   these daemons ?

Chuck Lever has written an init script for the daemons. About the only
thing that might be a subject of debate is the default mountpoint for the
pseudofs that the NFS client uses to communicate with the daemons. The
consensus at CITI is that it should be /var/lib/nfs/rpc_pipefs. I have no
strong feelings if people have alternative preferences, but note that this
is in any case configurable via the configuration files.

Cheers,
  Trond




-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
