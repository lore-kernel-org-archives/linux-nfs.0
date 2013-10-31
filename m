Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:51911 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab3JaQHU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 12:07:20 -0400
Message-ID: <5272802B.2030008@netapp.com>
Date: Thu, 31 Oct 2013 12:07:07 -0400
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

Yeah, I've been using it to test this.  I'm having trouble getting the last few parts of both test 11 and 12 to pass, which is better than what's happening now!

Anna
