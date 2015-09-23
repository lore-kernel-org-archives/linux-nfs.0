Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:34454 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736AbbIWU3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 16:29:42 -0400
Received: by lahg1 with SMTP id g1so65041446lah.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 13:29:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923191832.GA29577@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-27-git-send-email-agruenba@redhat.com>
	<20150922191108.GC19127@fieldses.org>
	<20150923191832.GA29577@fieldses.org>
Date: Wed, 23 Sep 2015 22:29:40 +0200
Message-ID: <CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
Subject: Re: [RFC v7 26/41] richacl: Apply the file masks to a richacl
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

2015-09-23 21:18 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Tue, Sep 22, 2015 at 03:11:08PM -0400, bfields wrote:
>> user aces like owner aces what you intended to do,
>> and if so, why?
>
> That does look wrong to me; in an example like:
>
>         file owner bfields
>         mask 0700, not WRITE_THROUGH
>         bfields:rwx::allow
>
> The permission algorithm grants nothing to anyone, but it looks to me
> like richacl_apply_masks just leaves this as
>
>         bfields:rwx::allow
>
> but it would give the right result (an empty/deny-all ACL) if it weren't
> for this odd case here.

In POSIX ACLs, only the entry that best matches the process determines
the access permissions. For the file owner, this would always be the
"user::" entry, and such an entry always exists.

In richacls, permissions from multiple entries do accumulate; the
permission check algorithm does not pick a "best match". When bfields
owns a file and a "bfields:rwx::allow" entry exists, denying rwx
access to bfields would be very surprising. It makes more sense to put
user entries that match the current owner into the owner class, and
apply the owner mask instead of the group mask. This was working in an
earlier version but apparently broke at some point.

So the result that richacl_apply_masks computes here is correct, and
the permission check algorithm needs a little fix.

Thanks,
Andreas
