Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:54208 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab1FIWPa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 18:15:30 -0400
Date: Thu, 9 Jun 2011 18:15:28 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 00/88] pnfs block layout driver
Message-ID: <20110609221528.GB28760@merit.edu>
References: <cover.1307464381.git.rees@umich.edu>
 <4DF140AF.20208@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DF140AF.20208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  Who is going to SQUASH all the SQUASHMEs and re think the all patch
  separation again. To something that makes a more logical progression
  and easier on the review. The way it is now I'm not able to review,
  sorry, I got lost trying to understand which is which.

I'm open to suggestions and happy to do the work.  I agree that 88 patches
is nearly indigestable.  However I note that Benny seems to have pulled in
the entire set so I'm not sure how to proceed at this point.  Also this code
was in Benny's 2.6.38 and only got dropped when the 3.0 merge came along, so
most of it's already been under review for a year or more.
