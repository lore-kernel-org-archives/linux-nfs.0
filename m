From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and
 rcu_dereference_protect
Date: Wed, 07 Apr 2010 18:35:38 +0200
Message-ID: <1270658138.8141.36.camel@edumazet-laptop>
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
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41173 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757966Ab0DGQfp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 12:35:45 -0400
In-Reply-To: <26698.1270657193@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 17:19 +0100, David Howells a =C3=A9cri=
t :

> what is the value of sk->sk_wmem_alloc to the lock context of sk->sk_=
filter?
> Why would lockdep be interested in sk_wmem_alloc?
>=20
> Surely, the assertion that the value of sk->sk_filter is related to
> sk_wmem_alloc being 0 is independent of the need to dereference sk_fi=
lter for
> RCU purposes.  So why are these being combined?

Because when sk->sk_filter is eventually written by some thread, this
thread _must_ own a reference on the socket, that is sk_wmem_alloc > 0

So when reading sk->sk_filter, the general condition is :=20
- We own the rcu lock=20
- But on the particular case of __sk_free(),
  we owned the very last reference to sk (we are going to kfree it), so
nobody can possibly change sk->sk_filter under us.



