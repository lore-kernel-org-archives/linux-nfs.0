From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: I have two Linux ( 2.6.8 ?)   NFS client/server problems
Date: Tue, 12 Oct 2004 02:42:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097541757.5432.73.camel@lade.trondhjem.org>
References: <20041011.170517.25418.13065@webmail12.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHIHI-0002l8-KU
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 01:45:04 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CHIGn-00029t-Ob
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 01:45:04 -0700
To: Alexander Povolotsky <pevnev@juno.com>
In-Reply-To: <20041011.170517.25418.13065@webmail12.lax.untd.com>
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

P=E5 ty , 12/10/2004 klokka 02:05, skreiv Alexander Povolotsky:
> Trond Myklebust wrote:
>=20
> > Have you tried the form recommended by the manpage?
>=20
> >  pivot_root . /tmp
>=20
> yes - same failure=20

Sorry. Actually that should be

pivot_root . tmp

'cos neither of the 2 directories may lie on the old root (and you have
to make sure that /fadsroot/tmp does indeed exist).

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
