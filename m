Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:54117 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750883Ab2JNBmQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 21:42:16 -0400
Date: Sat, 13 Oct 2012 18:42:15 -0700
From: Larry McVoy <lm@bitmover.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Larry McVoy <lm@bitmover.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121014014215.GO23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com>
 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013023147.GJ23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013025600.GL23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FFA38@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9091FFA38@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> PS: you are presumably running NFSv2 on your Macs. Odd that they should
> default to that...

I dunno if they default to that or we force that.  We have had lots of
problems with Linux NFS, we export our home directories but they are
more or less read only.

Maybe things have gotten better but back in the day I could crash the
kernel with a bk clone to a NFS directory.

We've also had problems with NFS versions, 2 has been stable for us so
we tend to use that when we can.

If you want me to get a rant about how retarded the various NFS versions
are I can go there.  The Sun NFS people absolutely positively did not
understand what RPC version numbers are for.  And they invented them.

Sigh.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
