From: Neil Brown <neilb@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Thu, 4 Sep 2008 16:03:16 +1000
Message-ID: <18623.31268.970805.5694@notabene.brown>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
	<48B5332B.2040800@RedHat.com>
	<76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com>
	<EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com>
	<3400963b9465552abb83ecefede125bc.squirrel@neil.brown.name>
	<EB1B1F05-65DA-4A18-80F6-13DE4FCB387C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>, Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:53908 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbYIDGD1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 02:03:27 -0400
In-Reply-To: message from Chuck Lever on Tuesday September 2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday September 2, chuck.lever@oracle.com wrote:
> > Only NOTIFY can come from other hosts (to tell us they rebooted).
> 
> Right.  sm_notify_1_svc() grabs the callers IP address with
> 
>     svc_getcaller(rqstp->rq_xprt)->sin_addr
> 
> It converts this to a string and checks this against lp->dns_name, in  
> addition to checking the mon_name that was originally registered to be  
> monitored.  Shouldn't statd check only mon_name against dns_name?  Why  
> does it check both?

If it was to only check one, it would probably to check ip_addr
against dns_name.

The IP address of that the SM_NOTIFY came from is the most reliable
thing we have to identify which host just rebooted.  We use that to
find a 'dns_name' when we first MONitor a host, and use that name for
the file stored in /var/lib/nfs/sm.  We then match the source of
SM_NOTIFY against those file names.

So I think this part of the code really does need to be IPv6-aware.
Certainly matchhostname does.

> > However we don't really want any user to be able to request a callback
> > to any random service....
> > I wonder if anyone uses for statd for anything but lockd, and how
> > could we know?
> 
> I think the real question is whether we should continue to support  
> this "off-label" use.  It adds complexity and security problems, and  
> the code paths that support this aren't ever tested these days, I'm  
> willing to bet.

How about we subtly break it, and then we nobody complains for 12
months, remove it as it was broken anyway :-)

I'm think I'm happy with removing any support for non-lockd uses for
statd.

NeilBrown

