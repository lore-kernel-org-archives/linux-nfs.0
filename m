Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:38737 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753307AbdLGSAe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 13:00:34 -0500
Received: by mail-ua0-f182.google.com with SMTP id i4so5851170uab.5
        for <linux-nfs@vger.kernel.org>; Thu, 07 Dec 2017 10:00:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171207165838.GA4096@fieldses.org>
References: <CAN-5tyEe2gEgmSnZju7MjgrFR_YK1PrLx2NpxJn5Ks88PEz__g@mail.gmail.com>
 <CAABAsM57k0E32ywgW=qdhFbeHctcUivM9mkuuA1qbfB9F7Rvyg@mail.gmail.com>
 <CAN-5tyEmwgo7ea1WJ-0nRE+Jz+b9rb97GkYEmFyq_C+8nr1kTw@mail.gmail.com> <20171207165838.GA4096@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 7 Dec 2017 13:00:32 -0500
Message-ID: <CAN-5tyGYL5jXSqWbMSBdD9oHTD5Bsj5moFyGBKnD3t1zBLZYZA@mail.gmail.com>
Subject: Re: [nfsv4] questing about NLM LOCK, CANCEL UNLOCK
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 7, 2017 at 11:58 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Dec 07, 2017 at 11:10:16AM -0500, Olga Kornievskaia wrote:
>> Ok. I thought that because RFC1813 covers NLM operations that it is.
>
> Yeah, I don't see a harm to the occasional NLM question on the v4
> working group list.  It's a bit of an orphaned protocol, so there's not
> really any other implementation-independent forum.
>
>> I will extend this question to the Linux NFS mailing list as the
>> client implementation I'm interested is Linux.
>
> But that's fine too.
>
> I thought that LOCK/CANCEL race was one of the motivations for NFSv4,
> so...
>
>> >> Is there a solution or this is broken protocol?
>
> ... I'd always assumed the protocol was impossible to implement 100%
> correctly, though maybe there's some clever solution.

Is such race still possible with the linux server implementation which
is single threaded and in my testing isn't processing LOCK/CANCEL
out-of-order then?

>> >> Should it be client's responsibility to notice that it received a LOCK
>> >> reply for which it wasn't waiting and always follow up with an UNLOCK?
>
> That would be tricky and still not handle all cases, I think.

Yes I'm not sure the client can do it. It will have no info about the
lock and not sure how to create an appropriate UNLOCK reply (unless we
keep around lock info of all cancelled locks).

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
