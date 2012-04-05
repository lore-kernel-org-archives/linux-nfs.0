Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218Ab2DELjK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Apr 2012 07:39:10 -0400
Date: Thu, 5 Apr 2012 07:39:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 high availability setups
Message-ID: <20120405073901.63d1c749@tlielax.poochiereds.net>
In-Reply-To: <20120405103124.GV4752@ics.muni.cz>
References: <20120405103124.GV4752@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Apr 2012 12:31:24 +0200
Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:

> Hi,
> 
> we got several front-ends for a shared storage. We want to build HA setup so
> that failed front-end fails over to another front-end (that is serving NFSv4
> already). 
> 
> As I understand, NFS4 uses state dir somewhere in /var/lib/nfs/rpc_pipefs.
> 

You're probably thinking of /var/lib/nfs/v4recovery.

> Can we put this state dir on a shared volume so that this state dir is common
> for all the front-ends serving the same content? Is is supposed to work and
> NFSv4 can merge its state with existing state on a shared disk?
> 

Not properly, no. nfsd expects to have complete control over that
directory. There's no locking or merging of the data there. A node will
also clean that directory out in some cases, and that will throw your
state tracking off.

3.4 just got an overhaul of this code to use an upcall instead. At this
point I'm waiting on Steve to merge the userspace portion of that. The
legacy client tracking code will probably never be cluster-aware.

This is actually a very complex problem to solve as you need to
coordinate the grace periods between the different serving cluster
nodes.

I've been looking at this problem for the last few months, and am still
working out a design that would allow active/active NFSv4 serving. For
now, I'd advise against trying it since it won't work properly.

If you want to follow along with the gory details of the design, I've
been sporadically doing blog posts about it here:

    http://jtlayton.wordpress.com/

-- 
Jeff Layton <jlayton@redhat.com>
