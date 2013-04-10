Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f47.google.com ([209.85.213.47]:49347 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935491Ab3DJMMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 08:12:25 -0400
Received: by mail-yh0-f47.google.com with SMTP id z12so25862yhz.34
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2013 05:12:25 -0700 (PDT)
Date: Wed, 10 Apr 2013 08:12:21 -0400
From: Jeff Layton <jlayton@samba.org>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org, samba-technical@lists.samba.org
Subject: Re: [PATCH v5 4/7] CIFS: Use NT_CREATE_ANDX command for forcemand
 mounts
Message-ID: <20130410081221.753e4bb3@corrin.poochiereds.net>
In-Reply-To: <CAKywueSPh2vXvS1HRmJHZUApo_YxWjcp4_2ZXgb1RHafS=A98w@mail.gmail.com>
References: <1365511227-17626-1-git-send-email-piastry@etersoft.ru>
	<1365511227-17626-5-git-send-email-piastry@etersoft.ru>
	<20130410071144.08ef2983@corrin.poochiereds.net>
	<CAKywueSPh2vXvS1HRmJHZUApo_YxWjcp4_2ZXgb1RHafS=A98w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Apr 2013 15:45:33 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> 2013/4/10 Jeff Layton <jlayton@samba.org>:
> > On Tue,  9 Apr 2013 16:40:24 +0400
> > Pavel Shilovsky <piastry@etersoft.ru> wrote:
> >
> >> forcemand mount option now lets us use Windows mandatory style of
> >> byte-range locks even if server supports posix ones - switches on
> >> Windows locking mechanism. Share flags is another locking mehanism
> >> provided by Windows semantic that can be used by NT_CREATE_ANDX
> >> command. This patch combines all Windows locking mechanism in one
> >> mount option by using NT_CREATE_ANDX to open files if forcemand is on.
> >>
> >> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> >> ---
> >>  fs/cifs/dir.c  | 1 +
> >>  fs/cifs/file.c | 6 ++++--
> >>  2 files changed, 5 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
> >> index d4331de..8587021 100644
> >> --- a/fs/cifs/dir.c
> >> +++ b/fs/cifs/dir.c
> >> @@ -217,6 +217,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
> >>       }
> >>
> >>       if (tcon->unix_ext && cap_unix(tcon->ses) && !tcon->broken_posix_open &&
> >> +         ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
> >>           (CIFS_UNIX_POSIX_PATH_OPS_CAP &
> >>                       le64_to_cpu(tcon->fsUnixInfo.Capability))) {
> >>               rc = cifs_posix_open(full_path, &newinode, inode->i_sb, mode,
> >> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> >> index 9394b2b..19038a4 100644
> >> --- a/fs/cifs/file.c
> >> +++ b/fs/cifs/file.c
> >> @@ -455,8 +455,9 @@ int cifs_open(struct inode *inode, struct file *file)
> >>       else
> >>               oplock = 0;
> >>
> >> -     if (!tcon->broken_posix_open && tcon->unix_ext &&
> >> -         cap_unix(tcon->ses) && (CIFS_UNIX_POSIX_PATH_OPS_CAP &
> >> +     if (!tcon->broken_posix_open && tcon->unix_ext && cap_unix(tcon->ses)
> >> +         && ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
> >> +         (CIFS_UNIX_POSIX_PATH_OPS_CAP &
> >>                               le64_to_cpu(tcon->fsUnixInfo.Capability))) {
> >>               /* can not refresh inode info since size could be stale */
> >>               rc = cifs_posix_open(full_path, &inode, inode->i_sb,
> >> @@ -624,6 +625,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
> >>               oplock = 0;
> >>
> >>       if (tcon->unix_ext && cap_unix(tcon->ses) &&
> >> +         ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
> >>           (CIFS_UNIX_POSIX_PATH_OPS_CAP &
> >>                               le64_to_cpu(tcon->fsUnixInfo.Capability))) {
> >>               /*
> >
> > I'm trying to understand why "forcemand" would matter here. Wouldn't
> > you just want to switch to using NT_CREATE_ANDX if O_DENY* is set
> > instead? What happens if I didn't mount with forcemand and then try to
> > use O_DENY*?
> 
> If cifs client mounts Samba share and negotiates posix extensions, it
> uses trans2 command to open files. In this case O_DENY* flags that are
> passed to open syscall won't be sent to the server and the file won't
> be locked. This patch gives us an opportunity to make the client
> always use NT_CREATE_ANDX command to open file - in this case O_DENY*
> flags won't be missed.
> 
> You are right, we can leave forcemand option without changes and use
> an appropriate smb command depending on openflags we have. Another
> possibility is to make the client use NT_CREATE_ANDX command if new
> 'sharelock' VFS mount options is specified.  If we mount a share with
> sharelock mount option, we need O_DENY* flags sent to the server, but
> the only one way to do it is to use NT_CREATE_ANDX command all the
> time we need to open a file - so, using trans2 open command doesn't
> make any sense in the case of 'sharelock' mounts.
> 

(cc'ing samba-technical)

I don't understand. Why would we need to use NT_CREATE_ANDX in lieu of
the POSIX trans2 open if the client isn't setting a share reservation
on that particular open? The server should still enforce share
reservations that are already set on the file regardless of which
method is used.

Perhaps too we should add these flags to the POSIX open call as well.
It would be nice not to have to fall back to NT_CREATE_ANDX.

-- 
Jeff Layton <jlayton@samba.org>
