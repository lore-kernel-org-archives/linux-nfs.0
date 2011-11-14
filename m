Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45121 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148Ab1KNXJZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 18:09:25 -0500
Date: Mon, 14 Nov 2011 18:09:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint
 under NFSDDBG_PNFS
Message-ID: <20111114230923.GA3718@fieldses.org>
References: <4EB9F8D6.1080302@panasas.com>
 <20111109195510.GA2227@fieldses.org>
 <4EBBF605.9050403@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EBBF605.9050403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 10, 2011 at 08:04:21AM -0800, Boaz Harrosh wrote:
> On 11/09/2011 11:55 AM, J. Bruce Fields wrote:
> > Hey now, nfs4pnfsd.c has enough problems of its own without being
> > accused of surliness.
> > 
> 
> Allow me to disagree! the nfs4pnfsd.c is a very nice pretty clean,
> well formatted and well implemented pNFS-Server implementation.
> Believe me I have seen a few other pNFS and Parallel servers
> implementation and this is surgery room clean compare to the other.
> (If you look at the point before pnfs-exp and spNFS patches)

OK, I hope so!  And we *are* getting closer to finishing off the last of
the 4.1 stuff (though with just me it's not going to happen for 3.3.),
so I hope to be looking at that soon.

> The only real mess in there is the mess already inherited from nfsd,
> like the great and grate messy locking.

You mean the overuse of the state lock, or something else?

--b.

> Though it's better then the rest of the NFSD code.
