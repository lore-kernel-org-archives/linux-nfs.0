Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbaEGU3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 16:29:32 -0400
Date: Wed, 7 May 2014 16:29:32 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/70] NFSd lock scalability patches
Message-ID: <20140507202932.GD9710@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <20140419205815.GA1094@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140419205815.GA1094@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 19, 2014 at 04:58:15PM -0400, Bruce Fields wrote:
> On Fri, Apr 18, 2014 at 02:43:54PM -0400, Trond Myklebust wrote:
> > In accordance with the traditional Good Friday theme of "suffering", here
> > is the first draft of the NFSd lock scalability patches for your perusal.
> > I've only done light testing so far, but since there is a total of 70
> > patches to review, I figured you might want to start sooner rather than
> > waiting for the QA folks to finish testing.
> 
> Thanks!
> 
> Yeah, this sounds like too much suffering for vacation time, but I'll at
> least make a stab at merging the initial bug fixes next week, then try
> to plow through these (or any revised version (thanks, Christoph, for
> help reviewing!)) after I get back in a couple more weeks.

I've at least skimmed through them all, and that's all the suffering I
can handle for now.  I'm assuming you'll send a new version soon.

I'm applying a few of these to my for-3.16 branch, could you rebase
future versions to that to avoid resending already-reviewed patches?

How are you testing?

Thanks again for taking on this difficult and long-overdue project....

--b.
