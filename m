From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] NFS: prevent remounts on shared superblocks
Date: Sat, 12 Apr 2008 14:14:47 -0400
Message-ID: <1208024087.8669.65.camel@heimdal.trondhjem.org>
References: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
	 <1208010798-22782-2-git-send-email-jlayton@redhat.com>
	 <20080412104250.1e574c9f@tleilax.poochiereds.net>
	 <1208017148.8669.39.camel@heimdal.trondhjem.org>
	 <20080412140902.6a3c1725@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46623 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967AbYDLSOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Apr 2008 14:14:51 -0400
In-Reply-To: <20080412140902.6a3c1725-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sat, 2008-04-12 at 14:09 -0400, Jeff Layton wrote:

> So how do we tell if a superblock is shared? Is that even possible?

Aside from the heuristic hint that sb->s_count offers, I don't see how
we can tell.

>  If not, should we just not worry about this and hope for the best?

That may be the best option. If it is important to people to be able to
change parameters on the fly without disrupting other mountpoints, then
there is always the possibility of mounting with the 'nosharecache'
option.

Cheers
  Trond

