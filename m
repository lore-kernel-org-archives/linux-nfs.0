From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 11:46:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B384449056@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ARx1-0001a4-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 03:03:03 -0700
To: 'Danny Smith' <dannys@cinesite.co.uk>
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

Thanks for your information ! we are on SMP boxes so I will try ASAP !

> -----Original Message-----
> From: Danny Smith [mailto:dannys@cinesite.co.uk]
> Sent: Tuesday, April 29, 2003 11:45 AM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] linux 2.4.20 oops
>=20
>=20
> Brasseur Val=E9ry wrote:
>=20
> >I have got this oops in my kernel (2.4.20 + NFS-ALL )
> >note : the oops are not log in syslog (don't know why !)
> >but the oops seems nfs-related, any ideas ?
> >
> We had almost identical oopses with the same setup on our=20
> dual render boxes,
> which would often panic almost immediately afterwards.
>=20
> We used this patch from Ulrich Weigand=20
> (weigand@informatik.uni-erlangen.de), and
> haven't seen a problem since. See the archives for full=20
> details - basically seems
> to be an SMP race in rpc_delete_timer(). If you're not on an=20
> SMP system,
> it's probably NOT the right fix.
>=20
> HTH,
>=20
> Danny
>=20
> Index: net/sunrpc/sched.c
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> RCS file: /home/cvs/linux-2.3/net/sunrpc/sched.c,v
> retrieving revision 1.13
> diff -u -p -r1.13 sched.c
> --- net/sunrpc/sched.c	3 May 2001 16:18:18 -0000	1.13
> +++ net/sunrpc/sched.c	8 Mar 2003 22:46:11 -0000
> @@ -168,10 +168,8 @@ void rpc_add_timer(struct rpc_task *task
>  static inline void
>  rpc_delete_timer(struct rpc_task *task)
>  {
> -	if (timer_pending(&task->tk_timer)) {
> +	if (del_timer_sync(&task->tk_timer))
>  		dprintk("RPC: %4d deleting timer\n", task->tk_pid);
> -		del_timer_sync(&task->tk_timer);
> -	}
>  }
> =20
>  /*
>=20
>=20
>=20
>=20
> --=20
> Danny Smith
> Senior Systems Administrator, Cinesite (Europe) Ltd
> 020 7973 4000 - x4055    /    dannys@cinesite.co.uk
>=20
>=20
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
