Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:50439 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbaBLVmN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Feb 2014 16:42:13 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 14:42:12 -0700
Date: Wed, 12 Feb 2014 13:42:09 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Question about nfs4_destroy_session()
Message-ID: <20140212214209.GA4136@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond,

In nfs4_destroy_session(), there is an rcu_dereference() that looks to
leak the returned pointer out of an RCU read-side critical section.
If the pointed-to object might have just now been created, this is a
bug because xprt_destroy_backchannel() dereferences this pointer.

So, does xprt_destroy_backchannel() exclude creation-side code?  (If so,
no bug -- but a comment might be good.)

							Thanx, Paul

void nfs4_destroy_session(struct nfs4_session *session)
{
	struct rpc_xprt *xprt;
	struct rpc_cred *cred;

	cred = nfs4_get_clid_cred(session->clp);
	nfs4_proc_destroy_session(session, cred);
	if (cred)
		put_rpccred(cred);

	rcu_read_lock();
	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
	rcu_read_unlock();
	dprintk("%s Destroy backchannel for xprt %p\n",
		__func__, xprt);
	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
	nfs4_destroy_session_slot_tables(session);
	kfree(session);
}

