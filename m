From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client hangs...
Date: Mon, 13 Dec 2004 20:31:48 -0500
Message-ID: <1102987908.10838.14.camel@lade.trondhjem.org>
References: <20041214011846.11258.qmail@web81507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce1Xi-000445-KT
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:31:58 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ce1Xh-0001IR-Tb
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:31:58 -0800
To: Ryan Mak <ryanmak@ameritech.net>
In-Reply-To: <20041214011846.11258.qmail@web81507.mail.yahoo.com>
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

m=E5 den 13.12.2004 Klokka 17:18 (-0800) skreiv Ryan Mak:
> yes, i am absolutely sure that the tcpdump was not
> taken on the server...it was indeed taken on the
> client. does anyone know what possible reasons that
> these ACKs are not received by the RPC layer on the
> client side or know of a way that I could debug
> further? thanx.

There are several reasons why the RPC layer might reject those packets.
For instance their UDP checksums may fail to verify.

In addition 2.4.20 is old enough that it may still have had timing
problems in the transport layer.

I would start by turning on the RPC debugging:
Try
    sysctl -w sunrpc.rpc_debug=3D3

(or "echo 3 >/proc/sys/sunrpc/rpc_debug" - which does the same thing).

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
