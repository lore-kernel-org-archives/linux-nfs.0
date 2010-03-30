From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 30 Mar 2010 19:04:31 +0200
Message-ID: <1269968671.10116.17.camel@edumazet-laptop>
References: <20100329210520.GN2569@linux.vnet.ibm.com>
	 <20100329192159.GM2569@linux.vnet.ibm.com>
	 <20100319022527.GC2894@linux.vnet.ibm.com>
	 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
	 <19192.1269889348@redhat.com> <23274.1269893706@redhat.com>
	 <25276.1269901350@redhat.com> <26760.1269903543@redhat.com>
	 <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com>
	 <20100330164912.GG2513@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Howells <dhowells@redhat.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56307 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab0C3REj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Mar 2010 13:04:39 -0400
In-Reply-To: <20100330164912.GG2513@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mardi 30 mars 2010 =C3=A0 09:49 -0700, Paul E. McKenney a =C3=A9crit=
 :
> On Tue, Mar 30, 2010 at 05:39:11PM +0100, David Howells wrote:
> > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> >=20
> > > Scrap this one -- Arnd has it covered, under the much better name
> > > of rcu_dereference_const().
> >=20
> > Not convinced of that name either.  That sounds like the RCU derefe=
rence of
> > constant (R/O) data.
>=20
> Which it is, as long as the lock is held.
>=20
> But what name would you suggest?
>=20

Maybe use 'protected' word or something like that, or 'owned', ...

rcu_dereference_protected() or rcu_dereference_owned()



