From: Frans Pop <aragorn@tiscali.nl>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Mon, 15 Sep 2003 18:46:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309151846.57189.aragorn@tiscali.nl>
References: <200309132202.47195.aragorn@tiscali.nl> <20030915022303.GB8188@perlsupport.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, 165744@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ywVM-00069f-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Sep 2003 09:47:12 -0700
Received: from matilda.tiscali.nl ([195.241.51.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19ywVL-0000Jp-Vx
	for nfs@lists.sourceforge.net; Mon, 15 Sep 2003 09:47:12 -0700
To: Chip Salzenberg <chip@pobox.com>,
	Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20030915022303.GB8188@perlsupport.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

And here is the proof!
I added a simple log statement to the monitor.c source where SM_UNMON is=20
handled.

=3D=3D=3D SNIP FROM MONITOR.C =3D=3D=3D
* OK, we are.  Now look for appropriate entry in run-time list.
* There should only be *one* match on this, since I block "duplicate"
* SM_MON calls.  (Actually, duplicate calls are allowed, but only one
* entry winds up in the list the way I'm currently handling them.)
*/
while ((clnt =3D nlist_gethost(clnt, mon_name, 0))) {
+++++ ADDED LINES +++++
        log(L_WARNING, "Result of hostname lookup: %s is %s",
                my_name, NL_MY_NAME(clnt));
+++++ ADDED LINES END +++++
        if (matchhostname(NL_MY_NAME(clnt), my_name) &&
                NL_MY_PROC(clnt) =3D=3D id->my_proc &&
                NL_MY_PROG(clnt) =3D=3D id->my_prog &&
                NL_MY_VERS(clnt) =3D=3D id->my_vers) {
                /* Match! */
=3D=3D=3D END OF SNIP FROM MONITOR.C =3D=3D=3D

This results in my log in:
rpc.statd[3066]: Result of hostname lookup: galadriel is 127.0.0.1
rpc.statd[3066]: Received erroneous SM_UNMON request from galadriel for=20
10.19.66.2

On Monday 15 September 2003 04:23, Chip Salzenberg wrote:
> According to Frans Pop:
> > I think the reason the error appears in my setup could be because I have
> > NFS kernel-support compiled in both server and clients. In Debian, this
> > means rpc.lockd is not run from the init scripts.
>
> What does the timing of lockd have to do with it?  Because that's the
> only difference between a user-space lockd and a kernel-thread lockd;
> the kernel thread only starts up when something might need it, while
> the user-space one starts up at boot time.

I'm not sure how this would affect things. I was just looking for an=20
explanation why this problem has not been reported by many, many more peopl=
e=20
who use NFS.

=46rans Pop
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE/Zezigm/Kwh6ICoQRAsBOAJ0aCpzc+i2BSx5DOccWRHFYeijclACgum3p
6ZlKRKULyVMcaL5LqQQj5GE=3D
=3DZkmx
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
