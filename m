Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34549 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcEIOOn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 10:14:43 -0400
Received: by mail-yw0-f174.google.com with SMTP id j74so250597676ywg.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2016 07:14:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160509073235.GI2694@ZenIV.linux.org.uk>
References: <20160505220344.GE5995@atomide.com>
	<20160508141629.GF2694@ZenIV.linux.org.uk>
	<20160509073235.GI2694@ZenIV.linux.org.uk>
Date: Mon, 9 May 2016 07:14:41 -0700
Message-ID: <CANn89iK5H-SokYE1r+OO3sPmQ1vpGqYGbE4x1QLn44wdyvH0cw@mail.gmail.com>
Subject: Re: NFSroot hangs with bad unlock balance in Linux next
From: Eric Dumazet <edumazet@google.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Tony Lindgren <tony@atomide.com>, Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 9, 2016 at 12:32 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, May 08, 2016 at 03:16:29PM +0100, Al Viro wrote:
>
>> Very strange.  We grab that rwsem at the entry into nfs_call_unlink()
>> and then either release it there and return or call nfs_do_call_unlink().
>> Which arranges for eventual call of nfs_async_unlink_release() (via
>> ->rpc_release); nfs_async_unlink_release() releases the rwsem.  Nobody else
>> releases it (on the read side, that is).
>>
>> The only kinda-sorta possibility I see here is that the inode we are
>> unlocking in that nfs_async_unlink_release() is not the one we'd locked
>> in nfs_call_unlink() that has lead to it.  That really shouldn't happen,
>> though...  Just to verify whether that's what we are hitting, could you
>> try to reproduce that thing with the patch below on top of -next and see
>> if it triggers any of those WARN_ON?
>
> D'oh...  Lockdep warnings are easy to trigger (and, AFAICS, bogus).
> up_read/down_read in fs/nfs/unlink.c should be replaced with
> up_read_non_owner/down_read_non_owner, lest the lockdep gets confused.
> Hangs are different - I've no idea what's triggering those.  I've seen
> something similar on that -next, but not on work.lookups.
>
> The joy of bisecting -next...  <a couple of hours later>
> 9317bb69824ec8d078b0b786b6971aedb0af3d4f is the first bad commit
> commit 9317bb69824ec8d078b0b786b6971aedb0af3d4f
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Apr 25 10:39:32 2016 -0700
>
>     net: SOCKWQ_ASYNC_NOSPACE optimizations
>
> Reverting changes to sk_set_bit/sk_clear_bit gets rid of the hangs.  Plain
> revert gives a conflict, since there had been additional change in
> "net: SOCKWQ_ASYNC_WAITDATA optimizations"; removing both fixed the hangs.
>
> Note that hangs appear without any fs/nfs/unlink.c modifications being
> there.  When the hang happens it affects NFS traffic; ssh session still
> works fine until it steps on a filesystem operation on NFS (i.e. you
> can use builtins, access procfs, etc.)

Yeah, the issue was reported last week (
http://www.spinics.net/lists/netdev/msg375777.html ),
and I could not convince myself to add a new sock flag,  like
SOCK_FASYNC_STICKY.

(Just in case NFS would ever call sock_fasync() with an empty
fasync_list, and SOCK_FASYNC would be cleared again.
