From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Wed, 8 Sep 2004 13:35:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
References: <1094674321.8363.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1094674321.8363.30.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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







Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 09/08/2004 01:12:=
01
PM:

> P=E5 on , 08/09/2004 klokka 15:49, skreiv Marc Eshel:
> >
> >
> > Sorry, the client is running on RedHat Linux 7.3 with a 2.6.7 kerne=
l.
> > Marc,
> >
> > > P=E5 on , 08/09/2004 klokka 13:33, skreiv Marc Eshel:
> > > >
> > > >
> > > > Hi,
> > > > My server sends the async GRANT_MSG RPC to the client for a blo=
cked
> > lock

> So if you are certain that the GRANT_MSG call is being sent by the
> server (2.6.x kernels prior to 2.6.9-rc1 have a bug that prevents thi=
s),
> then my first suspect is the new code in net/sunrpc/svcauth_unix.c,
> which assumes that all server traffic needs to be authenticated as if=
 it
> were rpc.nfsd traffic.

> If so, then a tcpdump should show you that the lockd process on the
> client is returning an AUTH_BADCRED reply or something like that. Cou=
ld
> you check please?

Yes, I see the following messages on the client:

svc: authenticate (1)
svc: authentication failed (1)

Marc.

=




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
