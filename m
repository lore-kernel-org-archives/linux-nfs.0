From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Mon, 11 Jul 2005 14:48:41 +0200
Message-ID: <20050711124840.GR27163@suse.de>
References: <20050711103250.GH27163@suse.de> <1121084217.8204.52.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxiH-0000Iq-Mf
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:48:45 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxiH-00053m-BC
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:48:45 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121084217.8204.52.camel@lade.trondhjem.org>
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

On Mon, Jul 11, 2005 at 08:16:57AM -0400, Trond Myklebust wrote:
> m=E5 den 11.07.2005 Klokka 12:32 (+0200) skreiv Olaf Kirch:
> > # Subject: [NFS] Use proper tgid in locks_remove_posix
> > #=20
> > # This patch fixes a problem with lost unlock calls in multithreaded
> > # applications. locks_remove_posix would send a single unlock call wi=
th
> > # the task group ID of the current process, which may not be the same=
 as
> > # the tgid of the lock. This patch ensures that we send separate unlo=
ck
> > # calls for different fl_pid values.
>=20
> This doesn't look right. Why should a thread be killing locks that
> belong to a different process?

locks_remove_posix is called when we close a file, i.e. when it is remove=
d
from current->files. The problem arises when the files struct is shared
by several threads with different tgid (which seems to be the default
when using pthreads) - in this case we must make sure we send the
unlock call with the right tgid. Previously we would send the unlock call
using fl_pid =3D current->tgid.

Olaf
--=20
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
