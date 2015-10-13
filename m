Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35244 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932291AbbJMNjR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 09:39:17 -0400
Received: by lbwr8 with SMTP id r8so20322297lbw.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 06:39:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151012040545.GC27164@dastard>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
	<1444604337-17651-25-git-send-email-andreas.gruenbacher@gmail.com>
	<20151012001033.GA27164@dastard>
	<CAHpGcMKeJHDegs2cYKaJdX4Tw43Jp30Nv_2WoSNZfBzGJKu=BQ@mail.gmail.com>
	<20151012040545.GC27164@dastard>
Date: Tue, 13 Oct 2015 15:39:15 +0200
Message-ID: <CAHc6FU7aNW3drN+Mj2PHyz0Tv8RHexSuUzWCPnCA7eCWY68pHQ@mail.gmail.com>
Subject: Re: [PATCH v10 24/46] xfs: Add richacl support
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>, xfs@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 6:05 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Oct 12, 2015 at 03:51:15AM +0200, Andreas Grünbacher wrote:
>> 2015-10-12 2:10 GMT+02:00 Dave Chinner <david@fromorbit.com>:
>> > Also, I really dislike the API where passing a NULL acl means to
>> > "set this acl" actually means "remove the existing ACL". Why no
>> > ->remove_acl method called from the generic code?
>>
>> It's not uncommon, it saves inode operations and wiring-up code.
>
> I know it's common. All it does is put extra branches in the
> filesystem code to do this, because remove is a different operation
> to set. The API sucks, and we're not limited on inode operations,
> and the operator overloading makes the filesystem code unnecessarily
> complex as it has to detect when to branch out ot remove or not...

I've tried it out. The filesystem code could be simplified (see the
richacl-wip [*] branch until the next posting). Adding a
remove_richacl inode operation on top of that really doesn't help.

Thanks,
Andreas

[*] git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git
richacl-wip
