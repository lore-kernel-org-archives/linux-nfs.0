From: Philippe Troin <phil@fifi.org>
Subject: Re: linux 2.4.20 oops
Date: 29 Apr 2003 09:31:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87of2pxo37.fsf@ceramic.fifi.org>
References: <8147E1B07201DD41B6B9F0D31E07B384449055@srv-grp-s07.dev.atos.fr>
	<3EAE498A.1000106@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AY1D-0006sv-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:31:47 -0700
To: Danny Smith <dannys@cinesite.co.uk>
In-Reply-To: <3EAE498A.1000106@cinesite.co.uk>
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

Danny Smith <dannys@cinesite.co.uk> writes:

> Brasseur Val=E9ry wrote:
>=20
> >I have got this oops in my kernel (2.4.20 + NFS-ALL )
> >note : the oops are not log in syslog (don't know why !)
> >but the oops seems nfs-related, any ideas ?
>=20
> We had almost identical oopses with the same setup on our dual
> render boxes, which would often panic almost immediately afterwards.
>=20
> We used this patch from Ulrich Weigand
> (weigand@informatik.uni-erlangen.de), and haven't seen a problem
> since. See the archives for full details - basically seems to be an
> SMP race in rpc_delete_timer(). If you're not on an SMP system, it's
> probably NOT the right fix.

Has this been pushed to 2.4.21?

Phil.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
