From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 31 Mar 2010 18:37:34 +0100
Message-ID: <15371.1270057054@redhat.com>
References: <20100331151604.GC2461@linux.vnet.ibm.com> <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk> <19192.1269889348@redhat.com> <23274.1269893706@redhat.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab0CaRhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 13:37:40 -0400
In-Reply-To: <20100331151604.GC2461@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Protected by something that the caller did, be it holding the the correct
> lock, operating on it during initialization before other CPUs have access
> to it, operating on it during cleanup after other CPUs' access has been
> revoked, or whatever.

But the point I made very early this morning still stands:  What if someone
simply wants to test the pointer, not actually to dereference it?

NFS was using rcu_dereference() for this in a couple of places - which is
overkill.  I suggested stripping this off and you countered with the
suggestion that it should be using rcu_dereference_check().

Why do I need anything at all?

David
