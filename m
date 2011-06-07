Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757897Ab1FGXXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 19:23:16 -0400
Date: Tue, 7 Jun 2011 19:23:14 -0400
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Cc: Tristan Ball <tristanb@pronto.com.au>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Sync with External Journal
Message-ID: <20110607232313.GG13911@fieldses.org>
References: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
 <BANLkTi=4ey0YpTtUwuVuRQz4_xYpt10wuw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <BANLkTi=4ey0YpTtUwuVuRQz4_xYpt10wuw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 06, 2011 at 01:12:51PM -0700, Wendy Cheng wrote:
> You'll probably get better answer(s) from ext3 user mailing list
> .... it is more about how journaling works for the specific file
> system.

Yes, though leave linux-nfs on the cc: as I'd be interested what you
find out.

> In ext3 case, I believe "sync" forces data getting flushed to the file
> system *regardless* which journal mode is chosen. Using an external
> journal device, particularly on SSD,  does help but the performance
> gain is limited by the amount of data that needs to be written into
> the file system itself.

> > /etc/exports:
> > /plain          *(rw,async,no_subtree_check,no_root_squash)
> > /split          *(rw,async,no_subtree_check,no_root_squash) # (FS with external Journal)
> >
> > Client mounts were done simply with -o 'rw,rsize=32768,wsize=32768'
> >
> > Benchmark results:
> > Plain Ext3, data=ordered export=sync, write speed 56-62MB/sec
> > Split Ext3, data=journal export=sync, write speed = 46-50MB/sec
> >
> > For reference:
> > Plain Ext3, data=ordered export=async, write speed 111MB/sec
> > Split Ext3, data=journal export=async, write speed 110MB/sec

What exactly is your test?

For sufficiently large sequential writes, I wouldn't actually have
expected sync vs. async to make much difference: eventually you're
limited by the drive speed (I'm assuming your drive does ~60MB/s write
througput?).  And individual writes (for NFS v3 and higher) aren't
necessarily required to be synchronous.

A better test would be creating or destroying a bunch of small files, as
create and unlink are synchronous (the nfs server won't return, in the
sync case, before each create and unlink actually hits the disk).

--b.
