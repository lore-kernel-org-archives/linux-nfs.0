From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs over tcp problem on Redhat 9
Date: Wed, 02 Jun 2004 12:04:51 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086203091.3955.17.camel@lade.trondhjem.org>
References: <2B51611764AC0A4DB3A15200DD51E8E6090783@mail2.chesapeakebay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVb2n-0007u7-QP
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 12:04:57 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BVb2n-00078x-BZ
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 12:04:57 -0700
To: Enils Bashi <EBashi@chesapeakebay.net>
In-Reply-To: <2B51611764AC0A4DB3A15200DD51E8E6090783@mail2.chesapeakebay.net>
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

P=E5 on , 02/06/2004 klokka 11:43, skreiv Enils Bashi:

>     100003    2   udp   2049  nfs
>=20
>     100003    3   udp   2049  nfs

Here's the problem. RedHat unfortunately only recently enabled TCP
support for knfsd. Your kernel appears to be one of the older versions
that only supports UDP.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
