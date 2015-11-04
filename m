Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35713 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbKDDC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 22:02:29 -0500
Received: by lfbn126 with SMTP id n126so34433240lfb.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 19:02:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <507E7A63-024B-4EBD-B0C3-4ABE8280440F@dilger.ca>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
	<1446563847-14005-3-git-send-email-agruenba@redhat.com>
	<507E7A63-024B-4EBD-B0C3-4ABE8280440F@dilger.ca>
Date: Wed, 4 Nov 2015 04:02:27 +0100
Message-ID: <CAHc6FU7q1WOTk_XH+pYOU2=i_ranmtbney9epyFQuTi27qOaGQ@mail.gmail.com>
Subject: Re: [PATCH v13 02/51] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 4, 2015 at 3:33 AM, Andreas Dilger <adilger@dilger.ca> wrote:
> On Nov 3, 2015, at 8:16 AM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
>> @@ -3667,7 +3674,7 @@ EXPORT_SYMBOL(dentry_unhash);
>>
>> int vfs_rmdir(struct inode *dir, struct dentry *dentry)
>> {
>> -     int error = may_delete(dir, dentry, 1);
>> +     int error = may_delete(dir, dentry, true, false);
>
> This is a prime example why passing "true" and "false" as function arguments
> is not very useful, and especially prone to bugs when there are two of them.
>
> That said, this is code originally from Al, so he may have a different
> opinion.

Have you checked how vfs_rename uses the is_dir and new_is_dir
variables? Using file modes there probably won't help readability. An
enum maybe?

Thanks,
Andreas
