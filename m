From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH 5 of 6] lockd: don't try to match callback requests
 against export table
Date: Fri, 24 Sep 2004 13:55:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16723.39578.994807.361949@cse.unsw.edu.au>
References: <1095375544.839c1c96.5@fieldses.org>
	<1095377696.10216.41.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAhB5-00083d-4p
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 20:55:23 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAhB4-0002Zz-N2
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 20:55:23 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Thursday September 16
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

On Thursday September 16, trond.myklebust@fys.uio.no wrote:
> P=E5 to , 16/09/2004 klokka 19:16, skreiv J. Bruce Fields:
> > +=09/* XXX: correct list?  Add field to proc? */
> > +=09/* XXX: SMPROC_NOTIFY may be a special case. */
> > +=09/* XXX: double-check: make sure the procedure numbers make sens=
e
> > +=09 * across all nlm versions.  Check NOTIFY in particular. */
> > +=09return proc =3D=3D NLMPROC_GRANTED
> > +=09=09|| proc =3D=3D NLMPROC_TEST_RES
> > +=09=09|| proc =3D=3D NLMPROC_LOCK_RES
> > +=09=09|| proc =3D=3D NLMPROC_CANCEL_RES
> > +=09=09|| proc =3D=3D NLMPROC_UNLOCK_RES
> > +=09=09|| proc =3D=3D NLMPROC_GRANTED_RES;
>=20
> || proc =3D=3D NLMPROC_NSM_NOTIFY

|| proc =3D=3D NLMPROC_GRANTED_MSG

which is the case that is actually causing problems.....(at least in
my testing)

:-)

NeilBrown

>=20
> Cheers,
>   Trond


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
