From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 06 Apr 2010 10:30:31 +0100
Message-ID: <17100.1270546231@redhat.com>
References: <20100405175754.GE2525@linux.vnet.ibm.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com> <14003.1270122314@redhat.com> <4161.1270133211@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669Ab0DFJam (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 05:30:42 -0400
In-Reply-To: <20100405175754.GE2525@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> And here is the corresponding patch.  Seem reasonable?

Okay.  Still not keen on the name, but it'll do.

I think the problem is that rcu_dereference() is itself a misnomer: It doesn't
actually dereference.

Anyway:

Acked-by: David Howells <dhowells@redhat.com>
