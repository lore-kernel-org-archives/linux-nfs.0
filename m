From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4] NLM: fix lockd hang when client blocking on
	released lock isn't responding
Date: Thu, 7 Feb 2008 16:05:33 -0500
Message-ID: <20080207210533.GG10958@fieldses.org>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:50549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763033AbYBGVFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:05:37 -0500
In-Reply-To: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 11:34:09AM -0500, Jeff Layton wrote:
> This patchset fixes the problem that Bruce pointed out last week when
> we were discussing the lockd-kthread patches.
> 
> The main problem is described in patch #1 and that patch also fixes the
> DoS. The remaining patches clean up how GRANT_MSG callbacks handle an
> unresponsive client. The goal in those is to make sure that we don't
> end up with a ton of duplicate RPC's in queue and that we try to handle
> an invalidated block correctly.
> 
> Bruce, I'd like to see this fixed in 2.6.25 if at all possible.
> 
> Comments and suggestions are appreciated.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

I gave them another quick skim, compiled, and did a connectathon run.
(As always, I need better regression testing.)  But I'll submit those
tommorow assuming no one finds a problem.

--b.
