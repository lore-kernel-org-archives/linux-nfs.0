From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Wed, 08 Sep 2004 16:12:01 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094674321.8363.30.camel@lade.trondhjem.org>
References: <OF6D9F0752.E1DC3AD0-ON88256F09.006C6355-88256F09.006CDBFD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF6D9F0752.E1DC3AD0-ON88256F09.006C6355-88256F09.006CDBFD@us.ibm.com>
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

P=E5 on , 08/09/2004 klokka 15:49, skreiv Marc Eshel:
>=20
>=20
> Sorry, the client is running on RedHat Linux 7.3 with a 2.6.7 kernel.
> Marc,
>=20
> > P=E5 on , 08/09/2004 klokka 13:33, skreiv Marc Eshel:
> > >
> > >
> > > Hi,
> > > My server sends the async GRANT_MSG RPC to the client for a blocked
> lock

So if you are certain that the GRANT_MSG call is being sent by the
server (2.6.x kernels prior to 2.6.9-rc1 have a bug that prevents this),
then my first suspect is the new code in net/sunrpc/svcauth_unix.c,
which assumes that all server traffic needs to be authenticated as if it
were rpc.nfsd traffic.

If so, then a tcpdump should show you that the lockd process on the
client is returning an AUTH_BADCRED reply or something like that. Could
you check please?

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
