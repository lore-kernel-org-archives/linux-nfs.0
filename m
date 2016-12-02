Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33967 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755829AbcLBJ5q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 04:57:46 -0500
Received: by mail-yw0-f193.google.com with SMTP id a10so21319308ywa.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 01:57:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1476190256-1677-4-git-send-email-agruenba@redhat.com>
References: <1476190256-1677-1-git-send-email-agruenba@redhat.com> <1476190256-1677-4-git-send-email-agruenba@redhat.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 2 Dec 2016 10:57:42 +0100
Message-ID: <CAELBmZCgttywPy3EtkFao7SPESaw8VB5K6x7PTRk7gwSk7sXqg@mail.gmail.com>
Subject: Re: [PATCH v27 03/21] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 11, 2016 at 2:50 PM, Andreas Gruenbacher
<agruenba@redhat.com> wrote:
> Normally, deleting a file requires MAY_WRITE access to the parent
> directory.  With richacls, a file may be deleted with MAY_DELETE_CHILD access
> to the parent directory or with MAY_DELETE_SELF access to the file.
>
> To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
> when checking for delete access inside a directory, and MAY_DELETE_SELF
> when checking for delete access to a file itself.
>
> The MAY_DELETE_SELF permission overrides the sticky directory check.

And MAY_DELETE_SELF seems totally inappropriate to any kind of rename,
since from the point of view of the inode we are not doing anything at
all.  The modifications are all in the parent(s), and that's where the
permission checks need to be.

> @@ -2780,14 +2780,20 @@ static int may_delete_or_replace(struct inode *dir, struct dentry *victim,
>         BUG_ON(victim->d_parent->d_inode != dir);
>         audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
>
> -       error = inode_permission(dir, mask);
> +       error = inode_permission(dir, mask | MAY_WRITE | MAY_DELETE_CHILD);
> +       if (!error && check_sticky(dir, inode))
> +               error = -EPERM;
> +       if (error && IS_RICHACL(inode) &&
> +           inode_permission(inode, MAY_DELETE_SELF) == 0 &&
> +           inode_permission(dir, mask) == 0)
> +               error = 0;

Why is MAY_WRITE missing here?  Everything not aware of
MAY_DELETE_SELF (e.g. LSMs) will still need MAY_WRITE otherwise this
is going to be a loophole.

Thanks,
Miklos
