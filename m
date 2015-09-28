Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38663 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924AbbI1Qvt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 12:51:49 -0400
MIME-Version: 1.0
In-Reply-To: <20150928162905.GE1358@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<1443391772-10171-11-git-send-email-agruenba@redhat.com>
	<20150928160855.GD1358@fieldses.org>
	<CAHpGcMLHxF8uqbv-hCjKFHKxwemn0QdxZifT7WC95oHs7D3MfA@mail.gmail.com>
	<20150928162905.GE1358@fieldses.org>
Date: Mon, 28 Sep 2015 18:51:47 +0200
Message-ID: <CAHpGcM+uMeqFPrU-QufLcNQnCdr-8+zKVx42y6xEWASwvMC8gA@mail.gmail.com>
Subject: Re: [PATCH v8 10/41] richacl: Permission check algorithm
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-28 18:29 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Sep 28, 2015 at 06:25:23PM +0200, Andreas Grünbacher wrote:
>> 2015-09-28 18:08 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> > The above also skips the following group_mask application on any unix
>> > group.
>>
>> Really? How does it do that?
>
> Sorry, I meant "unix user", not "unix group"!

Indeed, that's a bit tricky. Probably worth changing if just for clarity:

-                       goto entry_matches_owner;
+                       if (uid_eq(current_fsuid(), inode->i_uid))
+                               goto entry_matches_owner;

Thanks,
Andreas
