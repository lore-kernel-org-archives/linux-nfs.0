Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45773 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621Ab1JZDQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 23:16:24 -0400
Message-ID: <4EA77B78.6080706@panasas.com>
Date: Tue, 25 Oct 2011 20:16:08 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: nfsd (and lock) changes for 3.2
References: <20111025121924.GA15662@fieldses.org>
In-Reply-To: <20111025121924.GA15662@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/25/2011 05:19 AM, J. Bruce Fields wrote:
> Changes for nfsd (and also a few file-locking changes) are available in
> the git repository at:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-3.2
> 
> This is the same tree I've always used--I assume you believe it's mine
> without a need for signing anything.  Feel free to tell me otherwise.
> 

<Snip>

> 
> Boaz Harrosh (1):
>       nfsd4: fix failure to end nfsd4 grace period
> 

Bruce hi.

As I recall this failure I have experienced in early stages of the
3.1-rcX series. I admit that I always run with Benny's pnfs tree,
but I do not think it is patches that Benny added from the 3.2 set
I think it is breakage introduced by the 3.1 merge window.

Therefor I think that this patch must be sent to Stable@ otherwise
surly 3.1 Kernel users are to hit it. (You can escapee it)

Though it has been pulled to Linus tree, without the CC: stable@kernel
I think you can just send the patch to <stable@kernel.org> and it
will be included.

(What other 3.1 bug fixes are missing)

Thanks
Boaz
