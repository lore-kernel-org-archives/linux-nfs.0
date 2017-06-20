Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751082AbdFTTj4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 15:39:56 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "open list" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] fs/locks: Remove fl_nspid and use fs-specific l_pid
 for remote locks
Date: Tue, 20 Jun 2017 15:39:53 -0400
Message-ID: <9522737A-F6A5-4D17-A6F1-4438E438D076@redhat.com>
In-Reply-To: <1497987151.5054.1.camel@poochiereds.net>
References: <cover.1497877897.git.bcodding@redhat.com>
 <901367ff4ffd87594a380e3a0a5d20c4e4195b0e.1497877897.git.bcodding@redhat.com>
 <1497893534.4654.11.camel@poochiereds.net>
 <9037C362-D6F7-4545-80C2-08B072005055@redhat.com>
 <D1AFE5C7-427F-4B0B-8337-3D6A247156A3@redhat.com>
 <1497978415.4555.14.camel@poochiereds.net>
 <9AA05B58-8D17-4A03-88F8-0F44F346AE0F@redhat.com>
 <1497987151.5054.1.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 Jun 2017, at 15:32, Jeff Layton wrote:

> On Tue, 2017-06-20 at 15:17 -0400, Benjamin Coddington wrote:
>> On 20 Jun 2017, at 13:06, Jeff Layton wrote:
>>>
>>> Now that I think about it a bit more, I don't think we really need a
>>> flag here.
>>>
>>> Just have the ->lock operation set the fl_pid to a negative value. 
>>> That
>>> will never be a valid pid anyway. Then flock_translate_pid could 
>>> just
>>> return any negative value directly instead of trying to translate 
>>> it.
>>>
>>> In practice we would always just set it to -1. Maybe even add 
>>> something
>>> like this that the lock-> operation could set it to?
>>>
>>> #define    FILE_LOCK_OWNER_UNDEFINED       -1
>>
>> So for filesystems that set a remote pid, they should negate the pid 
>> to mean
>> that the pid should not be translated?  Then when we return that pid, 
>> we
>> flip it back again, or display a negative number, or turn it into -1?
>>
>> The flag, having a readable name, would make things a bit clearer as 
>> to what
>> the filesystems expect to happen to that pid value.
>>
>
> I now think that we really only ought to be filling out the pid when 
> it
> refers to a process on the local host. It seems sketchy to me to 
> return
> a pid here that is really the pid on another host, but happens to have
> the same pid as something else on this host. It's misleading at best,
> and if anyone tries to act on that info it could be dangerous. So I'm
> thinking that we should just set it to -1 when the lock is held by
> another host entirely.
>
> But, since pid values must be positive, we can code the basic
> infrastructure to return any negative value as-is instead of trying to
> translate it.

Ok, so we have to patch several filesystems.  The question is do we 
patch
those filesystems that set remote pids to negate their pid values in the 
lock
they return from F_GETLK, or do we ask them to set a flag?  We'd be 
patching
them to negate their pid just to then transform it to -1..

I'd prefer a flag rather than carrying meaning in a modified value since 
the
flag has readable information.  No one will come along later and wonder 
why
some filesystems are negating their pid values.

If we're going to touch filesystems that set have remote locks anyway,
perhaps it makes sense to take a step toward l_sysid by adding another
member to file_lock.  Then a special value of fl_sysid would indicate 
the
local system.

Ben
