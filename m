Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916Ab3JaQRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 12:17:41 -0400
Message-ID: <5272829A.90105@netapp.com>
Date: Thu, 31 Oct 2013 12:17:30 -0400
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-5-git-send-email-bjschuma@netapp.com> <20131031160440.GA30108@infradead.org>
In-Reply-To: <20131031160440.GA30108@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/31/2013 12:04 PM, Christoph Hellwig wrote:
> Btw, I just noticed that current nfs mainline fails xfstests 286 which
> test SEEK_DATA/SEEK_HOLE.   That sounds like a useful test case for your
> patches.
> 

I read too quickly.  I've been using 285 to test against, but I'll see what 286 gets me!  Thanks for the tip :)
