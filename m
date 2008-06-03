From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove signaling
 for shutdown
Date: Tue, 03 Jun 2008 13:27:56 +1000
Message-ID: <4844BA3C.3010605@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com>	<4833364A.4010803@melbourne.sgi.com>	<20080520214823.576ad7a7@tleilax.poochiereds.net>	<48339730.3060206@melbourne.sgi.com>	<20080530122517.4f18c48e@tleilax.poochiereds.net>	<48438A76.6000400@melbourne.sgi.com> <20080602064132.10c69c88@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:43225 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752522AbYFCDbk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 23:31:40 -0400
In-Reply-To: <20080602064132.10c69c88-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> On Mon, 02 Jun 2008 00:51:50 -0500
> Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:
>   
>
> I'm certainly no VM expert either, but where are you seeing the
> kmalloc + memset? The only definition I see is the inlined function
> in slab.h which is:
>
> static inline void *kzalloc(size_t size, gfp_t flags)
>
>   
Sorry, I was looking in the wrong tree (sles10 not tot).  Nevermind :-)

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

