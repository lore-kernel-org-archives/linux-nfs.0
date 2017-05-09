Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:32799 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752049AbdEISv1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 14:51:27 -0400
Received: by mail-qk0-f176.google.com with SMTP id y201so9342441qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 11:51:26 -0700 (PDT)
Message-ID: <1494355884.2659.18.camel@redhat.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>,
        David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Date: Tue, 09 May 2017 14:51:24 -0400
In-Reply-To: <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
         <10943.1494284264@warthog.procyon.org.uk>
         <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
         <15762.1494322915@warthog.procyon.org.uk>
         <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-09 at 14:02 +0200, Miklos Szeredi wrote:
> On Tue, May 9, 2017 at 11:41 AM, David Howells <dhowells@redhat.com> wrote:
> > Miklos Szeredi <mszeredi@redhat.com> wrote:
> > 
> > > I think that's crazy.  We don't return detailed errors for any other
> > > syscall for path lookup, so why would path lookup for mount be
> > > special.
> > 
> > Firstly, we don't return detailed errors for mount() at the moment either.
> > 
> > Secondly, path lookup might entail automounts, so perhaps we should do it for
> > path lookup too.  Particularly in light of the fact that NFS4 mount uses
> > pathwalk to get from server:/ to server:/the/dir/I/actually/wanted/ so I'm
> > currently losing that error:-/
> > 
> > Thirdly, the security operation I'm talking about is separate to path lookup -
> > though perhaps we should pass LOOKUP_MOUNT as an intent flag into pathwalk so
> > that the security check can be done there; perhaps combined with another one.
> > 
> > Fourthly, why shouldn't we consider extending the facility to other system
> > calls in future?  It would involve copying the string to task_struct and
> > providing a way to retrieve it, but that's not that hard to achieve.
> 
> Maybe we should.   In fact that sounds like a splendid idea.  IMO even
> better, than having errors go via the fsfd descriptor.  Pretty cheap
> on the kernel side, and completely optional on the userspace side.
> 

A question here: What should happen if you go to set an error here, and
one is already set? Should it just free the string and replace it with
the new one? IOW, just keep the latest error? Or is it better to keep
the earlier one?

If you want to put this in the task_struct then I think you'll want to
sort that out. You could easily end up in this situation if a lot of
different kernel subsystems started using it to pass back detailed
errors.

> > 
> > > And why would
> > > 
> > >     fd = open("/foo/bar", O_PATH);
> > >     fsmount(fsfd, fd, NULL);
> > > 
> > > behave differently from
> > > 
> > >     fsmount(fsfd, -1, "/foo/bar");
> > > 
> > > ?
> > 
> > There's argument that the former should return EFAULT.  And that you should
> > set the path to "" and pass AT_EMPTY_PATH.  I should probably make sure it
> > does that - and add a flags field.  statx() was fixed to work this way.
> > 
> > Question for you: Should the MNT_* flags be passed to fsmount(), perhaps in
> > MS_* form?
> 
> MS_* flags are a mess.  I don't think they should be used for any new
> functionality.  MNT_* flags are much better, but there are some
> internal flags there as well.
> 
> I think the struct file model is better, where we have the external
> O_* flags and the internal FMODE_* flags.
> 
> Thanks,
> Miklos
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@redhat.com>
