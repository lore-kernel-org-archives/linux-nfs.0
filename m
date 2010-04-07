From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and
 rcu_dereference_protect
Date: Wed, 07 Apr 2010 18:00:35 +0200
Message-ID: <1270656035.8141.23.camel@edumazet-laptop>
References: <1270652210.8141.9.camel@edumazet-laptop>
	 <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
	 <25990.1270654809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: paulmck@linux.vnet.ibm.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:59178 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab0DGQAn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 12:00:43 -0400
In-Reply-To: <25990.1270654809@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 16:40 +0100, David Howells a =C3=A9cri=
t :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > This is not the version Paul posted.=20
> >=20
> > Removing checks just to shutup warnings ?
>=20
> No.  I don't see the point in the condition.
>=20
> > All the point is to get lockdep assistance, and you throw it away.
> >=20
> > We want to explicit the condition, so that RCU users can explicitly
> > state what protects their data.
>=20
> You've missed the point.
>=20

You already claimed I dont understand RCU. I find this claim funny.


> For rcu_access_pointer(), _nothing_ protects the data, not only that,=
 we don't
> care: we're only checking the pointer.

How can you state this ?

Thats pretty simple, "always true" is a fine condition.

What's the problem with this ?

>=20
> For rcu_dereference_protect[ed](), I don't see that the check helps. =
 You
> don't need to be holding the RCU lock to call it, but you do need to =
hold all
> the requisite locks required to exclude others modifying it.  That's =
a
> precondition for calling this function, so is there any point in test=
ing it
> again?
>=20

If you dont see how the check can help, why dont you unset
CONFIG_PROVE_RCU ?


> For instance, consider the following pseudocode:
>=20
> 	do_something(struct foo *p)
> 	{
> 		struct bar *b;
> 		spin_lock(&foo->lock);
> 		b =3D rcu_dereference_protected(
> 			foo->bar, lockdep_is_held(&foo->lock));
> 		do_something_to_bar(b);
> 		spin_unlock(&foo->lock);
> 	}
>=20
> is there any need for the condition?=20

Yes, this is what is needed to help to catch when a condition is not
met.

Of course, on trivial code like this one, its pretty obvious condition
will be always true.

In many cases, smp_processor_id() checks are obvious too, yet we perfor=
m
them. It can help us sometimes, because many developers forget the
obvious things.

>  Does lockdep_is_held() have any side
> effects beyond those listed in the Documentation directory or on its =
attached
> banner comments?
>=20
>=20
> Furthermore, I think the condition in rcu_dereference_check() may wel=
l be
> misused.  For instance, Paul suggested:
>=20
> 	cred =3D rcu_dereference_check(delegation->cred,
> 				     delegation->inode =3D=3D NULL);
>=20
> but if 'c' is supposed to be the locks that protect the data, is this=
 a valid
> check?

'c' is not a lock. Its a condition.

You as the author of this code, decide of the condition to check.

You therefore can answer yourself to this question.

Example of non trivial check :

static void __sk_free(struct sock *sk)
{
=2E..
filter =3D rcu_dereference_check(sk->sk_filter,
			       atomic_read(&sk->sk_wmem_alloc) =3D=3D 0);
=2E..
}

In this check, there is no lock held.


commit a898def29e4119bc01ebe7ca97423181f4c0ea2d
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Feb 22 17:04:49 2010 -0800

    net: Add checking to rcu_dereference() primitives
   =20
    Update rcu_dereference() primitives to use new lockdep-based
    checking. The rcu_dereference() in __in6_dev_get() may be
    protected either by rcu_read_lock() or RTNL, per Eric Dumazet.
    The rcu_dereference() in __sk_free() is protected by the fact
    that it is never reached if an update could change it.  Check
    for this by using rcu_dereference_check() to verify that the
    struct sock's ->sk_wmem_alloc counter is zero.
   =20
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Acked-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Cc: laijs@cn.fujitsu.com
    Cc: dipankar@in.ibm.com
    Cc: mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org
    Cc: josh@joshtriplett.org
    Cc: dvhltc@us.ibm.com
    Cc: niv@us.ibm.com
    Cc: peterz@infradead.org
    Cc: rostedt@goodmis.org
    Cc: Valdis.Kletnieks@vt.edu
    Cc: dhowells@redhat.com
    LKML-Reference:
<1266887105-1528-5-git-send-email-paulmck@linux.vnet.ibm.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

=2E..
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1073,7 +1073,8 @@ static void __sk_free(struct sock *sk)
        if (sk->sk_destruct)
                sk->sk_destruct(sk);
=20
-       filter =3D rcu_dereference(sk->sk_filter);
+       filter =3D rcu_dereference_check(sk->sk_filter,
+                                      atomic_read(&sk->sk_wmem_alloc) =
=3D=3D 0);
        if (filter) {
                sk_filter_uncharge(sk, filter);
                rcu_assign_pointer(sk->sk_filter, NULL);



