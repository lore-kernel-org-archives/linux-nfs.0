From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove
 signaling for shutdown
Date: Tue, 20 May 2008 21:48:23 -0400
Message-ID: <20080520214823.576ad7a7@tleilax.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<4833364A.4010803@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479AbYEUBsa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 21:48:30 -0400
In-Reply-To: <4833364A.4010803-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 May 2008 13:36:26 -0700
Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:

> Greg Banks wrote:
> > [...]
> > I'll send out the patch I mentioned when we
> > chatted at Cthon, maybe you can consider the issue it fixes.
> >
> >   
> Here's the patch.  You probably don't want to do it the same way, but
> the intent is to delay the allocation of the svc_rqst structure until
> the nfsd is running on the correct cpu so that the allocation comes from
> the correct local memory on NUMA systems.  Absent the patch, most of the
> nfsds spend a lot of time updating remote memory allocated on node0.
> 

Thanks Greg. I'll make sure I incorporate a similar fix in the next
iteration of the patch. Rather than delaying the allocation like this,
I wonder if we can just figure out the node from the cpumask and then
do a kmalloc_node()?

-- 
Jeff Layton <jlayton@redhat.com>
