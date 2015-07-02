Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33685 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbbGBI7U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 04:59:20 -0400
Received: by wiwl6 with SMTP id l6so189731034wiw.0
        for <linux-nfs@vger.kernel.org>; Thu, 02 Jul 2015 01:59:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150701093547.116dd788@tlielax.poochiereds.net>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com> <20150701093547.116dd788@tlielax.poochiereds.net>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 2 Jul 2015 10:58:59 +0200
Message-ID: <CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
To: Jeff Layton <jeff.layton@primarydata.com>, trond.myklebust@primarydata.com
Cc: jean@primarydata.com, Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 1, 2015 at 3:37 PM Jeff Layton <jeff.layton@primarydata.com> wrote:
>
> > The problem is almost exactly the same as the one fixed by feaff8e5b2cf.
>
> Oops, I forgot to Cc stable on this one...
> Trond, can you add that?

Is the commit mentionned also targeted for stable?
commit feaff8e5b2cfc3eae02cf65db7a400b0b9ffc596
nfs: take extra reference to fl->fl_file when running a setlk

Regards,
-- 

William
