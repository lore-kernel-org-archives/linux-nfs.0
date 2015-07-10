Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33569 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbbGJWfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 18:35:48 -0400
MIME-Version: 1.0
In-Reply-To: <20150710120714.53893586@tlielax.poochiereds.net>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
 <20150701093547.116dd788@tlielax.poochiereds.net> <CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
 <20150702060827.66fc27f1@tlielax.poochiereds.net> <20150710110255.66fc6452@tlielax.poochiereds.net>
 <CAJ75kXb6FRN-DY+wtvUEi53pc=tqLjA12S1X5egc4eR5pBN_MA@mail.gmail.com> <20150710120714.53893586@tlielax.poochiereds.net>
From: William Dauchy <wdauchy@gmail.com>
Date: Sat, 11 Jul 2015 00:35:27 +0200
Message-ID: <CAJ75kXbMu_DuKvU=3vwdDstAAkcbmP4dY+TNgqypO_fyNpDcQA@mail.gmail.com>
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

On Fri, Jul 10, 2015 at 6:07 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> Oh? Do you have some reason to suspect the setlk patch to be
> problematic? If not, then I'd rather not revert that one (at least not
> from mainline) since I don't think it's likely to be a problem and it
> does fix a real bug. It's your call on what you do in stable of course.

Yes, I also had some instabilities with the setlk patch only applied.
Same trace as mentioned in the other thread.

-- 
William
