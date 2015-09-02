Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36419 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190AbbIBUig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 16:38:36 -0400
Received: by lbcao8 with SMTP id ao8so13208429lbc.3
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2015 13:38:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150902195408.GC3319@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-9-git-send-email-agruenba@redhat.com>
	<20150902195408.GC3319@fieldses.org>
Date: Wed, 2 Sep 2015 22:38:34 +0200
Message-ID: <CAHc6FU59RmihddjZ6vmTxDN4t+QqW-d37i1iH7Wh0xeqvjcq-g@mail.gmail.com>
Subject: Re: [RFC v6 08/40] richacl: Compute maximum file masks from an acl
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-02 21:54 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> +     richacl_for_each_entry_reverse(ace, acl) {
>> +             if (richace_is_inherit_only(ace))
>> +                     continue;
>> +
>> +             if (richace_is_owner(ace) ||
>> +                 (richace_is_unix_user(ace) &&
>> +                  uid_eq(ace->e_id.uid, owner))) {
>> +                     if (richace_is_allow(ace))
>> +                             acl->a_owner_mask |= ace->e_mask;
>> +                     else if (richace_is_deny(ace))
>> +                             acl->a_owner_mask &= ~ace->e_mask;
>> +             } else if (richace_is_everyone(ace)) {
>> +                     if (richace_is_allow(ace)) {
>> +                             acl->a_owner_mask |= ace->e_mask;
>> +                             acl->a_group_mask |= ace->e_mask & gmask;
>> +                             acl->a_other_mask |= ace->e_mask;
>> +                     } else if (richace_is_deny(ace)) {
>> +                             acl->a_owner_mask &= ~ace->e_mask;
>> +                             acl->a_group_mask &= ~ace->e_mask;
>> +                             acl->a_other_mask &= ~ace->e_mask;
>> +                     }
>> +             } else {
>> +                     if (richace_is_allow(ace)) {
>> +                             acl->a_owner_mask |= ace->e_mask & gmask;
>> +                             acl->a_group_mask |= ace->e_mask & gmask;
>
> I think we do that because we don't (we can't) know whether the owner
> might match this ace, so we assume that it will match, as that's what
> gives us the maximum.

Yes.

> But on first glance this is a little counterintuitive and maybe worth a
> comment.

I agree.

Thanks,
Andreas
