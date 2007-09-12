From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets work (was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 21:40:57 +0200
Message-ID: <200709122140.57783.wolfgang.walter@studentenwerk.mhn.de>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de> <18151.62510.891210.485277@notabene.brown> <20070912184222.GG4274@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@suse.de>, trond.myklebust@fys.uio.no,
	netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070912184222.GG4274@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wednesday 12 September 2007, J. Bruce Fields wrote:
> On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> > So it is in 2.6.21 and later and should probably go to .stable for =
=2E21
> > and .22.
> >=20
> > Bruce:  for you :-)
>=20
> OK, thanks!  But, (as is alas often the case) I'm still confused:
>=20
> >  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
> >  			continue;
> > -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_=
flags))
> > +		if (atomic_read(&svsk->sk_inuse) > 1
> > +		    || test_bit(SK_BUSY, &svsk->sk_flags))
> >  			continue;
> >  		atomic_inc(&svsk->sk_inuse);
> >  		list_move(le, &to_be_aged);
>=20
> What is it that ensures svsk->sk_inuse isn't incremented or SK_BUSY s=
et
> after that test?  Not all the code that does either of those is under
> the same serv->sv_lock lock that this code is.
>=20

This should not matter - SK_CLOSED may be set at any time.

svc_age_temp_sockets only detaches the socket, sets SK_CLOSED and then=20
enqueues it. If SK_BUSY is set its already enqueued and svc_sock_enqueu=
e=20
ensures that it is not enqueued twice.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
