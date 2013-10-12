Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59914 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3JLImm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Oct 2013 04:42:42 -0400
Date: Sat, 12 Oct 2013 01:42:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Message-ID: <20131012084235.GB5649@infradead.org>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
 <1378579561-26868-5-git-send-email-bfields@redhat.com>
 <20130909004647.GK13318@ZenIV.linux.org.uk>
 <20130909204655.GA10599@fieldses.org>
 <20131011160237.GA21258@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131011160237.GA21258@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 11, 2013 at 12:02:37PM -0400, J. Bruce Fields wrote:
> But just for fun--I did some cleanup and fixed some other quadratic
> behavior here and can notice a difference on lookups of very deep
> subdirectories.
> 
> For example I'm seeing an uncached lookup of an 8000-deep directory
> taking about 6 seconds, and can get that down to a tenth of a second.
> 
> I'm not sure yet if the difference on less extreme examples is really
> significant, I need to experiment some more.
> 
> I'll do some more review and post patches and results.

This sounds like and awesome improvement.  How much code do you have to
add for it?

