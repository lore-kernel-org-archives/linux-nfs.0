Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f44.google.com ([209.85.166.44]:43549 "EHLO
        mail-io1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727672AbeIRDGi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 23:06:38 -0400
Received: by mail-io1-f44.google.com with SMTP id y10-v6so12756197ioa.10
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 14:37:29 -0700 (PDT)
MIME-Version: 1.0
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
In-Reply-To: <20180917211504.GA21269@fieldses.org>
From: Stan Hu <stanhu@gmail.com>
Date: Mon, 17 Sep 2018 14:37:16 -0700
Message-ID: <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2018 at 2:15 PM J. Bruce Fields <bfields@fieldses.org> wrote:

> Sounds like a bug to me, but I'm not sure where.  What filesystem are
> you exporting?  How much time do you think passes between steps 1 and 4?
> (I *think* it's possible you could hit a bug caused by low ctime
> granularity if you could get from step 1 to step 4 in less than a
> millisecond.)

For CentOS, I am exporting xfs. In Ubuntu, I think I was using ext4.

Steps 1 through 4 are all done by hand, so I don't think we're hitting
a millisecond issue. Just for good measure, I've done experiments
where I waited a few minutes between steps 1 and 4.

> Those kernel versions--are those the client (node A and B) versions, or
> the server versions?

The client and server kernel versions are the same across the board. I
didn't mix and match kernels.

> > Note that with an Isilon NFS server, instead of seeing stale content,
> > I see "Stale file handle" errors indefinitely unless I perform one of
> > the corrective steps.
>
> You see "stale file handle" errors from the "cat test1.txt"?  That's
> also weird.

Yes, this is the problem I'm actually more concerned about, which led
to this investigation in the first place.
