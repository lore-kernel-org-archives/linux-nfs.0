Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36408 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933897AbbI1Q3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 12:29:07 -0400
Date: Mon, 28 Sep 2015 12:29:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
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
Subject: Re: [PATCH v8 10/41] richacl: Permission check algorithm
Message-ID: <20150928162905.GE1358@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <1443391772-10171-11-git-send-email-agruenba@redhat.com>
 <20150928160855.GD1358@fieldses.org>
 <CAHpGcMLHxF8uqbv-hCjKFHKxwemn0QdxZifT7WC95oHs7D3MfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMLHxF8uqbv-hCjKFHKxwemn0QdxZifT7WC95oHs7D3MfA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 28, 2015 at 06:25:23PM +0200, Andreas Grünbacher wrote:
> 2015-09-28 18:08 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Mon, Sep 28, 2015 at 12:09:01AM +0200, Andreas Gruenbacher wrote:
> >> +     /*
> >> +      * Check if the acl grants the requested access and determine which
> >> +      * file class the process is in.
> >> +      */
> >> +     richacl_for_each_entry(ace, acl) {
> >> +             unsigned int ace_mask = ace->e_mask;
> >> +
> >> +             if (richace_is_inherit_only(ace))
> >> +                     continue;
> >> +             if (richace_is_owner(ace)) {
> >> +                     if (!uid_eq(current_fsuid(), inode->i_uid))
> >> +                             continue;
> >> +                     goto entry_matches_owner;
> >> +             } else if (richace_is_group(ace)) {
> >> +                     if (!in_owning_group)
> >> +                             continue;
> >> +             } else if (richace_is_unix_user(ace)) {
> >> +                     if (!uid_eq(current_fsuid(), ace->e_id.uid))
> >> +                             continue;
> >> +                     goto entry_matches_owner;
> >> +             } else if (richace_is_unix_group(ace)) {
> >> +                     if (!in_group_p(ace->e_id.gid))
> >> +                             continue;
> >> +             } else
> >> +                     goto entry_matches_everyone;
> >> +
> >> +             /*
> >> +              * Apply the group file mask to entries other than owner@ and
> >> +              * everyone@ or user entries matching the owner.
> >
> > The above also skips the following group_mask application on any unix
> > group.
> 
> Really? How does it do that?

Sorry, I meant "unix user", not "unix group"!

--b.
