From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Wed, 15 Sep 2004 23:11:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095304285.8598.51.camel@lade.trondhjem.org>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Andrew Schretter <schrett@math.duke.edu>
In-Reply-To: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
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

P=E5 on , 15/09/2004 klokka 16:54, skreiv Andrew Schretter:
> The attached code is a blatant rip from the latest connectathon code that
> was stripped down to show exactly where it fails on my 2.6.8.1 NFS client=
.
> Note that this code works on the local disk and on a 2.4.22 client (both =
to
> a 2.6.8.1 server and a 2.4.22 server) but fail from a 2.6.8.1 client to
> both 2.4.22 and 2.6.8.1 servers.
>=20


This question keeps recurring on this list. The answer is the same now
as it was before: Fix the bloody servers!!!!

   subtree_check is INCOMPATIBLE with correct rename behaviour, and it
is simply ridiculous that this is still a default option.

Grrr,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
