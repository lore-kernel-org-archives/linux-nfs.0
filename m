Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helmsgagent01.f-secure.com ([193.110.108.21]:58667 "EHLO
        helmsgagent01.f-secure.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752915AbdCWNQ2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Mar 2017 09:16:28 -0400
From: Marko Rauhamaa <marko.rauhamaa@f-secure.com>
To: Jeff Layton <jlayton@poochiereds.net>
CC: Amir Goldstein <amir73il@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: fanotify read returns with errno == EOPENSTALE
References: <87inn12urq.fsf@drapion.f-secure.com>
        <CAOQ4uxjzjFDLmvebHmC4t4_tT8xyWfbHVGfKohEqw7ZjpxfV_w@mail.gmail.com>
        <20170322193122.GV29622@ZenIV.linux.org.uk>
        <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
        <87a88c2yxq.fsf@drapion.f-secure.com>
        <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
        <1490270212.3921.10.camel@poochiereds.net>
Date: Thu, 23 Mar 2017 14:43:12 +0200
In-Reply-To: <1490270212.3921.10.camel@poochiereds.net> (Jeff Layton's message
        of "Thu, 23 Mar 2017 07:56:52 -0400")
Message-ID: <8760j02mfz.fsf@drapion.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@poochiereds.net>:

> It was definitely not the intention to leak this error code to
> userland. EOPENSTALE is not a POSIX sanctioned error code, so
> applications generally don't know anything about it and will be
> confused.

Got it. I will try to work on a reproduction and make a proper bug
report.

> I haven't looked closely at this particular problem, but IIRC we
> usually just translate EOPENSTALE to ESTALE, and that may be all that
> needs to be done here. If this happened in the RHEL kernel, then
> please do open a bug with Red Hat and we'll get it straightened out.

ESTALE has not been mentioned as a possible error code from an fanotify
read. Most importantly, since read fails, I suppose there is no recovery
but you must close the fanotify fd and call fanotify_init() again. Or
should I just ignore it and read on? If so, why bother returning the
error from the kernel in the first place?

> That said, you should take heed that all of the [fa|i|d]notify APIs do
> not extend beyond the local machine when you use them on network
> filesystems. If you're expecting to get notification of events that
> are occurring on other clients, you're going to be disappointed here.

That certainly is disappointing. However, there is a certain level of
coherency one would expect, namely:

 * An NFS4 client opening a file should be subject to an OPEN_PERM check
   on that client (if the client is monitoring the mount point).

 * An NFS4 client opening a file should be subject to an OPEN_PERM check
   on the server (if the server is monitoring the mount point).

 * An fanotify read should not fail mysteriously. Rather, a read on
   metadata->fd should be the one failing.


Marko
