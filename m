From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Thu, 09 Sep 2004 13:08:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094699316.19981.79.camel@hole.melbourne.sgi.com>
References: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
	 <1094676655.8363.47.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Marc Eshel <eshel@almaden.ibm.com>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5FCM-0002gB-IR
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 20:02:10 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5FCM-0006E4-0J
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 20:02:10 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094676655.8363.47.camel@lade.trondhjem.org>
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

On Thu, 2004-09-09 at 06:50, Trond Myklebust wrote:
> P=E5 on , 08/09/2004 klokka 16:35, skreiv Marc Eshel:
> > Yes, I see the following messages on the client:
> >=20
> > svc: authenticate (1)
> > svc: authentication failed (1)
>=20

By sheer coincidence, I've had what appears to be the same problem
reported internally in the last couple of days.  I have a network
trace (partially truncated by tcpdump, sigh) which shows a GRANTED
callback from an IRIX server being rejected by a 2.6.5 (SLES9) client
with AUTH_BADCRED.  The same case works fine in 2.4 based kernels.
My suspicions were hovering around the same code as your suspicions ;-)

> OK. Bruce has promised to work on splitting out the "domain" code from
> the svcauth_unix code. Once that is done, we can fix up GRANT_MSG and
> NOTIFY as well as any other routines that do not need to be
> authenticated by rpc.mountd.

Any idea how long is this likely to take?

Greg.
--=20
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
