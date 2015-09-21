Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33445 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbbIUUh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 16:37:27 -0400
Received: by lamp12 with SMTP id p12so74574271lam.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 13:37:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150918175840.GA21506@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-15-git-send-email-agruenba@redhat.com>
	<20150918175840.GA21506@fieldses.org>
Date: Mon, 21 Sep 2015 22:37:25 +0200
Message-ID: <CAHc6FU4kK5fj6Xgyb1vPsnsQ079EpTfkxYC6XAiT1vEQvikBrw@mail.gmail.com>
Subject: Re: [RFC v7 14/41] richacl: Create-time inheritance
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-18 19:58 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:09PM +0200, Andreas Gruenbacher wrote:
>> +                     if (dir_ace->e_flags & RICHACE_NO_PROPAGATE_INHERIT_ACE)
>> +                             ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
>> +                     else if ((dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE) &&
>> +                              !(dir_ace->e_flags & RICHACE_DIRECTORY_INHERIT_ACE))
>
> The FILE_INHERIT_ACE check there is redundant since we already know
> dir_ace is inheritable.
>
> (So, OK, it isn't wrong to check it again but let's not make this
> condition any more complicated than necessary.)

Indeed, we can turn it into:

        if (dir_ace->e_flags & RICHACE_NO_PROPAGATE_INHERIT_ACE)
                ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
        else if (!(dir_ace->e_flags & RICHACE_DIRECTORY_INHERIT_ACE))
                ace->e_flags |= RICHACE_INHERIT_ONLY_ACE;

>> +static struct richacl *
>> +richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
>> +{
>> +     struct richacl *acl;
>> +     mode_t mask;
>> +
>> +     acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
>> +     if (acl) {
>> +             mask = inode->i_mode;
>> +             if (richacl_equiv_mode(acl, &mask) == 0) {
>> +                     richacl_put(acl);
>> +                     acl = NULL;
>
> Why is it correct to ignore entirely the inherited acl in this case?
>
> Oh, I see, I'm forgetting that richacl_equiv_mode is setting the mask,
> which will get applied at the end of this function.  In my defense,
> maybe it's easy to overlook a side effect in an if condition.... But I
> don't have a better idea.  OK.

Yes. I'll leave that as it is.

> So, nits aside:
>
>         Reviewed-by: J. Bruce Fields <bfields@redhat.com>

Thanks,
Andreas
