Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388Ab1KNXxt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 18:53:49 -0500
Date: Mon, 14 Nov 2011 18:53:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint
 under NFSDDBG_PNFS
Message-ID: <20111114235347.GA4243@fieldses.org>
References: <4EB9F8D6.1080302@panasas.com>
 <20111109195510.GA2227@fieldses.org>
 <4EBBF605.9050403@panasas.com>
 <20111114230923.GA3718@fieldses.org>
 <4EC1A5CD.9040500@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC1A5CD.9040500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 14, 2011 at 03:35:41PM -0800, Boaz Harrosh wrote:
> On 11/14/2011 03:09 PM, J. Bruce Fields wrote:
> > On Thu, Nov 10, 2011 at 08:04:21AM -0800, Boaz Harrosh wrote:
> > 
> > You mean the overuse of the state lock, or something else?
> > 
> 
> Yes and the places that causes to unlock / lock because of
> recursion or bad lock ordering.

That's purely a pNFS problem, right?

--b.
