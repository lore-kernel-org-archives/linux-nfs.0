Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dcvr.yhbt.net ([64.71.152.64]:37397 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757248Ab3IKVYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 17:24:12 -0400
Date: Wed, 11 Sep 2013 21:17:23 +0000
From: Eric Wong <normalperson@yhbt.net>
To: Zach Brown <zab@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130911211722.GA9725@dcvr.yhbt.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Zach Brown <zab@redhat.com> wrote:
> Towards the end of that thread Eric Wong asked why we didn't just
> extend splice.  I immediately replied with some dumb dismissive
> answer.  Once I sat down and looked at it, though, it does make a
> lot of sense.  So good job, Eric.  +10 Dummie points for me.

Thanks for revisiting that :>

> Some things to talk about:
> - I really don't care about the naming here.  If you do, holler.

Exposing "DIRECT" to userspace now might confuse users into expecting
O_DIRECT behavior.  I say this as an easily-confused user.

In the future, perhaps O_DIRECT behavior can become per-splice (instead
of just per-open) and can save SPLICE_F_DIRECT for that.

> - We might want different flags for file-to-file splicing and acceleration
> - We might want flags to require or forbid acceleration

> - We might want to provide all these flags to sendfile, too

Another syscall?  I prefer not.  Better to just maintain the sendfile
API as-is for compatibility reasons and nudge users towards splice.

> Thoughts?  Objections?

I'll try to test/comment more in a week or two (not much time for
computing until then).
