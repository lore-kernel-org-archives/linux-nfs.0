Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38737 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933922AbbI1QZZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 12:25:25 -0400
MIME-Version: 1.0
In-Reply-To: <20150928160855.GD1358@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<1443391772-10171-11-git-send-email-agruenba@redhat.com>
	<20150928160855.GD1358@fieldses.org>
Date: Mon, 28 Sep 2015 18:25:23 +0200
Message-ID: <CAHpGcMLHxF8uqbv-hCjKFHKxwemn0QdxZifT7WC95oHs7D3MfA@mail.gmail.com>
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

2015-09-28 18:08 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Sep 28, 2015 at 12:09:01AM +0200, Andreas Gruenbacher wrote:
>> +     /*
>> +      * Check if the acl grants the requested access and determine which
>> +      * file class the process is in.
>> +      */
>> +     richacl_for_each_entry(ace, acl) {
>> +             unsigned int ace_mask = ace->e_mask;
>> +
>> +             if (richace_is_inherit_only(ace))
>> +                     continue;
>> +             if (richace_is_owner(ace)) {
>> +                     if (!uid_eq(current_fsuid(), inode->i_uid))
>> +                             continue;
>> +                     goto entry_matches_owner;
>> +             } else if (richace_is_group(ace)) {
>> +                     if (!in_owning_group)
>> +                             continue;
>> +             } else if (richace_is_unix_user(ace)) {
>> +                     if (!uid_eq(current_fsuid(), ace->e_id.uid))
>> +                             continue;
>> +                     goto entry_matches_owner;
>> +             } else if (richace_is_unix_group(ace)) {
>> +                     if (!in_group_p(ace->e_id.gid))
>> +                             continue;
>> +             } else
>> +                     goto entry_matches_everyone;
>> +
>> +             /*
>> +              * Apply the group file mask to entries other than owner@ and
>> +              * everyone@ or user entries matching the owner.
>
> The above also skips the following group_mask application on any unix
> group.

Really? How does it do that?

Thanks,
Andreas
