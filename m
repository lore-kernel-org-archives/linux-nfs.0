From: Edward Roper <eroper@wanfear.com>
Subject: Re: close() / nfs commit performance
Date: 01 Jul 2003 12:40:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057088426.26307.0.camel@themachine.sanera.net>
References: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>
	 <1057015133.21354.44.camel@themachine.sanera.net>
	 <shshe67xeyd.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, neilb@cse.unsw.edu.au,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.sanera.net ([208.253.254.10] helo=sentinel)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19XQzk-0005bg-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Jul 2003 12:40:52 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shshe67xeyd.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

So in theory running nfs async is no more dangerous than using a local
app that calls close() without fsync()?

On Mon, 2003-06-30 at 17:34, Trond Myklebust wrote:
> >>>>> " " == Edward Roper <eroper@wanfear.com> writes:
> 
>      > Perhaps local close() calls don't actually commit to disk?
> 
> man 2 close
>    (and read the NOTES)
> 
> and then
> 
> man 2 fsync
> 
> Cheers,
>   Trond




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
