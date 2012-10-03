Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:37744 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab2JCNzw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2012 09:55:52 -0400
Received: by ieak13 with SMTP id k13so17199005iea.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2012 06:55:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121003095419.5c8d9018@tlielax.poochiereds.net>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
	<1349268173-16574-1-git-send-email-jlayton@redhat.com>
	<CAFB9KM1xNQYJFS=hE=cFdTkZE9Da8qfhYRLSEJ2xVvwWzxJo1Q@mail.gmail.com>
	<20121003094035.1f7245a4@tlielax.poochiereds.net>
	<CAFB9KM3xDcvth1pOg-eDAPzM7Gu48A_ExY9vUk0Sb524aencGA@mail.gmail.com>
	<20121003095419.5c8d9018@tlielax.poochiereds.net>
Date: Wed, 3 Oct 2012 09:55:51 -0400
Message-ID: <CAFB9KM32Ur3zFA26wncEsPvTATGJCYX9UxvAu7TGbFLKPj1WMg@mail.gmail.com>
Subject: Re: [PATCH 7/6] nfsdcltrack: add a legacy transition mechanism
From: Scott Lovenberg <scott.lovenberg@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 3, 2012 at 9:54 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Wed, 3 Oct 2012 09:52:02 -0400
> Scott Lovenberg <scott.lovenberg@gmail.com> wrote:
>
>> On Wed, Oct 3, 2012 at 9:40 AM, Jeff Layton <jlayton@redhat.com> wrote:
>> > On Wed, 3 Oct 2012 09:34:36 -0400
>> > Scott Lovenberg <scott.lovenberg@gmail.com> wrote:
>> >
>> >> On Wed, Oct 3, 2012 at 8:42 AM, Jeff Layton <jlayton@redhat.com> wrote:
>> >> [snip]
>> >> > +               /* if there's a problem, then skip this entry */
>> >> > +               if (len < 0 || (size_t)len >= sizeof(blob)) {
>> >> > +                       xlog(L_WARNING, "%s: unable to build filename for %s!",
>> >> > +                               __func__, entry->d_name);
>> >> > +                       continue;
>> >> > +               }
>> >>
>> >> Is a len == 0 not a problem?
>> >>
>> >
>> > I'm not sure -- under what circumstances would it return 0?
>> >
>> > --
>> > Jeff Layton <jlayton@redhat.com>
>>
>> I guess the only case would be if sizeof(blob) was 0, then snprintf
>> would return a value < 1 according to the SUSv2.  Apparently C99 says
>> the return value will be > 0.  I guess this is a non-issue?
>>
>
> I think so, yes. The main worry here is overrunning the buffer and I
> think the error checking I'm doing has that covered.
>
> --
> Jeff Layton <jlayton@redhat.com>

Agreed.  Sorry for the noise. :)

-- 
Peace and Blessings,
-Scott.
