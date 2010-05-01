Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36208 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758141Ab0EAAbz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 20:31:55 -0400
Date: Fri, 30 Apr 2010 17:31:53 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: mingo@elte.hu, peterz@infradead.org, Trond.Myklebust@netapp.com
Subject: [PATCH] fix RCU-lockdep splats in NFS
Message-ID: <20100501003153.GA27982@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello!

The following pair of fixes for RCU-lockdep splats have passed testing,
so are ready for inclusion.  Ingo suggests the NFS tree, so here they are!

							Thanx, Paul

------------------------------------------------------------------------

 b/fs/nfs/delegation.c |   42 ++++++++++++++++++++++++++++--------------
 fs/nfs/delegation.c   |   44 +++++++++++++++++++++++---------------------
 2 files changed, 51 insertions(+), 35 deletions(-)
