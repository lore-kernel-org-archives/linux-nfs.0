From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and	remove signaling
 for shutdown
Date: Mon, 02 Jun 2008 00:51:50 -0500
Message-ID: <48438A76.6000400@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com>	<4833364A.4010803@melbourne.sgi.com>	<20080520214823.576ad7a7@tleilax.poochiereds.net>	<48339730.3060206@melbourne.sgi.com> <20080530122517.4f18c48e@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:53561 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752103AbYFBFz2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2008 01:55:28 -0400
In-Reply-To: <20080530122517.4f18c48e-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
>
> I started to do this patch as part of the kthread conversion, but it's
> actually pretty independent. We can probably treat it separately.
> This hasn't been tested on an actual NUMA machine yet, but any thoughts
> on the following patch?
> [...]
>  
> -	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
> +	rqstp = kmalloc_node(sizeof(*rqstp), GFP_KERNEL | __GFP_ZERO, node);
>  	if (!rqstp)
>  		goto out_enomem;
>   
I'm not an expert, but from looking at the slab code I don't think
__GFP_ZERO works the way you're expecting on the kmalloc() family, only
on the alloc_pages() family.  In particular it's not used when the
object is allocated on the slab fastpath.   kzalloc() seems to be a
kmalloc() followed by a memset().  Perhaps you'd be better off either
adding a kzalloc_node() or doing kmalloc_node() plus memset().

Apart from that and Bruce's comment the patch looks like it would work.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

