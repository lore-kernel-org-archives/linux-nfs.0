Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helmsgagent01.f-secure.com ([193.110.108.21]:56646 "EHLO
        helmsgagent01.f-secure.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1039487AbdDUNNr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 09:13:47 -0400
From: Marko Rauhamaa <marko.rauhamaa@f-secure.com>
To: Amir Goldstein <amir73il@gmail.com>
CC: Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-api@vger.kernel.org>
Subject: Re: fanotify read returns with errno == EOPENSTALE
References: <87inn12urq.fsf@drapion.f-secure.com>
        <CAOQ4uxjzjFDLmvebHmC4t4_tT8xyWfbHVGfKohEqw7ZjpxfV_w@mail.gmail.com>
        <20170322193122.GV29622@ZenIV.linux.org.uk>
        <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
        <87a88c2yxq.fsf@drapion.f-secure.com>
        <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
        <1490270212.3921.10.camel@poochiereds.net>
        <8760j02mfz.fsf@drapion.f-secure.com>
        <CAOQ4uxja14p02jQurLTGv_fHrs+UBa5qfacrgY_-7tyv6UJqdw@mail.gmail.com>
        <87lgqwa4tg.fsf@drapion.f-secure.com>
        <CAOQ4uxirSfVVYBexXrWccDHnE5oqxNgUh3-X5Ey1w4R=nHXDjA@mail.gmail.com>
        <CAOQ4uxjA8Z7wnwuHFCKeKT1xz0Gh-qS40Y6cfPi3fAM0MKsRuQ@mail.gmail.com>
        <87shl38d1x.fsf@drapion.f-secure.com>
        <CAOQ4uxiJyrvEJMhM1jhiE5pCgP0iA_LL4Eo_h7UY00wkTKhbTg@mail.gmail.com>
Date: Fri, 21 Apr 2017 16:13:39 +0300
In-Reply-To: <CAOQ4uxiJyrvEJMhM1jhiE5pCgP0iA_LL4Eo_h7UY00wkTKhbTg@mail.gmail.com>
        (Amir Goldstein's message of "Thu, 20 Apr 2017 16:34:55 +0300")
Message-ID: <871ssl9a4c.fsf@drapion.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amir Goldstein <amir73il@gmail.com>:

> On Thu, Apr 20, 2017 at 3:43 PM, Marko Rauhamaa
> <marko.rauhamaa@f-secure.com> wrote:
>> Amir Goldstein <amir73il@gmail.com>:
>>
>>> Sorry I messed up the previous patch. please try this one:
>>
>> I will try it.

Tried it. Superficially, it seems to be working, but...

>> More importantly, does EAGAIN here still guarantee EPOLLET semantics
>> of epoll(7)? IOW, if I get EAGAIN, I shouldn't have to try read(2)ing
>> the fanotify fd again before calling epoll_wait(2).
>
> Yes, if you get EAGAIN it means there are no more events in the queue,
> so shouldn't have to try read again.

I ran into a system hang with our real product that suggests there might
be a problem left. It would be explained if your patch generated an
EAGAIN while there were other events waiting in the queue.

I will have to investigate further.


Marko

-- 
+358 44 990 4795
Skype: marko.rauhamaa_f-secure
