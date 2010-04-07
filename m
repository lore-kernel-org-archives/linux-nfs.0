From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and
 rcu_dereference_protect
Date: Wed, 07 Apr 2010 18:29:17 +0200
Message-ID: <1270657757.8141.30.camel@edumazet-laptop>
References: <1270656035.8141.23.camel@edumazet-laptop>
	 <1270652210.8141.9.camel@edumazet-laptop>
	 <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
	 <25990.1270654809@redhat.com>  <26698.1270657193@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: paulmck@linux.vnet.ibm.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47179 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab0DGQ31 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 12:29:27 -0400
In-Reply-To: <26698.1270657193@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 17:19 +0100, David Howells a =C3=A9cri=
t :

> Why not:
>=20
> 	ASSERT(atomic_read(&sk->sk_wmem_alloc) =3D=3D 0);
> 	filter =3D rcu_dereference(sk->sk_filter);
>=20
> This is much clearer, and you're not combining an unrelated assertion=
 with the
> RCU dereference.

1) Because we want the check being done only when CONFIG_PROVE_RCU is
set.

2) Because rcu_dereference() default condition is : 'Am I owning
rcu_read_lock() or equivalent'.=20
In this context, I am _not_ owning rcu lock, so we will trigger a
warning.


So this is best done as is :)

I personally find this very clear and clean, this is why I acked Paul
patch :)

If we were 100% sure testing sk_wmem_alloc is not necessary, we would
have put :

filter =3D rcu_dereference_check(sk->sk_filter, 1);



