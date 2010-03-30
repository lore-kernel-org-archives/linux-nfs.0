From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 30 Mar 2010 10:25:42 -0700
Message-ID: <20100330172542.GI2513@linux.vnet.ibm.com>
References: <20100319022527.GC2894@linux.vnet.ibm.com>
 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <20100330164912.GG2513@linux.vnet.ibm.com>
 <1269968671.10116.17.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: David Howells <dhowells@redhat.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:46417 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752673Ab0C3RZo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 13:25:44 -0400
In-Reply-To: <1269968671.10116.17.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 30, 2010 at 07:04:31PM +0200, Eric Dumazet wrote:
> Le mardi 30 mars 2010 =E0 09:49 -0700, Paul E. McKenney a =E9crit :
> > On Tue, Mar 30, 2010 at 05:39:11PM +0100, David Howells wrote:
> > > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > >=20
> > > > Scrap this one -- Arnd has it covered, under the much better na=
me
> > > > of rcu_dereference_const().
> > >=20
> > > Not convinced of that name either.  That sounds like the RCU dere=
ference of
> > > constant (R/O) data.
> >=20
> > Which it is, as long as the lock is held.
> >=20
> > But what name would you suggest?
> >=20
>=20
> Maybe use 'protected' word or something like that, or 'owned', ...
>=20
> rcu_dereference_protected() or rcu_dereference_owned()

I do like rcu_dereference_protected() -- a bit longer than
rcu_dereference_locked(), but covers the initialization and cleanup
accesses that might be protected by privatization rather than by lockin=
g.

Other thoughts?

							Thanx, Paul
