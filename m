Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44070 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab2JOAnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Oct 2012 20:43:06 -0400
Date: Sun, 14 Oct 2012 20:43:03 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Larry McVoy <lm@bitmover.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121015004302.GF32420@fieldses.org>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com>
 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013023147.GJ23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013025600.GL23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FFA38@SACEXCMBX04-PRD.hq.netapp.com>
 <20121014014215.GO23247@bitmover.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121014014215.GO23247@bitmover.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 06:42:15PM -0700, Larry McVoy wrote:
> > PS: you are presumably running NFSv2 on your Macs. Odd that they should
> > default to that...
> 
> I dunno if they default to that or we force that.  We have had lots of
> problems with Linux NFS, we export our home directories but they are
> more or less read only.
> 
> Maybe things have gotten better but back in the day I could crash the
> kernel with a bk clone to a NFS directory.

Bug reports welcomed if any of those bugs are still around.

--b.
