Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:49423 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab3ITJt4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Sep 2013 05:49:56 -0400
MIME-Version: 1.0
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
Date: Fri, 20 Sep 2013 11:49:56 +0200
Message-ID: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Szeredi Miklos <miklos@szeredi.hu>
To: Zach Brown <zab@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 11, 2013 at 7:06 PM, Zach Brown <zab@redhat.com> wrote:
>
> When I first started on this stuff I followed the lead of previous
> work and added a new syscall for the copy operation:
>
> https://lkml.org/lkml/2013/5/14/618
>
> Towards the end of that thread Eric Wong asked why we didn't just
> extend splice.  I immediately replied with some dumb dismissive
> answer.  Once I sat down and looked at it, though, it does make a
> lot of sense.  So good job, Eric.  +10 Dummie points for me.
>
> Extending splice avoids all the noise of adding a new syscall and
> naturally falls back to buffered copying as that's what the direct
> splice path does for sendfile() today.

Nice idea.

>
> So that's what this patch series demonstrates.  It adds a flag that
> lets splice get at the same direct splicing that sendfile() does.
> We then add a file system file_operations method to accelerate the
> copy which has access to both files.
>
> Some things to talk about:
> - I really don't care about the naming here.  If you do, holler.
> - We might want different flags for file-to-file splicing and acceleration

Yes, I think "copy" and "reflink" needs to be differentiated.

> - We might want flags to require or forbid acceleration
> - We might want to provide all these flags to sendfile, too
>
> Thoughts?  Objections?

Can filesystem support "whole file copy" only?  Or arbitrary
block-to-block copy should be mandatory?

Splice has size_t argument for the size, which is limited to 4G on 32
bit.  Won't this be an issue for whole-file-copy?  We could have
special value (-1) for whole file, but that's starting to be hackish.

We are talking about copying large amounts of data in a single
syscall, which will possibly take a long time.  Will the syscall be
interruptible?  Restartable?

Thanks,
Miklos
