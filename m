From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Date: Thu, 22 Jul 2010 13:40:26 -0400
Message-ID: <20100722134026.62091dc2@barsoom.rdu.redhat.com>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
	<20100721201437.GD28123@fieldses.org>
	<20100721232432.GA6689@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758927Ab0GVRke (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:40:34 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Jul 2010 19:24:32 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jul 21, 2010 at 04:14:37PM -0400, J. Bruce Fields wrote:
> > (Incremental on top of your last patch, with some noise due to moving
> > stuff around to avoid forward references.  I'll clean these up and
> > resend.)
> > 
> > Then we could also get rid of some of the individual flags (nfs4_init at
> > least), I think.
> 
> Here's what I'm thinking of applying.  (Lightly tested.)
> 

I gave them some basic smoke testing and looked them over and they seem
to be ok. Unfortunately, I don't really have an exhaustive test for
this sort of thing, but it does seem to fix the problem that
was originally reported to me.

-- 
Jeff Layton <jlayton@redhat.com>
