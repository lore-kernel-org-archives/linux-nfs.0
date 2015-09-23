Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:32896 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbbIWNLr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 09:11:47 -0400
Received: by lahh2 with SMTP id h2so25551642lah.0
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 06:11:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150922160637.GC15838@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-26-git-send-email-agruenba@redhat.com>
	<20150922160637.GC15838@fieldses.org>
Date: Wed, 23 Sep 2015 15:11:45 +0200
Message-ID: <CAHc6FU6gnPK5vdJynv0ze=mNju6V_1WuR99oXWC4Fdh2GFMVgA@mail.gmail.com>
Subject: Re: [RFC v7 25/41] richacl: Isolate the owner and group classes
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-22 18:06 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:20PM +0200, Andreas Gruenbacher wrote:
>> When applying the file masks to an acl, we need to ensure that no
>> process gets more permissions than allowed by its file mask.
>>
>> This may require inserting an owner@ deny ace to ensure this if the
>> owner mask contains fewer permissions than the group or other mask.  For
>> example, when applying mode 0466 to the following acl:
>>
>>    everyone@:rw::allow
>>
>> A deny ace needs to be inserted so that the owner won't get elevated
>> write access:
>>
>>    owner@:w::deny
>>    everyone@:rw::allow
>>
>> Likewise, we may need to insert group class deny aces if the group mask
>> contains fewer permissions than the other mask.  For example, when
>> applying mode 0646 to the following acl:
>>
>>    owner@:rw::allow
>>    everyone@:rw::allow
>>
>> A deny ace needs to be inserted so that the owning group won't get
>> elevated write access:
>>
>>    owner@:rw::allow
>>    group@:w::deny
>>    everyone@:rw::allow
>>
>> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
>> ---
>>  fs/richacl_compat.c | 236 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 236 insertions(+)
>>
>> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
>> index 30bdc95..412844c 100644
>> --- a/fs/richacl_compat.c
>> +++ b/fs/richacl_compat.c
>> @@ -494,3 +494,239 @@ richacl_set_other_permissions(struct richacl_alloc *alloc)
>>               richace_change_mask(alloc, &ace, other_mask);
>>       return 0;
>>  }
>> +
>> +/**
>> + * richacl_max_allowed  -  maximum permissions that anybody is allowed
>> + */
>> +static unsigned int
>> +richacl_max_allowed(struct richacl *acl)
>> +{
>> +     struct richace *ace;
>> +     unsigned int allowed = 0;
>> +
>> +     richacl_for_each_entry_reverse(ace, acl) {
>> +             if (richace_is_inherit_only(ace))
>> +                     continue;
>> +             if (richace_is_allow(ace))
>> +                     allowed |= ace->e_mask;
>> +             else if (richace_is_deny(ace)) {
>> +                     if (richace_is_everyone(ace))
>> +                             allowed &= ~ace->e_mask;
>> +             }
>> +     }
>> +     return allowed;
>> +}
>> +
>> +/**
>> + * richacl_isolate_owner_class  -  limit the owner class to the owner file mask
>> + * @alloc:   acl and number of allocated entries
>> + *
>> + * POSIX requires that after a chmod, the owner class is granted no more
>> + * permissions than the owner file permission bits.  For richacls, this
>> + * means that the owner class must not be granted any permissions that the
>> + * owner mask does not include.
>> + *
>> + * When we apply file masks to an acl which grant more permissions to the group
>> + * or other class than to the owner class, we may end up in a situation where
>> + * the owner is granted additional permissions from other aces.  For example,
>> + * given this acl:
>> + *
>> + *    everyone:rwx::allow
>> + *
>> + * when file masks corresponding to mode 0466 are applied, after
>> + * richacl_propagate_everyone() and __richacl_apply_masks(), we end up with:
>> + *
>> + *    owner@:r::allow
>> + *    everyone@:rw::allow
>
> Are you sure?  I didn't think richacl_apply_masks actually creates an
> owner@ entry in this case.  Which is OK, just delete the owner@ ace from
> here and the following example and it still makes sense, I think.

Hmm, the example can be fixed by applying more 0406 here instead of 0466.

> (But: thanks in general for the examples in these comments, they're
> extremely helpful.)

Yes, I think without them, the code cannot be reviewed properly.

> I'd find it simpler to follow without the  a_entries + a_count condition,
> maybe something like this (untested):
>
> [...]

Great, let me further simplify this to:

static int
richacl_isolate_owner_class(struct richacl_alloc *alloc)
{
        struct richacl *acl = alloc->acl;
        unsigned int deny = richacl_max_allowed(acl) & ~acl->a_owner_mask;

        if (deny) {
                struct richace *ace;

                /*
                 * Figure out if we can update an existig OWNER@ DENY entry.
                 */
                richacl_for_each_entry(ace, acl) {
                        if (richace_is_inherit_only(ace))
                                continue;
                        if (richace_is_allow(ace))
                                break;
                        if (richace_is_owner(ace)) {
                                return richace_change_mask(alloc, &ace,
                                                           ace->e_mask | deny);
                        }
                }

                /* Insert an owner@ deny entry at the front. */
                ace = acl->a_entries;
                if (richacl_insert_entry(alloc, &ace))
                        return -1;
                ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
                ace->e_flags = RICHACE_SPECIAL_WHO;
                ace->e_mask = deny;
                ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
        }
        return 0;
}

Thanks,
Andreas
