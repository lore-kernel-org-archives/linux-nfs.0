From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Wed, 8 Sep 2004 12:49:02 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF6D9F0752.E1DC3AD0-ON88256F09.006C6355-88256F09.006CDBFD@us.ibm.com>
References: <1094667846.9493.50.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1094667846.9493.50.camel@lade.trondhjem.org>
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





Sorry, the client is running on RedHat Linux 7.3 with a 2.6.7 kernel.
Marc,

> P=E5 on , 08/09/2004 klokka 13:33, skreiv Marc Eshel:
> >
> >
> > Hi,
> > My server sends the async GRANT_MSG RPC to the client for a blocked=

lock
> > but the client either ignoring it or not receiving it. The client w=
ait
for
> > 30 seconds and than tries to get the locks again. Can someone expla=
in
what
> > might cause this problem ?
> > Thanks, Marc.

> Yes, but not without knowing which client you are using. ;-)

> Cheers,
> Trond
>
> -------------------------------------------------------
> This SF.Net email is sponsored by BEA Weblogic Workshop
> FREE Java Enterprise J2EE developer tools!
> Get your free copy of BEA WebLogic Workshop 8.1 today.
> http://ads.osdn.com/?ad_idP47&alloc_id=10808&oplick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs=




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
