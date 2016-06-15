Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58202 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867AbcFOUzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 16:55:43 -0400
Date: Wed, 15 Jun 2016 16:55:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, tibbs@math.uh.edu
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
Message-ID: <20160615205542.GG3848@fieldses.org>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
 <20160615192116.GA3848@fieldses.org>
 <20160615192415.GB3848@fieldses.org>
 <m2d1niw6pl.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2d1niw6pl.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 04:13:58PM -0400, Andrew W Elble wrote:
> 
> > (Also: remind me what they symptoms ("lost delegation problems")
> > actually were from the point of view of users?  Does the client end up
> > resending failing DELEGRETURNS and failing to make progress?)
> 
> Client endlessly loops in state recovery with no path to recovery.
> I'm guessing Jason is seeing some of this as well.

OK.  Just added a note at the end of the changelog saying "Without this,
Linux clients with credentials that expired while holding
delegations were getting stuck in an endless loop."--in hopes that might
help somebody recognize their problem.

--b.
