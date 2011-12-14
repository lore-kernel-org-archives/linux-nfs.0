Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:53025 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab1LNT1n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 14:27:43 -0500
Date: Wed, 14 Dec 2011 19:27:39 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111214192739.GN2203@ZenIV.linux.org.uk>
References: <4EE8F75F.6070800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE8F75F.6070800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:

> We had an active thread a couple of years back that came out of the
> reflink work and, at the time, there seemed to be moderately
> positive support for adding a new system call that would fit this
> use case (Joel Becker's copyfile()).
> 
> Can we resurrect this effort? Is copyfile() still a good way to go,
> or should we look at other hooks?

copyfile(2) is probably a good way to go, provided that we do _not_
go baroque as it had happened the last time syscall had been discussed.

IOW, to hell with progress reports, etc. - just a fastpath kind of
thing, in the same kind of relationship to cp(1) as rename(2) is to mv(1).
If it works - fine, if not - caller has to be ready to deal with handling
cross-device case anyway.
