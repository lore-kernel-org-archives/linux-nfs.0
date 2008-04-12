From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NFS: prevent remounts on shared superblocks
Date: Sat, 12 Apr 2008 14:24:33 -0400
Message-ID: <20080412142433.7cec47ef@tleilax.poochiereds.net>
References: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
	<1208010798-22782-2-git-send-email-jlayton@redhat.com>
	<20080412104250.1e574c9f@tleilax.poochiereds.net>
	<1208017148.8669.39.camel@heimdal.trondhjem.org>
	<20080412140902.6a3c1725@tleilax.poochiereds.net>
	<1208024087.8669.65.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967AbYDLSYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Apr 2008 14:24:41 -0400
In-Reply-To: <1208024087.8669.65.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 12 Apr 2008 14:14:47 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Sat, 2008-04-12 at 14:09 -0400, Jeff Layton wrote:
> 
> > So how do we tell if a superblock is shared? Is that even possible?
> 
> Aside from the heuristic hint that sb->s_count offers, I don't see how
> we can tell.
> 
> >  If not, should we just not worry about this and hope for the best?
> 
> That may be the best option. If it is important to people to be able to
> change parameters on the fly without disrupting other mountpoints, then
> there is always the possibility of mounting with the 'nosharecache'
> option.
> 

Ok, then I think my original patch should be sufficient as a fix
for remounts not returning error even though they don't apply the new
options.

BTW: is -EINVAL the correct error for this?

Peter is probably correct that we should also consider allowing at
least some options to be changed on remount, but I think that would be
best addressed by follow-up patches.

Thanks for the review so far...
-- 
Jeff Layton <jlayton@redhat.com>
