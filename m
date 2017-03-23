Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34276 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751105AbdCWL45 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Mar 2017 07:56:57 -0400
Received: by mail-qk0-f176.google.com with SMTP id p64so177499788qke.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Mar 2017 04:56:56 -0700 (PDT)
Message-ID: <1490270212.3921.10.camel@poochiereds.net>
Subject: Re: fanotify read returns with errno == EOPENSTALE
From: Jeff Layton <jlayton@poochiereds.net>
To: Amir Goldstein <amir73il@gmail.com>,
        Marko Rauhamaa <marko.rauhamaa@f-secure.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 23 Mar 2017 07:56:52 -0400
In-Reply-To: <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
References: <87inn12urq.fsf@drapion.f-secure.com>
         <CAOQ4uxjzjFDLmvebHmC4t4_tT8xyWfbHVGfKohEqw7ZjpxfV_w@mail.gmail.com>
         <20170322193122.GV29622@ZenIV.linux.org.uk>
         <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
         <87a88c2yxq.fsf@drapion.f-secure.com>
         <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-03-23 at 07:46 -0400, Amir Goldstein wrote:
> On Thu, Mar 23, 2017 at 4:13 AM, Marko Rauhamaa
> <marko.rauhamaa@f-secure.com> wrote:
> > Amir Goldstein <amir73il@gmail.com>:
> > 
> > > On Wed, Mar 22, 2017 at 3:31 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > > > On Wed, Mar 22, 2017 at 02:20:15PM -0400, Amir Goldstein wrote:
> > > > 
> > > > > Well, the behavior was changed in kernel 4.7 (and stable kernels) by
> > > > > commit by Al Viro:
> > > > > fac7d19 fix EOPENSTALE bug in do_last()
> > > > > 
> > > > > Since that commit userspace will be able to see this error in
> > > > > fanotify events.
> > > > 
> > > > Unless *notify somehow uses do_last() directly, that commit should
> > > > have no effect on it (and it definitely has no effect on
> > > > dentry_open() callers)...
> > > 
> > > Right. I'm being silly :/
> > > 
> > > Back to Redhat I guess...
> > 
> > I will gladly take the issue to RedHat. However, the discussion so far
> > confuses me a bit. To confirm, is there a consensus here that EOPENSTALE
> > should never leak to userspace (through fanotify read anyway)?
> > 
> > If EOPENSTALE *is* a valid possible return from fanotify read, this is
> > my bug and not RedHat's. In that case, what is the correct recovery?
> > 
> > As for reproduction, I don't yet have one. At the moment, I just need an
> > authoritative user-space API clarification.
> > 
> 
> There is a consensus that the commit I pointed to has nothing do to with
> this alleged error leak.
> 
> It certainly looks like it wasn't the intention that this error will end up in
> userspace, but I can't say that it is bad that it got there in this case.
> The error is quite useful for you to understand what happened.
> 
> On a second look, I think that beyond pointing to an irrelevant commit
> my analysis still looks correct correct. I think upstream kernel *can* deliver
> this error on fanotify event and all those callers I mentioned that call
> dentry_open() directly without checking EOPENSTALE later on.
> 
> IIUC, the only way to get out of a stale dentry situation is that some thread
> will lookup that path and revalidate the dentry.
> 
> But if file has become stale between the time that the event was queued
> and the time the event is read and no process has tried looking it up since
> then the event read will have -EOPENSTALE for metadata->fd.
> 
> It's probably much harder to hit this in other cases I mentioned, but
> seems quite plausible with fanotify because events are often read some
> time after they happened.
> 
> With overlayfs readdir for example, lower dir will be revalidated on
> open of overlay dir, so process would have to wait some time
> before open and readdir to make this case likely.
> 
> I have been wrong once. Could be wrong again.
> Anyone?

It was definitely not the intention to leak this error code to
userland. EOPENSTALE is not a POSIX sanctioned error code, so
applications generally don't know anything about it and will be
confused.

I haven't looked closely at this particular problem, but IIRC we
usually just translate EOPENSTALE to ESTALE, and that may be all that
needs to be done here. If this happened in the RHEL kernel, then please
do open a bug with Red Hat and we'll get it straightened out.

That said, you should take heed that all of the [fa|i|d]notify APIs do
not extend beyond the local machine when you use them on network
filesystems. If you're expecting to get notification of events that are
occurring on other clients, you're going to be disappointed here.
-- 
Jeff Layton <jlayton@poochiereds.net>
