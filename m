From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 5 of 6] lockd: don't try to match callback requests
 against export table
Date: Thu, 16 Sep 2004 19:34:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095377696.10216.41.camel@lade.trondhjem.org>
References: <1095375544.839c1c96.5@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85mV-0004SH-6H
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:35:15 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C85mU-0004sa-NA
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:35:15 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1095375544.839c1c96.5@fieldses.org>
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

P=E5 to , 16/09/2004 klokka 19:16, skreiv J. Bruce Fields:
> +	/* XXX: correct list?  Add field to proc? */
> +	/* XXX: SMPROC_NOTIFY may be a special case. */
> +	/* XXX: double-check: make sure the procedure numbers make sense
> +	 * across all nlm versions.  Check NOTIFY in particular. */
> +	return proc =3D=3D NLMPROC_GRANTED
> +		|| proc =3D=3D NLMPROC_TEST_RES
> +		|| proc =3D=3D NLMPROC_LOCK_RES
> +		|| proc =3D=3D NLMPROC_CANCEL_RES
> +		|| proc =3D=3D NLMPROC_UNLOCK_RES
> +		|| proc =3D=3D NLMPROC_GRANTED_RES;

|| proc =3D=3D NLMPROC_NSM_NOTIFY

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
