Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:34991 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdBLBmG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Feb 2017 20:42:06 -0500
MIME-Version: 1.0
In-Reply-To: <20170212011521.GD2768@fieldses.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net> <20170212011521.GD2768@fieldses.org>
From: David Windsor <dwindsor@gmail.com>
Date: Sat, 11 Feb 2017 20:42:04 -0500
Message-ID: <CAEXv5_ggWO39MBZu_y5z4hKuN9xRUrxM4xh30MaapR6smus3_g@mail.gmail.com>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
To: Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 11, 2017 at 8:15 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Feb 11, 2017 at 07:31:42AM -0500, Jeff Layton wrote:
>> The basic idea here is that nfsv4 sessions have a "resting state" of 0.
>> We want to keep them around, but if they go "dead" then we we'll tear
>> them down if they aren't actively in use at the time. So, we still free
>> the thing when the refcount goes to zero, but we have an extra condition
>> before we free it on the put -- that the session is also "dead" (meaning
>> that the client asked us to destroy it).
>>
>> Your patch doesn't look like it'll break anything, but I personally find
>>  it harder to follow that way. The freeable reference state will be 1
>> instead of the normal 0.
>
> Alas, I don't have any examples in mind, but doesn't this pattern happen
> all over?
>

The majority of refcounted objects are allocated with refcount=1: the
very fact that they're being allocated means that they already have a
user.

The issue with struct nfsd4_session is that, like struct nfs4_client,
references to it are only taken when the server is actively working on
it.  Its default "resting state" is with refcount=0.

I would like to make its default resting state with refcount=1.  In
other cases similar to this, we've gotten around it by doing a
semantic +1 to the object's overall refcounting scheme.

Jeff suggested taking an additional reference in init_session(), and
dropping it in is_session_dead(), after determining, in fact, that the
object is DEAD.

> You have objects that live in some data structure.  They're freed only
> when they're removed from the data structure.  You want removal to fail
> whenever they're in use.
>

When they're in use, these objects' refcount should be > 0.

> So it's natural to use an atomic counter to track the number of external
> users and some other lock to serialize lookup and destruction.
>

When considering refcounted objects, the most "natural" interpretation
of refcount=0 means that the object no longer has any users and can be
freed.  Increments on objects with refcount=0 shouldn't be allowed, as
this may indicate a use-after-free condition.

This discussion is difficult because the refcount_t API hasn't yet
been introduced.  The purpose of that API is to eliminate
use-after-free bugs.

> --b.
