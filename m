From: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 06/19] Use get_random_bytes() to create confounder
Date: Wed, 12 Mar 2008 12:50:38 -0500
Message-ID: <1205344238.11354.59.camel@calx>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
	 <20080221184417.19195.55123.stgit@jazz.citi.umich.edu>
	 <20080312164616.GF10015@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:50648 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbYCLRum (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 13:50:42 -0400
In-Reply-To: <20080312164616.GF10015@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-12 at 12:46 -0400, J. Bruce Fields wrote:
> On Thu, Feb 21, 2008 at 01:44:17PM -0500, Kevin Coffman wrote:
> > Instead of using an incementing value for the confounder, use
> > get_random_bytes() which gives us the desired unpredictable value.
> 
> OK, admittedly I was probably nuts to substitute a predictable number
> for a random number in any cryptographic protocol, even if I was pretty
> sure it didn't matter in our case--so thanks for doing this.
> 
> But my impression is that other callers of this function are using it on
> a per-connection basis instead of (as in our case) a per-rpc basis.  Is
> there any problem with calling it that frequently?  Is it fast enough?
> Will it deplete some common entropy pool?

get_random_bytes is in the many megabytes/second range, so it's fast
enough for most things, but considered too slow for per-socket use
(which means the comment above it is quite stale!). If per-rpc means
once per every stat over NFS, then definitely too expensive. It draws
from the non-blocking pool, so no worries about entropy depletion.

Take a look at lib/random32.c for a moderately stong and fast PRND.
Reseeding that periodically with get_random_bytes might be sufficient.
Or look at secure_tcp_sequence_number in random.c for a more ad-hoc
approach.

-- 
Mathematics is the supreme nostalgia of our time.

