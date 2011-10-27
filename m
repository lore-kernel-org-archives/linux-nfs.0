Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46493 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516Ab1J0UeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 16:34:15 -0400
Date: Thu, 27 Oct 2011 16:34:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
Message-ID: <20111027203412.GB31669@fieldses.org>
References: <20111025121924.GA15662@fieldses.org>
 <4EA77B78.6080706@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EA77B78.6080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 25, 2011 at 08:16:08PM -0700, Boaz Harrosh wrote:
> On 10/25/2011 05:19 AM, J. Bruce Fields wrote:
> > Boaz Harrosh (1):
> >       nfsd4: fix failure to end nfsd4 grace period
> > 
> 
> Bruce hi.
> 
> As I recall this failure I have experienced in early stages of the
> 3.1-rcX series. I admit that I always run with Benny's pnfs tree,
> but I do not think it is patches that Benny added from the 3.2 set
> I think it is breakage introduced by the 3.1 merge window.
> 
> Therefor I think that this patch must be sent to Stable@ otherwise
> surly 3.1 Kernel users are to hit it. (You can escapee it)

We need to test it, but I think you're probably correct,
6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to end
nfsd4 grace period" should have been tagged for stable.  Does that also
require any previous patches? (E.g.
48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir
setting"?)

--b.
