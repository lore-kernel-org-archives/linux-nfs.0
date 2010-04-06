From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 06 Apr 2010 20:34:06 +0100
Message-ID: <26510.1270582446@redhat.com>
References: <20100406172944.GB2553@linux.vnet.ibm.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com> <14003.1270122314@redhat.com> <4161.1270133211@redhat.com> <23331.1270570443@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756692Ab0DFTe1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 15:34:27 -0400
In-Reply-To: <20100406172944.GB2553@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> OK, just to make sure I understand you...  You are asking for two additional
> RCU API members:
> 
> 1.	rcu_access_pointer() or some such that includes ACCESS_ONCE(),
> 	but not smp_read_barrier_depends(), which may be used when
> 	we are simply examining the value of the RCU-protected pointer
> 	(as in the NFS case).  It could also be used when the
> 	appropriate update-side lock is held, but for that we have:
> 
> 2.	rcu_dereference_protected() or some such that includes neither
> 	ACCESS_ONCE() nor smp_read_barrier_depends(), and that may
> 	only be used if updates are prevented, for example, by holding
> 	the appropriate update-side lock.
> 
> Does this fit?

Yep.  I think so.

David
