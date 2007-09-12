From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [NFS] [patch] sunrpc: make closing of old temporary sockets work (was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 16:37:16 +0200
Message-ID: <200709121637.16802.wolfgang.walter@studentenwerk.mhn.de>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de> <20070912133729.GA24998@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: trond.myklebust@fys.uio.no, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070912133729.GA24998@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Am Mittwoch, 12. September 2007 15:37 schrieb J. Bruce Fields:
> On Wed, Sep 12, 2007 at 02:07:10PM +0200, Wolfgang Walter wrote:
> > as already described old temporary sockets (client is gone) of lock=
d
> > aren't closed after some time. So, with enough clients and some tim=
e
> > gone, there are 80 open dangling sockets and you start getting mess=
ages
> > of the form:
> >
> > lockd: too many open TCP sockets, consider increasing the number of=
 nfsd
> > threads.
>
> Thanks for working on this problem!
>
> > If I understand the code then the intention was that the server clo=
ses
> > temporary sockets after about 6 to 12 minutes:
> >
> > 	a timer is started which calls svc_age_temp_sockets every 6 minute=
s.
> >
> > 	svc_age_temp_sockets:
> > 		if a socket is marked OLD it gets closed.
> > 		sockets which are not marked as OLD are marked OLD
> >
> > 	every time the sockets receives something OLD is cleared.
> >
> > But svc_age_temp_sockets never closes any socket though because it =
only
> > closes sockets with svsk->sk_inuse =3D=3D 0. This seems to be a bug=
=2E
> >
> > Here is a patch against 2.6.22.6 which changes the test to
> > svsk->sk_inuse <=3D 0 which was probably meant. The patched kernel =
runs
> > fine here. Unused sockets get closed (after 6 to 12 minutes)
>
> So the fact that this changes the behavior means that sk_inuse is tak=
ing
> on negative values.  This can't be right--how can something like
> svc_sock_put() (which does an atomic_dec_and_test) work in that case?

You probably misread the code.

if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
	continue;

This means: any socket where svsk->sk_inuse !=3D 0 or SK_BUSY is set is=
 ignored
by svc_age_temp_sockets: no attempt is made to close the svc.

This seems to be wrong: if svsk->sk_inuse is zero only if svc_delete_so=
cket
has been called for it and will be deleted anyway (probably it is alrea=
dy
closed then).

But the intention of svc_age_temp_sockets is to close open temporary
sockets where no traffic has been received for more than 6 minutes. The=
se
sockets have svsk->sk_inuse >=3D 1.

My patch does exactly this:

instead of

"skip sockets which are not already deleted or which are busy"

to

"skip sockets which are already deleted or which are busy"

>
> I wish I had time today to figure out what's going on in this case.  =
But
> from a quick through svsock.c for sk_inuse, it looks odd; I'm suspici=
ous
> of anything without the stereotyped behavior--initializing to one,
> atomic_inc()ing whenever someone takes a reference, and
> atomic_dec_and_test()ing whenever someone drops it....
>

Then svc_tcp_accept would be wrong, too (it closes sockets the same way=
 just
without testing for sk_inuse and SK_BUSY).

I think this works because as long as a socket is in sv_tempsocks or
sv_permsocks svsk->sk_inuse can never reach zero. As svc_age_temp_socke=
ts locks
the list nobody can bring svsk->sk_inuse to zero as long as
svc_age_temp_sockets holds the lock. As svc_age_temp_sockets calls
atomic_inc(&svsk->sk_inuse) when holding the lock there is no
problem. (the same is true for svc_tcp_accept).

This is the reason why I doubt that this check for svsk->sk_inuse in
svc_age_temp_sockets is usefull at all. It should be always false.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
