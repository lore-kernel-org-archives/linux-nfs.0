From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 13:08:26 -0500
Message-ID: <1101146906.11196.35.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
	 <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWIcz-0006Q2-TW
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:09:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWIcy-0000Oq-F6
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:09:29 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: <41A2280B.1010005@int-evry.fr>
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

m=E5 den 22.11.2004 Klokka 18:55 (+0100) skreiv jehan.procaccia:

> My users won't accept the sync performances !

Will they accept data loss in case of a server crash? If they don't
care, then hey - you're safe...

BTW: I've never seen a slowdown as bad as that. Just out of curiosity,
what happens if you turn off ACL support and/or use a client from
ftp.kernel.org, with no ACL support.

(NOTE: the reason I've rejected ACLs so far in the mainline client is
the lack of support for caching in the patches I've seen so far)

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
