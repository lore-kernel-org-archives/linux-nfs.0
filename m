From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and
 rcu_dereference_protect
Date: Wed, 7 Apr 2010 08:59:29 -0700
Message-ID: <20100407155929.GB2481@linux.vnet.ibm.com>
References: <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
 <1270652210.8141.9.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: David Howells <dhowells@redhat.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42947 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932581Ab0DGP7f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 11:59:35 -0400
In-Reply-To: <1270652210.8141.9.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 07, 2010 at 04:56:50PM +0200, Eric Dumazet wrote:
> Le mercredi 07 avril 2010 =E0 14:57 +0100, David Howells a =E9crit :
> > From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >=20
> > This patch adds variants of rcu_dereference() that handle situation=
s
> > where the RCU-protected data structure cannot change, perhaps due t=
o
> > our holding the update-side lock, or where the RCU-protected pointe=
r is
> > only to be fetched, not dereferenced.
> >=20
> > The new rcu_access_pointer() primitive is for the case where the po=
inter
> > is be fetch and not dereferenced.  This primitive may be used witho=
ut
> > protection, RCU or otherwise, due to the fact that it uses ACCESS_O=
NCE().
> >=20
> > The new rcu_dereference_protect() primitive is for the case where u=
pdates
> > are prevented, for example, due to holding the update-side lock.  T=
his
> > primitive does neither ACCESS_ONCE() nor smp_read_barrier_depends()=
, so
> > can only be used when updates are somehow prevented.
> >=20
> > Suggested-by: David Howells <dhowells@redhat.com>
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Signed-off-by: David Howells <dhowells@redhat.com>
> > ---
> >=20
> >  include/linux/rcupdate.h |   34 ++++++++++++++++++++++++++++++++++
> >  1 files changed, 34 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> > index 872a98e..a1b14b6 100644
> > --- a/include/linux/rcupdate.h
> > +++ b/include/linux/rcupdate.h
> > @@ -209,9 +209,43 @@ static inline int rcu_read_lock_sched_held(voi=
d)
> >  		rcu_dereference_raw(p); \
> >  	})
> > =20
> > +/**
> > + * rcu_access_pointer - fetch RCU pointer with no dereferencing
> > + *
> > + * Return the value of the specified RCU-protected pointer, but om=
it the
> > + * smp_read_barrier_depends() and keep the ACCESS_ONCE().  This is=
 useful
> > + * when the value of this pointer is accessed, but the pointer is =
not
> > + * dereferenced, for example, when testing an RCU-protected pointe=
r against
> > + * NULL.  This may also be used in cases where update-side locks p=
revent
> > + * the value of the pointer from changing, but rcu_dereference_pro=
tect()
> > + * is a lighter-weight primitive for this use case.
> > + */
> > +#define rcu_access_pointer(p) \
> > +	({ \
> > +		ACCESS_ONCE(p); \
> > +	})
> > +
> > +/**
> > + * rcu_dereference_protected - fetch RCU pointer when updates prev=
ented
> > + *
> > + * Return the value of the specified RCU-protected pointer, but om=
it
> > + * both the smp_read_barrier_depends() and the ACCESS_ONCE().  Thi=
s
> > + * is useful in cases where update-side locks prevent the value of=
 the
> > + * pointer from changing.  Please note that this primitive does -n=
ot-
> > + * prevent the compiler from repeating this reference or combining=
 it
> > + * with other references, so it should not be used without protect=
ion
> > + * of appropriate locks.
> > + */
> > +#define rcu_dereference_protected(p) \
> > +	({ \
> > +		(p); \
> > +	})
> > +
> >  #else /* #ifdef CONFIG_PROVE_RCU */
> > =20
> >  #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
> > +#define rcu_access_pointer(p)		ACCESS_ONCE(p)
> > +#define rcu_dereference_protect(p)	(p)
> > =20
> >  #endif /* #else #ifdef CONFIG_PROVE_RCU */
> > =20
> >=20
> > --
>=20
> This is not the version Paul posted.=20

I blew the name -- rcu_dereference_protected() is in fact a better name=
=2E

> Removing checks just to shutup warnings ?
>=20
> All the point is to get lockdep assistance, and you throw it away.
>=20
> We want to explicit the condition, so that RCU users can explicitly
> state what protects their data.

What Eric said!!!  ;-)

							Thanx, Paul
