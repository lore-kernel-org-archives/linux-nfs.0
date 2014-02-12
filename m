Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:55207 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbaBLVzF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Feb 2014 16:55:05 -0500
Received: by mail-oa0-f45.google.com with SMTP id i11so11643550oag.4
        for <linux-nfs@vger.kernel.org>; Wed, 12 Feb 2014 13:55:04 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: Question about nfs4_destroy_session()
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140212214209.GA4136@linux.vnet.ibm.com>
Date: Wed, 12 Feb 2014 16:55:02 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <5BCC49E0-6F92-49EC-BFCD-17D5CA4D30C7@primarydata.com>
References: <20140212214209.GA4136@linux.vnet.ibm.com>
To: paulmck@linux.vnet.ibm.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 12, 2014, at 16:42, Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Hello, Trond,
> 
> In nfs4_destroy_session(), there is an rcu_dereference() that looks to
> leak the returned pointer out of an RCU read-side critical section.
> If the pointed-to object might have just now been created, this is a
> bug because xprt_destroy_backchannel() dereferences this pointer.
> 
> So, does xprt_destroy_backchannel() exclude creation-side code?  (If so,
> no bug -- but a comment might be good.)
> 
> 							Thanx, Paul
> 
> void nfs4_destroy_session(struct nfs4_session *session)
> {
> 	struct rpc_xprt *xprt;
> 	struct rpc_cred *cred;
> 
> 	cred = nfs4_get_clid_cred(session->clp);
> 	nfs4_proc_destroy_session(session, cred);
> 	if (cred)
> 		put_rpccred(cred);
> 
> 	rcu_read_lock();
> 	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
> 	rcu_read_unlock();
> 	dprintk("%s Destroy backchannel for xprt %p\n",
> 		__func__, xprt);
> 	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
> 	nfs4_destroy_session_slot_tables(session);
> 	kfree(session);
> }
> 

Hi Paul,

nfs4_destroy_session() is only called when we’re tearing down the struct nfs_client that owns the cl_rppcclient, and the associated cl_xprt, so the code above should be safe, despite being ugly.

Is there a better annotation for use in the above kind of situation?

Cheers,
  Trond

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

