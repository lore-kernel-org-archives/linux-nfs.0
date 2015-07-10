Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33601 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbbGJP5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 11:57:18 -0400
MIME-Version: 1.0
In-Reply-To: <20150710110255.66fc6452@tlielax.poochiereds.net>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
 <20150701093547.116dd788@tlielax.poochiereds.net> <CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
 <20150702060827.66fc27f1@tlielax.poochiereds.net> <20150710110255.66fc6452@tlielax.poochiereds.net>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 10 Jul 2015 17:56:57 +0200
Message-ID: <CAJ75kXb6FRN-DY+wtvUEi53pc=tqLjA12S1X5egc4eR5pBN_MA@mail.gmail.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jean Spector <jean@primarydata.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        stable@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 5:02 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> So, William has done some testing and hit some problems with this
> patch. I suspect that it's because we can end up running an unlock
> after the filp->f_count has already gone to zero and are in __fput, so
> we take an extra reference and end up with a use-after-free.
>
> I think it'd be best to revert this patch from all kernels for now
> (mainline and stable). I don't think the one that changes the setlk
> codepath is susceptible to this, but it's probably fine to hold off on
> applying both until I can sort out a better way to fix this one.

I also think it's safer to revert both of them.

-- 
William
