Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34623 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753042AbeCFRQB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 12:16:01 -0500
Received: by mail-wm0-f46.google.com with SMTP id a20so18972554wmd.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Mar 2018 09:16:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180220184829.GA528@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-8-kolga@netapp.com>
 <20180126215942.GC7770@fieldses.org> <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
 <20180202214545.GB7229@parsley.fieldses.org> <CAN-5tyHOa6SM1Gv+dv=pfQaQ--YTjfkyA6V57wgGic5qEK+jvg@mail.gmail.com>
 <20180216014337.GA3591@parsley.fieldses.org> <CAN-5tyFMSqC8GJEvCjxzTO7Nf3c69YBMjmRRc6EFrgXzKJ4+cg@mail.gmail.com>
 <20180216181237.GB2623@parsley.fieldses.org> <CAN-5tyHmt1DWgPz9nzuK9V2bVBRhEGev3iOoMv7TNY_k8shgXA@mail.gmail.com>
 <20180220184829.GA528@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 6 Mar 2018 12:15:59 -0500
Message-ID: <CAN-5tyEJu0PZ8i+t5c6EGMSWuW=zpcH1+1z8W+mXNxt-rON9AQ@mail.gmail.com>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 20, 2018 at 1:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Feb 16, 2018 at 03:53:05PM -0500, Olga Kornievskaia wrote:
>> It seems wrong but I'm not sure exactly why. I thinking what if the
>> server receives all state closing operations (delegreturn, unlock,
>> close) and the copy is still going. A file is being changed after the
>> file is closed seem weird. But as I mentioned, properly working client
>> should be unlocking/closing the file until after the copy is done (or
>> until offload_cancel is sent after ctrl-c).
>>
>> Who is responsible for making sure that the file isn't being accessed
>> after it's closed? Is it server's or client's? Like client is making
>> sure all the writes are done before it does the close. Should it be
>> client's responsibility as well to make sure there are no on-going
>> copies before doing the close?
>>
>> Is the question here about just delegations or are you questioning
>> whether or not CLOSE/UNLOCK need to be delayed until the copy is
>> finished?
>
> Yeah, I kinda suspect there's a bug in the CLOSE and UNLOCK case too.
>
> I don't know if the client really causes trouble for anyone but itself
> if it allows IO to go on past close, unlock, or delegreturn.
>
> If it's still going on after another client acquires a conflicting open,
> lock, or delegation, that could be a problem: a client that holds a
> mandatory lock, or an open with DENY_WRITE, or a delegation, has a right
> not to expect the file to change underneath it.  We should already be
> safe against that in the delegation case thanks to the vfs checks in
> fs/locks.c:check_conflicting_open().
>
> In the DENY_WRITE case I bet there's still bug.  Maybe in the mandatory
> lock case, too.  But those cases are rare and already have other
> problems.
>
> So, I guess I don't care too much unless someone's seeing another
> problem.
>
> Still, killing off a long-running copy is probably a good precaution?

Now that I got back into the code and remembered it again, copy
stateid is never associated with a delegation stateid. Copy is
associated with the destination file's stateid which is opened for
write. Since linux server does not give out write delegations, then
the stateid is either an open stateid or lock stateid (in my testing I
varied not locking and locking the destination file so to get open
stateid as well as lock stateid to be used in the copy). If you want
me to keep the code for killing off copy in the delegreturn because in
the future there might be write delegations, I can but I recall the
rule of thumb is to keep it simple, thus I'm inclined to remove it.
