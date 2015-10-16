Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34957 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbbJPQNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 12:13:21 -0400
Received: by lbbes7 with SMTP id es7so14264220lbb.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 09:13:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrXFkB01tk21FuEOqABHWg1XyOQwsT+s=Lq0RYye6X_7xw@mail.gmail.com>
References: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
	<1445008706-15115-17-git-send-email-agruenba@redhat.com>
	<CALCETrXFkB01tk21FuEOqABHWg1XyOQwsT+s=Lq0RYye6X_7xw@mail.gmail.com>
Date: Fri, 16 Oct 2015 18:13:19 +0200
Message-ID: <CAHc6FU7SNs6+xt34s18xM-C4U_7v5DLcN_feHXhVMY1q=K6zxA@mail.gmail.com>
Subject: Re: [PATCH v11 16/48] richacl: Automatic Inheritance
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Andy Lutomirski <luto@amacapital.net>
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
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 6:00 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Oct 16, 2015 at 8:17 AM, Andreas Gruenbacher
> <agruenba@redhat.com> wrote:
>> Automatic Inheritance works as follows:
>>
>>  - When the RICHACL_AUTO_INHERIT flag in the acl of a file or directory
>>    is not set, the file or directory is not affected by AI.
>>
>>  - When the RICHACL_AUTO_INHERIT flag in the acl of a directory is set
>>    and a file or subdirectory is created in that directory, the
>>    inherited acl will have the RICHACL_AUTO_INHERIT flag set, and all
>>    inherited aces will have the RICHACE_INHERITED_ACE flag set.  This
>>    allows user space to distinguish between aces which have been
>>    inherited and aces which have been explicitly added.
>
> What if the file or subdirectory that's created in that directory is a
> hard link?

Directories cannot have hard links.

When a file is hard linked into multiple directories with different
inheritable permissions, the permissions set last will "win". This
isn't particularly pretty, but it's the way this has worked on that
other operating system with significant marked share for the last
fifteen years.

Thanks,
Andreas
