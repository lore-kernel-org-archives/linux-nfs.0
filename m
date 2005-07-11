From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in
	locks_remove_posix
Date: Mon, 11 Jul 2005 09:52:17 -0400
Message-ID: <1121089937.13326.41.camel@lade.trondhjem.org>
References: <20050711103250.GH27163@suse.de>
	 <1121084217.8204.52.camel@lade.trondhjem.org>
	 <20050711124840.GR27163@suse.de>
	 <1121086941.13326.14.camel@lade.trondhjem.org>
	 <20050711131639.GU27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dryi0-0003Er-UF
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:52:32 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Dryi0-0004Ei-NI
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:52:33 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711131639.GU27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 15:16 (+0200) skreiv Olaf Kirch:
> On Mon, Jul 11, 2005 at 09:02:21AM -0400, Trond Myklebust wrote:
> > For posix locks we should pretty much be ignoring the value of fl_pid.
> > It gets returned to the user in a F_GETLK call, but all the low-level
> > functions (such as posix_same_owner) should be testing the value of
> > fl_owner instead.
> >=20
> > The exception here is nlmsvc_same_owner(), which has to follow the NLM
> > byte range spec but doesn't rely on locks_remove_posix.
>=20
> Let me try to explain this a little better. What I believe is happening
> is that on the client, thread A with tgid 0xA establishes a lock,
> and when thread B closes the file. locks_remove_posix sends an unlock req=
uest
> to the server with tgid 0xB.
>=20
> On the server, posix_lock_file walks the list of all existing locks,
> comparing the lock owner via nlmsvc_same_owner - and since the fl_pid
> value of the request is 0xB, this misses the established lock with
> fl_pid =3D=3D 0xA.

Then let me be more precise. The server should never see any value
fl_pid =3D=3D 0xA or 0xB.

In the case of NLM, we use the function nlm_find_lockowner() to create a
mapping between fl_owner and a 32-bit numerical value which we call
"pid", but which is really just a unique number. This mapping is
preserved at least for the lifetime of the lock, and is shared between
all locks that reference the same fl_owner.
The "pid" of this mapping is the number that is seen by the server.

Aside from ensuring that the current locks_remove_posix works properly,
it also ensures that the client and server have the same behaviour
w.r.t. merging locks. Recall that the client will merge locks with the
same fl_owner, and the server merges locks with the same pid. If the two
were to differ...

Note that the NFSv4 protocol uses a string called a "lockowner" instead
of the 32-bit "pid" value, so we don't need to maintain a special
mapping there.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
