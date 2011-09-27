Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61750 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab1I0USh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 16:18:37 -0400
Received: by bkbzt4 with SMTP id zt4so7327502bkb.19
        for <linux-nfs@vger.kernel.org>; Tue, 27 Sep 2011 13:18:36 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Greg KH <gregkh@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Ian Kent <raven@themaw.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, David Howells <dhowells@redhat.com>,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
References: <1317078563.21770.8.camel@lade.trondhjem.org>
	<CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
	<1317085155.21770.17.camel@lade.trondhjem.org>
	<CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
	<1317097001.3176.20.camel@perseus.themaw.net>
	<CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
	<1317099091.3176.31.camel@perseus.themaw.net>
	<CA+55aFwf8z+pi3okC2GmuYYKTN3hz+j5Y4XX4B=VrOP+YG0Qpw@mail.gmail.com>
	<20110927173822.GC24197@suse.de>
	<CA+55aFzJBxMJEgPBv-bWGJSBvKA04orsnrMo8YJiMvoTYKZYfA@mail.gmail.com>
	<20110927180026.GA25156@suse.de>
Date: Tue, 27 Sep 2011 22:18:11 +0200
In-Reply-To: <20110927180026.GA25156@suse.de> (Greg KH's message of "Tue, 27
	Sep 2011 11:00:26 -0700")
Message-ID: <87aa9p4u4c.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Greg KH <gregkh@suse.de> writes:

> On Tue, Sep 27, 2011 at 10:51:34AM -0700, Linus Torvalds wrote:
>> On Tue, Sep 27, 2011 at 10:38 AM, Greg KH <gregkh@suse.de> wrote:
>> >
>> > Does any of this make any sense for the 3.0-stable tree as well?
>> 
>> My gut feel is that it's not important enough to worry about too much,
>> and we should wait to see that nobody complains about the 3.1
>> behavior.
>
> Ok, thanks, will do.

In that case you should back out

 vfs-automount-should-ignore-lookup_follow.patch

too, otherwise there is strange behavior with NFSv4.

Thanks,
Miklos
