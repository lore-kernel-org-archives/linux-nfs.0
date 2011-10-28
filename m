Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40789 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369Ab1J1Omz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 10:42:55 -0400
Date: Fri, 28 Oct 2011 10:42:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
Message-ID: <20111028144252.GB5798@fieldses.org>
References: <20111025121924.GA15662@fieldses.org>
 <4EA77B78.6080706@panasas.com>
 <20111027203412.GB31669@fieldses.org>
 <4EA9F5E8.6060900@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EA9F5E8.6060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 27, 2011 at 05:23:04PM -0700, Boaz Harrosh wrote:
> On 10/27/2011 01:34 PM, J. Bruce Fields wrote:
> > We need to test it, but I think you're probably correct,
> > 6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to end
> > nfsd4 grace period" should have been tagged for stable.  Does that also
> > require any previous patches? (E.g.
> > 48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir
> > setting"?)
> > 
> 
> right, and all for that dmesg print. But yes! 
> 
> Well the 3.1 Kernel without them gets stuck. I guess you need to experiment
> with what would be the minimal patchset needed for 3.1 .
> 
> Tell me if you need help testing that the damage has gone. But basically I have
> a script (4 years old) that does: 
> 	server: service nfs stop/start 
> 	client: mount
> back to back, The client gets stuck forever.

You and I are pretty sure those patches are needed, and fix the problem.
But it would probably be a good idea, to make sure.

Would you mind passing both along to stable@kernel.org?  Cc: me and I'll
ack them.

--b.
