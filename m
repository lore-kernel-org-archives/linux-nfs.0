Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35839 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbbE0JYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2015 05:24:52 -0400
MIME-Version: 1.0
In-Reply-To: <20150515205140.GD29627@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
	<20150515205140.GD29627@fieldses.org>
Date: Wed, 27 May 2015 11:24:49 +0200
Message-ID: <CAHpGcMJAU+o_hyKLjBKGD7_akPxfMv0JeVCBcS1pKTwSRnCU-w@mail.gmail.com>
Subject: Re: [RFC v3 19/45] richacl: Also recognize nontrivial mode-equivalent acls
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

2015-05-15 22:51 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Apr 24, 2015 at 01:04:16PM +0200, Andreas Gruenbacher wrote:
> This comment is a little confusing:
>
>> + * This function does not consider the masks in @acl.
>
> Given that we do this later:
>
>> +     if (acl->a_flags & RICHACL_MASKED) {
>> +             owner.allowed &= acl->a_owner_mask;
>> +             group.allowed &= acl->a_group_mask;
>> +             everyone.allowed &= acl->a_other_mask;
>> +     }

Indeed, the comment seems to be a left-over from a previous version, sorry.

> I think the difference is that here you're checking that the end result
> after applying masks is mode-equivalent, whereas in riachacl_equiv_mode
> [...] you're also checking whether the masks themselves are
> mode-equivalent?

Yes.

>Is that the right thing to do?

This patch and its consequences probably weren't thought through well enough
initially. I meanwhile think that it doesn't matter if the masks themselves are
mode-equivalent and that we can drop this check.

Thanks,
Andreas
