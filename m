Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723Ab3L0SnM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Dec 2013 13:43:12 -0500
Date: Fri, 27 Dec 2013 13:43:09 -0500
From: "J.;Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question ref Running NFS at V4 Only
Message-ID: <20131227184309.GA9161@fieldses.org>
References: <52B47A12.2070202@garethwilliams.me.uk>
 <20131223173956.GA9221@fieldses.org>
 <52BD53CA.5050205@gmail.com>
 <7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 27, 2013 at 11:05:05AM -0500, Chuck Lever wrote:
> Hi-
> 
> On Dec 27, 2013, at 5:17 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > On 12/24/2013 01:39 AM, J. Bruce Fields wrote:
> >> On Fri, Dec 20, 2013 at 05:10:42PM +0000, Gareth Williams wrote:
> >>> Hi,
> >>> 
> >>> I'm trying to run NFS with protocol version 4 only (that is, with v2
> >>> & v3 disabled) on a CentOS 6.5 install running as a KVM guest.
> >>> 
> >>> The RedHat documentation (amongst others) states that rpcbind isn't
> >>> needed with v4, but if I start nfs without rpcbind I get errors.
> >> 
> >> I suspect the kernel code needs to be fixed to not attempt to register
> >> with rpcbind n the v4-only case.  (Or to attempt to register but ignore
> >> any error, I'm not sure which is best.)
> >> 
> >> And this may not be the only issue in the v4-only case.  This isn't
> >> really a priority for me right now, but I'd happily look at patches.
> > 
> > Hi all,
> > 
> > I make a patch for this problem, please have a check, thanks.
> > 
> > From 64c1f96348213f39b9411ab25699a292edbef4ef Mon Sep 17 00:00:00 2001
> > From: Kinglong Mee <kinglongmee@gmail.com>
> > Date: Fri, 27 Dec 2013 18:06:25 +0800
> > Subject: [PATCH] NFSD: supports nfsv4 service without rpcbind
> > 
> > 1. set vs_hidden in nfsd_version4 to avoid register nfsv4 to rpcbind
> 
> IMO we do want the NFS port registered if rpcbind is running.  NFSv4 is not a hidden service, like the client's callback server which can only be discovered by a forward advertisement (SETCLIENTID).
> 
> I think I prefer ignoring the rpcb_set error for NFSv4.

Agreed.  My only concern would be that there be no unnecessary delays or
errors logged in the v4-only case if rpcbind isn't running.

--b.

> 
> 
> > 2. don't start lockd when only supports nfsv4.
> > 
> > Reported-by: Gareth Williams <gareth@garethwilliams.me.uk>
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> > fs/nfsd/netns.h    |  3 +++
> > fs/nfsd/nfs4proc.c |  1 +
> > fs/nfsd/nfsctl.c   |  3 +++
> > fs/nfsd/nfssvc.c   | 21 ++++++++++++++++-----
> > 4 files changed, 23 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> > index 849a7c3..ae2c179 100644
> > --- a/fs/nfsd/netns.h
> > +++ b/fs/nfsd/netns.h
> > @@ -96,6 +96,9 @@ struct nfsd_net {
> > 
> > 	bool nfsd_net_up;
> > 
> > +	bool lockd_up;
> > +	u32 nfsd_needs_lockd;
> > +
> > 	/*
> > 	 * Time of server startup
> > 	 */
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 419572f..1496376 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1881,6 +1881,7 @@ struct svc_version	nfsd_version4 = {
> > 		.vs_proc	= nfsd_procedures4,
> > 		.vs_dispatch	= nfsd_dispatch,
> > 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
> > +		.vs_hidden	= 1,
> > };
> > 
> > /*
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 7f55517..8c7b0f0 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -575,6 +575,9 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
> > 			switch(num) {
> > 			case 2:
> > 			case 3:
> > +				nfsd_vers(num, sign == '-' ? NFSD_CLEAR : NFSD_SET);
> > +				nn->nfsd_needs_lockd = nfsd_vers(num, NFSD_TEST);
> > +				break;
> > 			case 4:
> > 				nfsd_vers(num, sign == '-' ? NFSD_CLEAR : NFSD_SET);
> > 				break;
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index 760c85a..2b841d8 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -255,9 +255,14 @@ static int nfsd_startup_net(int nrservs, struct net *net)
> > 	ret = nfsd_init_socks(net);
> > 	if (ret)
> > 		goto out_socks;
> > -	ret = lockd_up(net);
> > -	if (ret)
> > -		goto out_socks;
> > +
> > +	if (nn->nfsd_needs_lockd && !nn->lockd_up) {
> > +		ret = lockd_up(net);
> > +		if (ret)
> > +			goto out_socks;
> > +		nn->lockd_up = 1;
> > +	}
> > +
> > 	ret = nfs4_state_start_net(net);
> > 	if (ret)
> > 		goto out_lockd;
> > @@ -266,7 +271,10 @@ static int nfsd_startup_net(int nrservs, struct net *net)
> > 	return 0;
> > 
> > out_lockd:
> > -	lockd_down(net);
> > +	if (nn->lockd_up) {
> > +		lockd_down(net);
> > +		nn->lockd_up = 0;
> > +	}
> > out_socks:
> > 	nfsd_shutdown_generic();
> > 	return ret;
> > @@ -277,7 +285,10 @@ static void nfsd_shutdown_net(struct net *net)
> > 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > 
> > 	nfs4_state_shutdown_net(net);
> > -	lockd_down(net);
> > +	if (nn->lockd_up) {
> > +		lockd_down(net);
> > +		nn->lockd_up = 0;
> > +	}
> > 	nn->nfsd_net_up = false;
> > 	nfsd_shutdown_generic();
> > }
> > -- 
> > 1.8.4.2
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
