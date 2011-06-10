Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11653 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab1FJCQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 22:16:45 -0400
Message-ID: <4DF17E86.3060701@panasas.com>
Date: Thu, 09 Jun 2011 19:16:38 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 00/88] pnfs block layout driver
References: <cover.1307464381.git.rees@umich.edu> <4DF140AF.20208@panasas.com> <20110609221528.GB28760@merit.edu>
In-Reply-To: <20110609221528.GB28760@merit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 03:15 PM, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   Who is going to SQUASH all the SQUASHMEs and re think the all patch
>   separation again. To something that makes a more logical progression
>   and easier on the review. The way it is now I'm not able to review,
>   sorry, I got lost trying to understand which is which.
> 
> I'm open to suggestions and happy to do the work.  I agree that 88 patches
> is nearly indigestable.  However I note that Benny seems to have pulled in
> the entire set so I'm not sure how to proceed at this point.  Also this code
> was in Benny's 2.6.38 and only got dropped when the 3.0 merge came along, so
> most of it's already been under review for a year or more.

Lets start by squashing all the SQUASHMEs into their proper place, that will
get you down to 49. You might notice that it could get hard and it will be
easier to actually take the complete code and re-divide it to patches, a fresh.
crafted more less on the old division strategy.

It's what Fred did at the final files submission. And it is what I did more
or less with the objects final submission. But you might find that for you
it is easier to rebase and squash the patches together after you re-order
them. It's your call and you will not know before you experiment a little.
I can show you some techniques I use on both these paths.
(Let's meet in B next week)

Then you should do a second pass to see that each patch is compile-able and
makes sense and maybe also reorder the introduction of the generic parts
close to where they are used in the pachset progression. Again like we did
for files and objects.

Thanks
Boaz
