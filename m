Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helmsgagent01.f-secure.com ([193.110.108.21]:45187 "EHLO
        helmsgagent01.f-secure.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S942878AbdDTMn2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 08:43:28 -0400
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
Date: Thu, 20 Apr 2017 15:43:22 +0300
In-Reply-To: <CAOQ4uxjA8Z7wnwuHFCKeKT1xz0Gh-qS40Y6cfPi3fAM0MKsRuQ@mail.gmail.com>
        (Amir Goldstein's message of "Thu, 20 Apr 2017 14:33:04 +0300")
Message-ID: <87shl38d1x.fsf@drapion.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amir Goldstein <amir73il@gmail.com>:

> Sorry I messed up the previous patch. please try this one:

I will try it.

> +                        * do the right thing if there are no more events to
> +                        * read (i.e. return bytes read, -EAGAIN or wait).

EAGAIN is the right thing to do when FAN_NONBLOCK has been specified.
Without FAN_NONBLOCK, EAGAIN is bound to confuse the application. That
could be documented, of course.

More importantly, does EAGAIN here still guarantee EPOLLET semantics of
epoll(7)? IOW, if I get EAGAIN, I shouldn't have to try read(2)ing the
fanotify fd again before calling epoll_wait(2).


Marko
