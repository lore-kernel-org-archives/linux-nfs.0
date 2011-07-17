Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52914 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab1GQO6Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 10:58:16 -0400
Received: by wwe5 with SMTP id 5so2509334wwe.1
        for <linux-nfs@vger.kernel.org>; Sun, 17 Jul 2011 07:58:15 -0700 (PDT)
Message-ID: <4E22F880.9070005@tonian.com>
Date: Sun, 17 Jul 2011 17:58:08 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: block layout patches
References: <20110714165004.GA2607@merit.edu> <20110714165348.GA13287@infradead.org> <20110714170924.GC2607@merit.edu> <4E1F3630.1090708@tonian.com> <20110715152201.GB8142@merit.edu>
In-Reply-To: <20110715152201.GB8142@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-15 18:22, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   I've pulled (rebased actually) your for-trond branch into my tree.
>   The new tip is at pnfs-all-3.0-rc7-2011-07-14
> 
> I have pushed out yet another patch set, this time based on Trond's new
> (since yesterday) IO code.  On the for-trond branch.
> 
> Again, this is a pull request for Benny, not Trond.  Maybe I should rename
> the branch.

Thanks, I pulled in Trond's for-next branch and linux-pnfs-blk/for-trond.
I also updated panlayout pgio vectors.
This was pushed out under pnfs-all-3.0-rc7-2011-07-17

Benny

