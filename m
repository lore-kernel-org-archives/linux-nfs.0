From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove signaling
 for shutdown
Date: Tue, 20 May 2008 20:29:52 -0700
Message-ID: <48339730.3060206@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com>	<4833364A.4010803@melbourne.sgi.com> <20080520214823.576ad7a7@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:40232 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765490AbYEUDcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 23:32:23 -0400
In-Reply-To: <20080520214823.576ad7a7-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
>   
> [...] Rather than delaying the allocation like this,
> I wonder if we can just figure out the node from the cpumask and then
> do a kmalloc_node()?
>
>   
Sure.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

