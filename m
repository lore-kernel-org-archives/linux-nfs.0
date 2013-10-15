Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55590 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933271Ab3JOT3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 15:29:36 -0400
Date: Tue, 15 Oct 2013 15:29:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Message-ID: <20131015192908.GB10128@fieldses.org>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
 <1378579561-26868-5-git-send-email-bfields@redhat.com>
 <20130909004647.GK13318@ZenIV.linux.org.uk>
 <20130909204655.GA10599@fieldses.org>
 <20131011160237.GA21258@fieldses.org>
 <20131012084235.GB5649@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131012084235.GB5649@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 12, 2013 at 01:42:35AM -0700, Christoph Hellwig wrote:
> On Fri, Oct 11, 2013 at 12:02:37PM -0400, J. Bruce Fields wrote:
> > But just for fun--I did some cleanup and fixed some other quadratic
> > behavior here and can notice a difference on lookups of very deep
> > subdirectories.
> > 
> > For example I'm seeing an uncached lookup of an 8000-deep directory
> > taking about 6 seconds, and can get that down to a tenth of a second.
> > 
> > I'm not sure yet if the difference on less extreme examples is really
> > significant, I need to experiment some more.
> > 
> > I'll do some more review and post patches and results.
> 
> This sounds like and awesome improvement.

Nobody should be nesting that deep, but maybe it's useful to have the
insurance against bad behavior anyway.

> How much code do you have to
> add for it?

 fs/exportfs/expfs.c | 224 ++++++++++++++++++++++++++--------------------------
 1 file changed, 112 insertions(+), 112 deletions(-)

But maybe I removed some necessary complication.  I'll post the
patches....

--b.
