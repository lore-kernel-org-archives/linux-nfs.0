From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Wed, 08 Sep 2004 16:50:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094676655.8363.47.camel@lade.trondhjem.org>
References: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
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

P=E5 on , 08/09/2004 klokka 16:35, skreiv Marc Eshel:
> Yes, I see the following messages on the client:
>=20
> svc: authenticate (1)
> svc: authentication failed (1)

OK. Bruce has promised to work on splitting out the "domain" code from
the svcauth_unix code. Once that is done, we can fix up GRANT_MSG and
NOTIFY as well as any other routines that do not need to be
authenticated by rpc.mountd.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
