Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54574 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdJZQYV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Oct 2017 12:24:21 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com>
References: <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com> <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk> <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock creation/configuration context [ver #6]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Oct 2017 17:24:15 +0100
Message-ID: <28791.1509035055@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> > +/**
> > + * vfs_parse_mount_option - Add a single mount option to a superblock config
> 
> Mount options are those that refer to the mount
> (nosuid,nodev,noatime,etc..); this function is not parsing those,
> AFAICT.

I'd quibble that those are "mountpoint" options, not "mount" options.  Mount
options are the options you can pass to mount and are a mixed bag.  But fair
enough, it's probably worth avoiding such terminology where we can.

> How about vfs_parse_fs_option()?

Sure.  Can we please not rename it again?

> We probably also need a "reset" type of option that clears all bits
> and is also passed onto the filesystem's parsing routine so it can
> reset all options as well.

Reset what?  To what?  To a blank slate?  To the state on the medium?  What if
it's a netfs?

This operation isn't well defined and I'm not sure it's useful because:

 (1) Unless we can preload options from some source, the starting context is
     blank, so why do you need a reset on a new mount?

 (2) We need to find out what state the options are currently in.  Reset today
     doesn't necessarily mean the same as reset tomorrow.

 (3) Not all options are simple on/off switches.  Some of them are multistate,
     some are strings/numbers that have non-zero defaults and some have
     dependencies on other options.

 (4) Not all options can be simply reset to "0", particularly if the
     filesystem is live.  Take an option that points to a network server or a
     separate journalling device for example.

> 1/a) New sb:
> 1/b) New sb for legacy mount(2)

Looking at this in terms of ext4, I would make the parser create an "option
change" script prior to loading the superblock.  The reason for that with ext4
is that ext4 stores an additional option string that must be parsed and
applied first - except that we potentially need some of the mount-supplied
options to be able to mount the fs.

So in the new-mount-of-new-sb case, I would actually create two scripts, one
for the options written to the context fd, then one for the on-disk script,
then validate the context and then apply them both atomically.

> 2/a) Shared sb:
> 2/b) Shared sb for legacy mount(2)

In the new-mount-of-live-sb case, I would validate the context script and
ignore any options that try to change things that can't be changed because the
fs is live.

It might be nice to report them also, but that requires a mechanism to do so.

> 3/a) Reconfig
> 3/b) Reconfig for legacy mount(2) (i.e. MS_REMOUNT)

In the reconfigure case, I only need to create one script, validate it and
then apply it atomically (well, as atomically as possible, given the fs is
actually live at this point).

There's the question of how far you allow a happens-to-share mount to effect a
reconfigure.  Seems a reasonable distinction to say that in your case 2 you
just ignore conflicts but possibly warn or reject in case 3.

> > +int generic_parse_monolithic(struct fs_context *ctx, void *data)
> > +{
> > +       char *options = data, *p;
> > +       int ret;
> > +
> > +       if (!options)
> > +               return 0;
> > +
> > +       while ((p = strsep(&options, ",")) != NULL) {
> > +               if (*p) {
> > +                       ret = vfs_parse_mount_option(ctx, p);
> 
> Monolithic option block is the legacy thing.

Yes, I know.

> It shouldn't be parsing the common flags.  It should instead be treating
> them as forbidden (although it probably doesn't really matter, since no
> filesystem will accept these anyway).

Except that ext4, f2fs, 9p, ... do take at least some of them.  I'm not sure
whether they ever see them, but without auditing userspace, there's no way to
know.

> So probably best to expand vfs_parse_mount_option() here and skip the
> sb flag parsing part.

You need to prove they are never seen here :-/

> > + * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)
> 
> I'm confused: MS_REMOUNT in sb_flags and FS_CONTEXT_FOR_REMOUNT in purpose?
> 
> I hope that's just a stale comment, sb_flags should really be just the
> superblock flags and not any op flags.

Yeah - that's stale.

> Also, can FS_CONTEXT_FOR_REMOUNT be renamed to ..._RECONFIG?

If you really want ;-)

> > + * vfs_sb_reconfig - Create a filesystem context for remount/reconfiguration
> > + * @mnt: The mountpoint to open
> > + * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)
> 
> Here again op flags make no sense.

Also stale.

> Also it should be made clear that the old sb flags will be overridden
> with these.

That's not necessarily the case.  The filesystem can override the override.

		if (sb->s_op->remount_fs_fc) {
		    retval = sb->s_op->remount_fs_fc(sb, fc);
 --->		    sb_flags = fc->sb_flags;
		} else {
 --->			retval = sb->s_op->remount_fs(sb, &sb_flags, data);
		}

> > +/**
> > + * vfs_dup_fc_config: Duplicate a filesytem context.
> > + * @src_fc: The context to copy.
> > + */
> 
> Can we introduce these before they actually get used.

I would rather not.  Any fix I have to make then has to be distributed
backwards over a bunch of patches that have stuff that doesn't get compiled,
especially if a change touches code divided up between multiple patches.

David
