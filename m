From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 31 Mar 2010 20:32:46 +0200
Message-ID: <1270060366.1931.19.camel@edumazet-laptop>
References: <20100331151604.GC2461@linux.vnet.ibm.com>
	 <20100319022527.GC2894@linux.vnet.ibm.com>
	 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
	 <19192.1269889348@redhat.com> <23274.1269893706@redhat.com>
	 <25276.1269901350@redhat.com> <26760.1269903543@redhat.com>
	 <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com>
	 <21972.1269993064@redhat.com> <10818.1270044273@redhat.com>
	 <15371.1270057054@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: paulmck@linux.vnet.ibm.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:57625 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab0CaSdA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Mar 2010 14:33:00 -0400
In-Reply-To: <15371.1270057054@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mercredi 31 mars 2010 =C3=A0 18:37 +0100, David Howells a =C3=A9crit=
 :
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>=20
> > Protected by something that the caller did, be it holding the the c=
orrect
> > lock, operating on it during initialization before other CPUs have =
access
> > to it, operating on it during cleanup after other CPUs' access has =
been
> > revoked, or whatever.
>=20
> But the point I made very early this morning still stands:  What if s=
omeone
> simply wants to test the pointer, not actually to dereference it?
>=20
> NFS was using rcu_dereference() for this in a couple of places - whic=
h is
> overkill.  I suggested stripping this off and you countered with the
> suggestion that it should be using rcu_dereference_check().
>=20

If pointer has the rcu mark, and somehing access this pointer without
proper locking, then automatic checkers (sparse...) will trigger a
warning, this is what Paul said.

Example of such checks,=20

# define __percpu   __attribute__((noderef, address_space(3)))=20

If someone tries to manipulate a __percpu marked ptr without proper API=
,
sparse loudly complains.


> Why do I need anything at all?
>=20

If you dont own a lock, and test a pointer, what guarantee do you have
this pointer doesnt change right after you tested it ?

If *something* protects the pointer from being changed, then how can be
expressed this fact ?

If nothing protects the pointer, why test it then, as result of test is
unreliable ?

If NFS was using rcu_dereference(), it probably was for a reason, but i=
f
nobody can recall it, it was a wrong reason ?

Sorry, too many questions and no answer I guess...



