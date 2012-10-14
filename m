Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31617 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101Ab2JNWcp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 18:32:45 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CA+55aFz=1yFc-i4gmfGbyATvSNmPheedb6qF38ditHrdvtbdFQ@mail.gmail.com>
Date: Sun, 14 Oct 2012 18:32:31 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Larry McVoy <lm@bitmover.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F6AF04FD-1849-408B-A964-DDC386CA4654@oracle.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com> <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com> <20121014193905.GC32420@fieldses.org> <2CAF58DA-E925-47F5-B1FD-DC86EF565125@oracle.com> <CA+55aFz=1yFc-i4gmfGbyATvSNmPheedb6qF38ditHrdvtbdFQ@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 14, 2012, at 5:05 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Oct 14, 2012 at 1:55 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> I think range-check assertions in the XDR code are valuable.  Whether they are done via BUG_ON or WARN_ON_ONCE is a matter of priority:
> 
> Bullshit.
> 
>> BUG_ON forces you to notice the problem and address it, while WARN_ON allows the system to continue operating with the bug, but the bug can be ignored (or the WARN_ON simply removed because it is annoying).
> 
> Bullshit again.

> I don't think you've ever even *seen* a BUG_ON() fire in critical
> code, have you? It's not pretty.

I've been working on the Linux kernel NFS client for 12 years.  I've seen plenty of BUG_ONs fire at inopportune moments, and plenty fire right when it is useful.

The client-side XDR encoder functions don't return a return value.  Upper layers can not find out there was a problem if marshalling fails.  That's why we use BUG_ON here: the code really has to stop executing, especially if pointers are involved, to avoid crapping on other parts of memory or posting data to a server that could corrupt file data.

Remember, in a file system, you need to be concerned about kernel data structures _and_ what is being written to disk.

Even if we change BUG_ON to WARN_ON everywhere, there are still plenty of ways to oops in that code, and we have the same result: the machine may lock up or not write the back trace to the system log.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



