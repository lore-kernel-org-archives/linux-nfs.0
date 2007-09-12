From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets work (was: problems with lockd in 2.6.22.6)
Date: Thu, 13 Sep 2007 00:18:55 +0200
Message-ID: <200709130018.55728.wolfgang.walter@studentenwerk.mhn.de>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de> <200709122140.57783.wolfgang.walter@studentenwerk.mhn.de> <20070912195512.GC13792@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@suse.de>, trond.myklebust@fys.uio.no,
	netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070912195512.GC13792@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wednesday 12 September 2007, J. Bruce Fields wrote:
> On Wed, Sep 12, 2007 at 09:40:57PM +0200, Wolfgang Walter wrote:
> > On Wednesday 12 September 2007, J. Bruce Fields wrote:
> > > On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> > > > So it is in 2.6.21 and later and should probably go to .stable =
for .21
> > > > and .22.
> > > >=20
> > > > Bruce:  for you :-)
> > >=20
> > > OK, thanks!  But, (as is alas often the case) I'm still confused:
> > >=20
> > > >  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
> > > >  			continue;
> > > > -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY,=20
&svsk->sk_flags))
> > > > +		if (atomic_read(&svsk->sk_inuse) > 1
> > > > +		    || test_bit(SK_BUSY, &svsk->sk_flags))
> > > >  			continue;
> > > >  		atomic_inc(&svsk->sk_inuse);
> > > >  		list_move(le, &to_be_aged);
> > >=20
> > > What is it that ensures svsk->sk_inuse isn't incremented or SK_BU=
SY set
> > > after that test?  Not all the code that does either of those is u=
nder
> > > the same serv->sv_lock lock that this code is.
> > >=20
> >=20
> > This should not matter - SK_CLOSED may be set at any time.
> >=20
> > svc_age_temp_sockets only detaches the socket, sets SK_CLOSED and t=
hen=20
> > enqueues it. If SK_BUSY is set its already enqueued and svc_sock_en=
queue=20
> > ensures that it is not enqueued twice.
>=20
> Oh, got it.  And the list manipulation is safe thanks to sv_lock.  Ne=
at,
> thanks.  Can you verify that this solves your problem?
>=20

I'll test it tomorrow. So friday morning I'll know and mail you for sur=
e.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
