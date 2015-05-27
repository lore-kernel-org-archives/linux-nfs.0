Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35425 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbbE0LZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2015 07:25:19 -0400
MIME-Version: 1.0
In-Reply-To: <20150522210831.GA8689@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<380de2cdb4a129e4b5d7b586260b79d71c7d241d.1429868795.git.agruenba@redhat.com>
	<20150522210831.GA8689@fieldses.org>
Date: Wed, 27 May 2015 13:25:18 +0200
Message-ID: <CAHpGcMLbqOgHd=nbq6m_LinAk4S9zS80SfUUvU6Ah7d_p=OfFg@mail.gmail.com>
Subject: Re: [RFC v3 14/45] richacl: Permission check algorithm
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-22 23:08 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Apr 24, 2015 at 01:04:11PM +0200, Andreas Gruenbacher wrote:
>> A richacl grants a requested access if the NFSv4 acl in the richacl
>> grants the requested permissions (according to the NFSv4 permission
>> check algorithm) and the file mask that applies to the process
>> includes the requested permissions.
>
> Is that right?  Based on that I'd have thought that an acl like
>
>         owner  :r::mask
>         group  :-::mask
>         other  :-::mask
>         bfields:r::allow
>
> would permit read to bfields in the case bfields is the file owner,
> because both the mask entries and the NFSv4 ACL would permit access.
>
> But I think it doesn't (because the "bfields" entry is subject to the
> group mask).

The problem at cause here that if we treat the acl and masks completely
separately, we can end up with acl/mask combinations that don't have a
representation as "normal" acls. For example, this:

   owner:r::mask
   group:-::mask
   other:-::mask
  group@:r::allow

would grant the owner read access when in the owning group, but
wouldn't grant the owning group access. This is handled by applying
the group mask to all group-class entries; see this comment in the
code:

                /*
                 * Apply the group file mask to entries other than OWNER@ and
                 * EVERYONE@. This is not required for correct access checking
                 * but ensures that we grant the same permissions as the acl
                 * computed by richacl_apply_masks() would grant.
                 */

There is no necessity to also apply this rule to user entries matching the
current owner though; we can change that here and in richacl_apply_masks().

> But if I'm right, I'm not sure how to describe the algorithm concisely.

Right, it's all a bit messy.

Thanks,
Andreas
