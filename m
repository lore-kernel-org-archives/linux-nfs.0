Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43731 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933040Ab1KDRp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 13:45:59 -0400
Date: Fri, 4 Nov 2011 13:45:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: stable@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
Message-ID: <20111104174556.GA721@fieldses.org>
References: <20111025121924.GA15662@fieldses.org>
 <4EA77B78.6080706@panasas.com>
 <20111027203412.GB31669@fieldses.org>
 <4EA9F5E8.6060900@panasas.com>
 <20111028144252.GB5798@fieldses.org>
 <20111104160439.GA32756@fieldses.org>
 <4EB417C8.4000502@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EB417C8.4000502@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 04, 2011 at 09:50:16AM -0700, Boaz Harrosh wrote:
> On 11/04/2011 09:04 AM, J. Bruce Fields wrote:
> > Boaz points out that I forgot to add stable cc's to two commits:
> > 
> > 	48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir setting"
> > 	6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to
> > 	end nfsd4 grace period"
> > 
> > which fix a regression introduced by
> > ab1350b2b3c1dd2e465a6abdda608d8c44facfb8 "nfsd41: Deny new lock before
> > RECLAIM_COMPLETE done" (first included in v3.1-rc1).
> > 
> > Included below for reference, but I assume simplest for you will be to
> > cherry-pick the above two sha1's.
> > 
> > Thanks!
> > 
> > --b.
> > 
> 
> Bruce hi, thanks
> 
> Yesterday I hit this bug again. I rebased on Benny's tree which did not have them
> for some reason. It's hunting me. ;-)
> 
> Just for Future reference, these patches were suppose to be submitted very early around
> rc3 when we found them. This is what the -rcX are for, to test and fix what was broken
> in the merge window.
> 
> Please forgive me I should have followed it through, but was too busy and forgot.
> 
> But in general you should always have an rc-fixes branch and bug fixes patches
> should go there

More specifically (and especially later in the -rc's) Linus has ask that
we raise the bar somewhat above just "bug fixes"--but yes, this was a
regression with a pretty simple fix, so I should have gotten it in.

> and not into the linux-next branch. And yes both branches should
> be included in linux-next.

Agreed.  Feel free to yell when you see something I missed.  I'm feeling
spread a little thin....

--b.
