Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35200 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab1FJEEW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 00:04:22 -0400
Received: by qwk3 with SMTP id 3so1045251qwk.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 21:04:22 -0700 (PDT)
Message-ID: <4DF197C3.7070907@panasas.com>
Date: Fri, 10 Jun 2011 00:04:19 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 00/88] pnfs block layout driver
References: <cover.1307464381.git.rees@umich.edu> <4DF140AF.20208@panasas.com> <20110609221528.GB28760@merit.edu>
In-Reply-To: <20110609221528.GB28760@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 18:15, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   Who is going to SQUASH all the SQUASHMEs and re think the all patch
>   separation again. To something that makes a more logical progression
>   and easier on the review. The way it is now I'm not able to review,
>   sorry, I got lost trying to understand which is which.
> 
> I'm open to suggestions and happy to do the work.  I agree that 88 patches

Thanks!

> is nearly indigestable.  However I note that Benny seems to have pulled in
> the entire set so I'm not sure how to proceed at this point.  Also this code patch

For 2.6.39 it is what it is but for 3.[01] we should clean up the patchset and I'll
rebase it into the tree again.  When it's ready for final review and submission we'll
have a for-3.1 branch based off of Trond's respective branch with all the queued
patches.

> was in Benny's 2.6.38 and only got dropped when the 3.0 merge came along, so
> most of it's already been under review for a year or more.

Ehhhhh, we need to re-review it for submission taking into account
the major changes that went into 2.6.39 and 3.0...

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
