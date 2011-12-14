Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33440 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757877Ab1LNW1a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 17:27:30 -0500
Date: Wed, 14 Dec 2011 17:27:23 -0500
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111214222723.GD7623@fieldses.org>
References: <4EE8F75F.6070800@gmail.com>
 <20111214192739.GN2203@ZenIV.linux.org.uk>
 <4EE8FC2E.3010207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE8FC2E.3010207@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 02:42:38PM -0500, Ric Wheeler wrote:
> On 12/14/2011 02:27 PM, Al Viro wrote:
> >On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
> >
> >>We had an active thread a couple of years back that came out of the
> >>reflink work and, at the time, there seemed to be moderately
> >>positive support for adding a new system call that would fit this
> >>use case (Joel Becker's copyfile()).
> >>
> >>Can we resurrect this effort? Is copyfile() still a good way to go,
> >>or should we look at other hooks?
> >copyfile(2) is probably a good way to go, provided that we do _not_
> >go baroque as it had happened the last time syscall had been discussed.
> >
> >IOW, to hell with progress reports, etc. - just a fastpath kind of
> >thing, in the same kind of relationship to cp(1) as rename(2) is to mv(1).
> >If it works - fine, if not - caller has to be ready to deal with handling
> >cross-device case anyway.
> 
> I think that this approach makes a lot of sense. Most of the
> devices/targets that support the copy offload, will do it in very
> reasonable amounts of time.

The current NFSv4.2 draft rolls both the "fast" and "slow" cases into
one operation:

	http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-06#section-2
 
Perhaps we should ask for separate operations for the two cases.  (Or at
least a "please don't bother if this is going to take 8 hours" flag....)

--b.

> 
> Let me see if I can dig up some of the presentations from the NetApp
> guys who presented overviews or the specifications from the IETF and
> T10....
> 
> Ric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
