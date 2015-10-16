Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36612 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbbJPQAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 12:00:31 -0400
Received: by obcqt19 with SMTP id qt19so16003214obc.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 09:00:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1445008706-15115-17-git-send-email-agruenba@redhat.com>
References: <1445008706-15115-1-git-send-email-agruenba@redhat.com> <1445008706-15115-17-git-send-email-agruenba@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 16 Oct 2015 09:00:11 -0700
Message-ID: <CALCETrXFkB01tk21FuEOqABHWg1XyOQwsT+s=Lq0RYye6X_7xw@mail.gmail.com>
Subject: Re: [PATCH v11 16/48] richacl: Automatic Inheritance
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        xfs@oss.sgi.com,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 8:17 AM, Andreas Gruenbacher
<agruenba@redhat.com> wrote:
> Automatic Inheritance (AI) allows changes to the acl of a directory to
> propagate down to children.
>
> This is mostly implemented in user space: when a process changes the
> permissions of a directory and Automatic Inheritance is enabled for that
> directory, the process must propagate those changes to all children,
> recursively.
>
> The kernel enables this by keeping track of which permissions have been
> inherited at create time.  In addition, it makes sure that permission
> propagation is turned off when the permissions are set explicitly (for
> example, upon create or chmod).
>
> Automatic Inheritance works as follows:
>
>  - When the RICHACL_AUTO_INHERIT flag in the acl of a file or directory
>    is not set, the file or directory is not affected by AI.
>
>  - When the RICHACL_AUTO_INHERIT flag in the acl of a directory is set
>    and a file or subdirectory is created in that directory, the
>    inherited acl will have the RICHACL_AUTO_INHERIT flag set, and all
>    inherited aces will have the RICHACE_INHERITED_ACE flag set.  This
>    allows user space to distinguish between aces which have been
>    inherited and aces which have been explicitly added.

What if the file or subdirectory that's created in that directory is a
hard link?

--Andy
