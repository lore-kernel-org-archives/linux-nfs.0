Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49543 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S968318AbdEWOy4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:54:56 -0400
Message-Id: <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
To: Djalal Harouni <tixxdz@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        Miklos Szeredi <mszeredi@redhat.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel" <linux-kernel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Date: Tue, 23 May 2017 10:54:52 -0400
In-Reply-To: <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com>
 <874lwbraxh.fsf@xmission.com>
 <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017, at 10:30 AM, Djalal Harouni wrote:
>
> Maybe it depends on the cases, a general approach can be too difficult
> to handle especially from the security point. Maybe it is better to
> identify what operations need what context, and a userspace
> service/proxy can act using kthreadd with the right context... at
> least the shift to this model has been done for years now in the
> mobile industry.

Why not drop the upcall model in favor of having userspace
monitor events via a (more efficient) protocol and react to them on its own?
It's just generally more flexible and avoids all of those issues like
replicating the seccomp configuration, etc.

Something like inotify/signalfd could be a precedent around having a read()/poll()able
fd.  /proc/keys-requests ?

Then if you create a new user namespace, and open /proc/keys-requests, the
kernel will always write to that instead of calling /sbin/request-key.
