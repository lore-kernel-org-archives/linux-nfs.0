From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 15:14:45 -0500
Message-ID: <1101154485.11196.64.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
	 <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr>
	 <1101146906.11196.35.camel@lade.trondhjem.org>
	 <41A236A6.4050104@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWKaT-0006o9-LL
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 12:15:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWKaS-0005uC-AE
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 12:15:01 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: <41A236A6.4050104@int-evry.fr>
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

m=E5 den 22.11.2004 Klokka 19:57 (+0100) skreiv jehan.procaccia:
> >
> in my old solaris 7 nfs it was async I suppose ! although we didn't lose=20
> data, maybe we where risking it ... ? anyway now I move from and old=20
> solaris NFS server to a brand new linux one with a SAN (AX100) Storage=20
> Processor in Raid 5 an Fiber Channel attachement, how can I support=20
> performances more than 50 times longer :-( with that config,  user and=20
> manager wil tell me that I  spoild money on that new server !, there=20
> must be a misconfiguration somewhere ?.
>=20

Solaris has no equivalent to the "async" export option. AFAIK that is a
Linux creation.

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
