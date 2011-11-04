Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46391 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932807Ab1KDQ5R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 12:57:17 -0400
Message-ID: <4EB417C8.4000502@panasas.com>
Date: Fri, 4 Nov 2011 09:50:16 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <stable@kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: nfsd (and lock) changes for 3.2
References: <20111025121924.GA15662@fieldses.org> <4EA77B78.6080706@panasas.com> <20111027203412.GB31669@fieldses.org> <4EA9F5E8.6060900@panasas.com> <20111028144252.GB5798@fieldses.org> <20111104160439.GA32756@fieldses.org>
In-Reply-To: <20111104160439.GA32756@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/04/2011 09:04 AM, J. Bruce Fields wrote:
> Boaz points out that I forgot to add stable cc's to two commits:
> 
> 	48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir setting"
> 	6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to
> 	end nfsd4 grace period"
> 
> which fix a regression introduced by
> ab1350b2b3c1dd2e465a6abdda608d8c44facfb8 "nfsd41: Deny new lock before
> RECLAIM_COMPLETE done" (first included in v3.1-rc1).
> 
> Included below for reference, but I assume simplest for you will be to
> cherry-pick the above two sha1's.
> 
> Thanks!
> 
> --b.
> 

Bruce hi, thanks

Yesterday I hit this bug again. I rebased on Benny's tree which did not have them
for some reason. It's hunting me. ;-)

Just for Future reference, these patches were suppose to be submitted very early around
rc3 when we found them. This is what the -rcX are for, to test and fix what was broken
in the merge window.

Please forgive me I should have followed it through, but was too busy and forgot.

But in general you should always have an rc-fixes branch and bug fixes patches
should go there and not into the linux-next branch. And yes both branches should
be included in linux-next.

This way there is nothing to forget

Thanks
Boaz
