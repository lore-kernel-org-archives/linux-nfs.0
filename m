Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63755 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab1I0Rv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 13:51:59 -0400
Received: by wwf22 with SMTP id 22so7606129wwf.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Sep 2011 10:51:58 -0700 (PDT)
In-Reply-To: <20110927173822.GC24197@suse.de>
References: <1317076424.19951.32.camel@lade.trondhjem.org> <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
 <1317078563.21770.8.camel@lade.trondhjem.org> <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
 <1317085155.21770.17.camel@lade.trondhjem.org> <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
 <1317097001.3176.20.camel@perseus.themaw.net> <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
 <1317099091.3176.31.camel@perseus.themaw.net> <CA+55aFwf8z+pi3okC2GmuYYKTN3hz+j5Y4XX4B=VrOP+YG0Qpw@mail.gmail.com>
 <20110927173822.GC24197@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Sep 2011 10:51:34 -0700
Message-ID: <CA+55aFzJBxMJEgPBv-bWGJSBvKA04orsnrMo8YJiMvoTYKZYfA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Greg KH <gregkh@suse.de>
Cc: Ian Kent <raven@themaw.net>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 10:38 AM, Greg KH <gregkh@suse.de> wrote:
>
> Does any of this make any sense for the 3.0-stable tree as well?

My gut feel is that it's not important enough to worry about too much,
and we should wait to see that nobody complains about the 3.1
behavior.

                  Linus
