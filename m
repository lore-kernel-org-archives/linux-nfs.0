Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755713Ab1KDRcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 13:32:36 -0400
Date: Fri, 4 Nov 2011 13:32:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: when attempting to open a directory, fall back
 on normal lookup (try #4)
Message-ID: <20111104133230.26f79122@tlielax.poochiereds.net>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9337@SACMVEXC2-PRD.hq.netapp.com>
References: <1320413608-17032-1-git-send-email-jlayton@redhat.com>
	<1320413608-17032-2-git-send-email-jlayton@redhat.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9337@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 4 Nov 2011 10:04:52 -0700
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> 
> Just one last request: can you reverse the order of the patches so that
> this one becomes 1/2? That would lose the dependency on the first patch,
> making the 'Cc: stable' bit more palatable.
> 
> BTW: it is now 'stable@vger.kernel.org'...
> 
> Also note that I'm quite ready to send these 2 patches as a post-rc1
> bugfix. Doing so shouldn't be a problem for Linus, since this is a
> regression w.r.t. older NFSv4 behaviour.
> 

Good point on the reordering...

Resent and the Cc: stable line is now fixed.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
