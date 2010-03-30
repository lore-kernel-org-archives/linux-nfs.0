From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 30 Mar 2010 17:39:11 +0100
Message-ID: <2440.1269967151@redhat.com>
References: <20100330154015.GA8183@linux.vnet.ibm.com> <20100329223609.GR2569@linux.vnet.ibm.com> <20100329210520.GN2569@linux.vnet.ibm.com> <20100329192159.GM2569@linux.vnet.ibm.com> <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk> <19192.1269889348@redhat.com> <23274.1269893706@redhat.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753670Ab0C3QjS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 12:39:18 -0400
In-Reply-To: <20100330154015.GA8183@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Scrap this one -- Arnd has it covered, under the much better name
> of rcu_dereference_const().

Not convinced of that name either.  That sounds like the RCU dereference of
constant (R/O) data.

David
