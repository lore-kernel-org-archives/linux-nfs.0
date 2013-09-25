Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab3IYSjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Sep 2013 14:39:05 -0400
Date: Wed, 25 Sep 2013 11:38:28 -0700
From: Zach Brown <zab@redhat.com>
To: Szeredi Miklos <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130925183828.GA30372@lenny.home.zabbo.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
 <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hrmph.  I had composed a reply to you during Plumbers but.. something
happened to it :).  Here's another try now that I'm back.

> > Some things to talk about:
> > - I really don't care about the naming here.  If you do, holler.
> > - We might want different flags for file-to-file splicing and acceleration
> 
> Yes, I think "copy" and "reflink" needs to be differentiated.

I initially agreed but I'm not so sure now.  The problem is that we
can't know whether the acceleration is copying or not.  XCOPY on some
array may well do some shared referencing tricks.  The nfs COPY op can
have a server use btrfs reflink, or ext* and XCOPY, or .. who knows.  At
some point we have to admit that we have no way to determine the
relative durability of writes.  Storage can do a lot to make writes more
or less fragile that we have no visibility of.  SSD FTLs can log a bunch
of unrelated sectors on to one flash failure domain.

And if such a flag couldn't *actually* guarantee anything for a bunch of
storage topologies, well, let's not bother with it.

The only flag I'm in favour of now is one that has splice return rather
than falling back to manual page cache reads and writes.  It's more like
O_NONBLOCK than any kind of data durability hint.

> > - We might want flags to require or forbid acceleration
> > - We might want to provide all these flags to sendfile, too
> >
> > Thoughts?  Objections?
> 
> Can filesystem support "whole file copy" only?  Or arbitrary
> block-to-block copy should be mandatory?

I'm not sure I understand what you're asking.  The interface specifies
byte ranges.  File systems can return errors if they can't accelerate
the copy.  We *can't* mandate copy acceleration granularity as some
formats and protocols just can't do it.  splice() will fall back to
doing buffered copies when the file system returns an error.

> Splice has size_t argument for the size, which is limited to 4G on 32
> bit.  Won't this be an issue for whole-file-copy?  We could have
> special value (-1) for whole file, but that's starting to be hackish.

It will be an issue, yeah.  Just like it is with write() today.  I think
it's reasonable to start with a simple interface that matches current IO
syscalls.  I won't implement a special whole-file value, no.

And it's not just 32bit size_t.  While do_splice_direct() doesn't use
the truncated length that's returned from rw_verify_area(), it then
silently truncates the lengths to unsigned int in the splice_desc struct
fields.  It seems like we might want to address that :/.

> We are talking about copying large amounts of data in a single
> syscall, which will possibly take a long time.  Will the syscall be
> interruptible?  Restartable?

In as much as file systems let it be, yeah.  As ever, you're not going
to have a lot of luck interrupting a process stuck in lock_page(),
mutex_lock(), wait_on_page_writeback(), etc.   Though you did remind me
to investigate restarting.  Thanks.

- z
