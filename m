From: Ryan Mak <ryanmak@ameritech.net>
Subject: Re: NFS client hangs...
Date: Mon, 13 Dec 2004 17:41:46 -0800 (PST)
Message-ID: <20041214014146.61955.qmail@web81501.mail.yahoo.com>
References: <1102987908.10838.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce1hJ-0004h5-VK
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:41:53 -0800
Received: from web81501.mail.yahoo.com ([206.190.37.104])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1Ce1hI-0008D9-3S
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:41:52 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1102987908.10838.14.camel@lade.trondhjem.org>
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

thanx for your help.
what exactly should i look for since the RPC debug is
logging tons of data?

what are the other possible debug settings besides '3'
??

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> må den 13.12.2004 Klokka 17:18 (-0800) skreiv Ryan
> Mak:
> > yes, i am absolutely sure that the tcpdump was not
> > taken on the server...it was indeed taken on the
> > client. does anyone know what possible reasons
> that
> > these ACKs are not received by the RPC layer on
> the
> > client side or know of a way that I could debug
> > further? thanx.
> 
> There are several reasons why the RPC layer might
> reject those packets.
> For instance their UDP checksums may fail to verify.
> 
> In addition 2.4.20 is old enough that it may still
> have had timing
> problems in the transport layer.
> 
> I would start by turning on the RPC debugging:
> Try
>     sysctl -w sunrpc.rpc_debug=3
> 
> (or "echo 3 >/proc/sys/sunrpc/rpc_debug" - which
> does the same thing).
> 
> Cheers,
>   Trond
> 
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>
> 
> 
> 
>
-------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT
> Products from real users.
> Discover which products truly live up to the hype.
> Start reading now.
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
