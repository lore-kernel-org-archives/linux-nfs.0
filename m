Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbaHMPvd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 11:51:33 -0400
Date: Wed, 13 Aug 2014 11:51:31 -0400
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] locks: move most locks_release_private calls outside
 of i_lock
Message-ID: <20140813155131.GA5169@fieldses.org>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
 <20140813082827.1097c3ad@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140813082827.1097c3ad@canb.auug.org.au>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 13, 2014 at 08:28:27AM +1000, Stephen Rothwell wrote:
> This s reinforced by the lack of Acked-by, Reviewed-by and Tested-by
> tags ... (the addition of which would presumably require the rebase
> (or rewrite) of a published git tree.)

By the way, I reshuffled my branches recently so the one you pull has
incoming patches that I think are mature enough to be worth testing but
haven't finished review yet.

That was partly Jeff's request, as he wanted his patches to get some
exposure while waiting for review.

It also means I can fold in some minor fixes instead of piling up fixes
for nits found by the kbuild robot.  (But maybe that unfairly denies it
some credit, I don't know.)

Anyway that means that branch is getting rewritten, say, weekly, as
opposed to never (or maybe for once-in-a-year level screwups).

Am I doing it wrong?

--b.
