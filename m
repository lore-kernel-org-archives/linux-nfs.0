Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:59186 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752625Ab2JMC4B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:56:01 -0400
Date: Fri, 12 Oct 2012 19:56:00 -0700
From: Larry McVoy <lm@bitmover.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Larry McVoy <lm@bitmover.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121013025600.GL23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com>
 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013023147.GJ23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 02:52:51AM +0000, Myklebust, Trond wrote:
> On Fri, 2012-10-12 at 19:31 -0700, Larry McVoy wrote:
> > As I've said, debugging this is going to be hard, it means stopping my
> > company.  We can do one more crash, you guys can tell me what to do,
> > but that's about it.
> 
> Do you have a reproducer? 

Oh yeah, it happens every time.  Run skype on a mac w/ your home dir NFS
mounted.  Skype tries to do some lock operation and the machine panics.

We've done it 4 times in a row to be sure we weren't smoking crack.  No
crack.  Just panics.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
