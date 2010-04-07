From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and
 rcu_dereference_protect
Date: Wed, 07 Apr 2010 16:56:50 +0200
Message-ID: <1270652210.8141.9.camel@edumazet-laptop>
References: <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: paulmck@linux.vnet.ibm.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45040 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581Ab0DGO45 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 10:56:57 -0400
In-Reply-To: <20100407135732.12414.16416.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 14:57 +0100, David Howells a =C3=A9cri=
t :
> From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> This patch adds variants of rcu_dereference() that handle situations
> where the RCU-protected data structure cannot change, perhaps due to
> our holding the update-side lock, or where the RCU-protected pointer =
is
> only to be fetched, not dereferenced.
>=20
> The new rcu_access_pointer() primitive is for the case where the poin=
ter
> is be fetch and not dereferenced.  This primitive may be used without
> protection, RCU or otherwise, due to the fact that it uses ACCESS_ONC=
E().
>=20
> The new rcu_dereference_protect() primitive is for the case where upd=
ates
> are prevented, for example, due to holding the update-side lock.  Thi=
s
> primitive does neither ACCESS_ONCE() nor smp_read_barrier_depends(), =
so
> can only be used when updates are somehow prevented.
>=20
> Suggested-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
>  include/linux/rcupdate.h |   34 ++++++++++++++++++++++++++++++++++
>  1 files changed, 34 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 872a98e..a1b14b6 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -209,9 +209,43 @@ static inline int rcu_read_lock_sched_held(void)
>  		rcu_dereference_raw(p); \
>  	})
> =20
> +/**
> + * rcu_access_pointer - fetch RCU pointer with no dereferencing
> + *
> + * Return the value of the specified RCU-protected pointer, but omit=
 the
> + * smp_read_barrier_depends() and keep the ACCESS_ONCE().  This is u=
seful
> + * when the value of this pointer is accessed, but the pointer is no=
t
> + * dereferenced, for example, when testing an RCU-protected pointer =
against
> + * NULL.  This may also be used in cases where update-side locks pre=
vent
> + * the value of the pointer from changing, but rcu_dereference_prote=
ct()
> + * is a lighter-weight primitive for this use case.
> + */
> +#define rcu_access_pointer(p) \
> +	({ \
> +		ACCESS_ONCE(p); \
> +	})
> +
> +/**
> + * rcu_dereference_protected - fetch RCU pointer when updates preven=
ted
> + *
> + * Return the value of the specified RCU-protected pointer, but omit
> + * both the smp_read_barrier_depends() and the ACCESS_ONCE().  This
> + * is useful in cases where update-side locks prevent the value of t=
he
> + * pointer from changing.  Please note that this primitive does -not=
-
> + * prevent the compiler from repeating this reference or combining i=
t
> + * with other references, so it should not be used without protectio=
n
> + * of appropriate locks.
> + */
> +#define rcu_dereference_protected(p) \
> +	({ \
> +		(p); \
> +	})
> +
>  #else /* #ifdef CONFIG_PROVE_RCU */
> =20
>  #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
> +#define rcu_access_pointer(p)		ACCESS_ONCE(p)
> +#define rcu_dereference_protect(p)	(p)
> =20
>  #endif /* #else #ifdef CONFIG_PROVE_RCU */
> =20
>=20
> --

This is not the version Paul posted.=20

Removing checks just to shutup warnings ?

All the point is to get lockdep assistance, and you throw it away.

We want to explicit the condition, so that RCU users can explicitly
state what protects their data.



