From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 1/1] nfs: fix race between renewd, umount, and the
 state manager in V4.1
Date: Fri, 22 Jan 2010 14:41:38 -0500
Message-ID: <1264189298.30757.16.camel@localhost>
References: <1264135871-13083-1-git-send-email-batsakis@netapp.com>
	 <1264186039.30757.7.camel@localhost>
	 <B9364369CA66BF45806C2CD86EAB8BA604F35537@SACMVEXC3-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64524 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab0AVTlj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 14:41:39 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0MJfdbF019762
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 11:41:39 -0800 (PST)
In-Reply-To: <B9364369CA66BF45806C2CD86EAB8BA604F35537-hX7t0kiaRRqx3DEm5hsDiAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-22 at 11:30 -0800, Batsakis, Alexandros wrote: 
> 
> > -----Original Message-----
> > From: Myklebust, Trond
> > Sent: Friday, January 22, 2010 10:47 AM
> > To: Batsakis, Alexandros
> > Cc: linux-nfs@vger.kernel.org; Myklebust, Trond
> > Subject: Re: [PATCH 1/1] nfs: fix race between renewd, umount, and the
> > state manager in V4.1
> > 
> > On Thu, 2010-01-21 at 20:51 -0800, Alexandros Batsakis wrote:
> > 
> > > struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
> > > @@ -878,7 +888,11 @@ void nfs4_schedule_state_manager(struct
> > nfs_client *clp)
> > >  	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) !=
> > 0)
> > >  		return;
> > >  	__module_get(THIS_MODULE);
> > > -	atomic_inc(&clp->cl_count);
> > > +	if (!atomic_inc_not_zero(&clp->cl_count)) {
> > > +		nfs4_clear_state_manager_bit(clp);
> > > +		module_put(THIS_MODULE);
> > > +		return;
> > > +	}
> > 
> > The use of atomic_inc_not_zero() should not be necessary here. Anybody
> > who is calling this function without holding a reference to clp is
> > doing
> > something fundamentally wrong.
> 
> Agreed, but how can we enforce this (especially with asynchronous RPC) ?
> For example what will happen if _during_ umount (after nfs_put_client()), an NFS call that was sleeping e.g. waiting for the server to come up, reaches the server and the response causes the state manager to start ?
> Any ideas ?

What would you expect to see running during umount? Nobody can be
holding a reference to the vfsmount at that point, so there should be no
active processes around to make NFS calls.

Trond

