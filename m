From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: Return full WCC data for NFSv3 metadata
 operations
Date: Thu, 8 Jul 2010 16:10:23 -0400
Message-ID: <20100708201023.GC31173@fieldses.org>
References: <20100708154037.2820.51702.stgit@ellison.1015granger.net>
 <20100708195335.GB31173@fieldses.org>
 <4C362E13.4080509@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43151 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab0GHUKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 16:10:32 -0400
In-Reply-To: <4C362E13.4080509@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 08, 2010 at 03:59:15PM -0400, Chuck Lever wrote:
> On 07/ 8/10 03:53 PM, J. Bruce Fields wrote:
> >On Thu, Jul 08, 2010 at 11:43:46AM -0400, Chuck Lever wrote:
> >>
> >>This patch is mechanically the same as the previous one, but the patch
> >>description has a more accurate and clearly stated rationale for the
> >>change.
> >>
> >>Please use this one instead of the previous one.
> >
> >Thanks.  The first is already committed, though.
> 
> And you can't use "git reset --soft ..." to fix the commit message
> because....?

The public for-2.6.x branches only fast-forward.  I'd prefer to keep it
that way.

--b.
