From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client hangs...
Date: Mon, 13 Dec 2004 20:52:58 -0500
Message-ID: <1102989178.10838.37.camel@lade.trondhjem.org>
References: <20041214014146.61955.qmail@web81501.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce1sC-0005KI-2u
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:53:08 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ce1sB-0003gI-8W
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:53:08 -0800
To: Ryan Mak <ryanmak@ameritech.net>
In-Reply-To: <20041214014146.61955.qmail@web81501.mail.yahoo.com>
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

m=E5 den 13.12.2004 Klokka 17:41 (-0800) skreiv Ryan Mak:
> thanx for your help.
> what exactly should i look for since the RPC debug is
> logging tons of data?

The first thing to do is to look for "RPC: %4d received reply" and try
to match the pid to the request pid. Also look for timeouts.

> what are the other possible debug settings besides '3'
> ??

See the RPCDBG_* values in include/linux/sunrpc/debug.h: they define the
bitmask of "dprintk()"s that can be turned on.

Cheers,
  Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
