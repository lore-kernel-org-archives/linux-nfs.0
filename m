From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Wed, 08 Sep 2004 14:24:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094667846.9493.50.camel@lade.trondhjem.org>
References: <OFECAABC86.319E8CA4-ON88256F09.005FC378-88256F09.00606C10@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFECAABC86.319E8CA4-ON88256F09.005FC378-88256F09.00606C10@us.ibm.com>
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

P=E5 on , 08/09/2004 klokka 13:33, skreiv Marc Eshel:
>=20
>=20
> Hi,
> My server sends the async GRANT_MSG RPC to the client for a blocked lock
> but the client either ignoring it or not receiving it. The client wait fo=
r
> 30 seconds and than tries to get the locks again. Can someone explain wha=
t
> might cause this problem ?
> Thanks, Marc.

Yes, but not without knowing which client you are using. ;-)

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
