Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:36659 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937525AbdEWPbf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:31:35 -0400
Received: by mail-qt0-f179.google.com with SMTP id f55so131087060qta.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 May 2017 08:31:35 -0700 (PDT)
Message-ID: <1495553491.2946.16.camel@redhat.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Jeff Layton <jlayton@redhat.com>
To: Colin Walters <walters@verbum.org>,
        Djalal Harouni <tixxdz@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        Miklos Szeredi <mszeredi@redhat.com>,
        linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Date: Tue, 23 May 2017 11:31:31 -0400
In-Reply-To: <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com>
         <874lwbraxh.fsf@xmission.com>
         <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
         <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-23 at 10:54 -0400, Colin Walters wrote:
> On Tue, May 23, 2017, at 10:30 AM, Djalal Harouni wrote:
> > 
> > Maybe it depends on the cases, a general approach can be too difficult
> > to handle especially from the security point. Maybe it is better to
> > identify what operations need what context, and a userspace
> > service/proxy can act using kthreadd with the right context... at
> > least the shift to this model has been done for years now in the
> > mobile industry.
> 
> Why not drop the upcall model in favor of having userspace
> monitor events via a (more efficient) protocol and react to them on its own?
> It's just generally more flexible and avoids all of those issues like
> replicating the seccomp configuration, etc.
> 
> Something like inotify/signalfd could be a precedent around having a read()/poll()able
> fd.  /proc/keys-requests ?
> 
> Then if you create a new user namespace, and open /proc/keys-requests, the
> kernel will always write to that instead of calling /sbin/request-key.

Case in point:

nfsdcltrack was originally nfsdcld, a long running daemon that used
rpc_pipefs to talk to the kernel. That meant that you had to make sure
it gets enabled by systemd (or sysvinit, etc). If it dies, then you also
want to ensure that it gets restarted lest the kernel server hang,
etc...

It was pretty universally hated, as it was just one more daemon that you
needed to run to work a proper nfs server. So, I was encouraged to
switch it to a call_usermodehelper upcall and since then it has just
worked, as long as the binary is installed.

It's quite easy to say:

"You're doing it wrong. You just need to run all of these services as
long-running daemons."

But, that ignores the fact that handling long-running daemons for
infrequently used upcalls is actually quite painful to manage in
practice.

-- 
Jeff Layton <jlayton@redhat.com>
