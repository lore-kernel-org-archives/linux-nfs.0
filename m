Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37961 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbIWOMp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 10:12:45 -0400
MIME-Version: 1.0
In-Reply-To: <20150923140307.GB27083@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-25-git-send-email-agruenba@redhat.com>
	<20150923140307.GB27083@fieldses.org>
Date: Wed, 23 Sep 2015 16:12:42 +0200
Message-ID: <CAHpGcMJMgtqGDsxUYFXqVmenaLxdJHL3VO8byV0GtSkdrQMggw@mail.gmail.com>
Subject: Re: [RFC v7 24/41] richacl: Set the other permissions to the other mask
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-23 16:03 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:19PM +0200, Andreas Gruenbacher wrote:
>> +static int
>> +richacl_set_other_permissions(struct richacl_alloc *alloc)
>> +{
>> +     struct richacl *acl = alloc->acl;
>> +     unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
>> +     unsigned int other_mask = acl->a_other_mask & ~x;
>> +     struct richace *ace = acl->a_entries + acl->a_count - 1;
>> +
>> +     if (!(other_mask &&
>> +           (acl->a_flags & RICHACL_WRITE_THROUGH) &&
>> +           (acl->a_flags & RICHACL_MASKED)))
>> +             return 0;
>
> By the way, I think this is only called after checking MASKED--so the
> MASKED check here could be a WARN_ON, or could just be dropped.  Ditto
> for the following patch.

Hmm, yes. I'll drop that.

Thanks,
Andreas
