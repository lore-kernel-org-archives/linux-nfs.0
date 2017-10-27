Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45510 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751472AbdJ0QDG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Oct 2017 12:03:06 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKd2MX0ao7f2X32js=72YmZ0exn4KkwdgrXB9tKY7KiSXg@mail.gmail.com>
References: <CAOssrKd2MX0ao7f2X32js=72YmZ0exn4KkwdgrXB9tKY7KiSXg@mail.gmail.com> <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk> <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk> <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com> <28791.1509035055@warthog.procyon.org.uk> <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com> <29611.1509114932@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock creation/configuration context [ver #6]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 27 Oct 2017 17:03:04 +0100
Message-ID: <3054.1509120184@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> Yes I did mean vfs_parse_sb_flag_option().
> 
> Yes, I understand its purpose, but it would be cleaner if all the
> option parsing was done in fc->ops->parse_option().
> 
> It might be worth introducing the vfs_parse_sb_flag_option(), to be
> called from ->parse_option().

I was trying to relieve the filesystem of the requirement to have to deal with
common stuff and also the need to talk directly to the LSM.

> > Btw, how would it affect the LSM?
> 
> LSM would have to reject a "reset" if not enough privileges to
> *create* a new fs instance, since it essentially requires creating a
> new config, which is what is done when creating an fs instance.

That's not what I'm asking.  Would the reset change LSM state?  Reset security
labels and options?

> > Sorry, how does the new, clean one do it without handling these options?
> > There is no MS_* mask passed in, except to fsmount().
> 
> The new one certainly should.

Should what?

> Ignoring unknown flags/options is generally a bad idea.

They're not unknown - just not of interest to the filesystem.

David
