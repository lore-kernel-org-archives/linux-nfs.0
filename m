Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:36281 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbbIWWOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 18:14:41 -0400
Received: by lacao8 with SMTP id ao8so44176449lac.3
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 15:14:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923210531.GC29349@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-27-git-send-email-agruenba@redhat.com>
	<20150922191108.GC19127@fieldses.org>
	<20150923191832.GA29577@fieldses.org>
	<CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
	<20150923203357.GC30521@fieldses.org>
	<CAHc6FU4Jh=-K5=DBERP3-vv8Sak4XGjVJgJ85mTeyPiApUhz+g@mail.gmail.com>
	<20150923210531.GC29349@fieldses.org>
Date: Thu, 24 Sep 2015 00:14:40 +0200
Message-ID: <CAHc6FU7W-oLTOqBxmzAOY5mM37-J6NcnXrhm2SnoDXqHBJbhRQ@mail.gmail.com>
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

2015-09-23 23:05 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Wed, Sep 23, 2015 at 10:40:18PM +0200, Andreas Gruenbacher wrote:
>> 2015-09-23 22:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> > The same could be said if there's a group-i-belong-to:rwx::allow entry,
>> > do we make that exception too?
>>
>> We cannot because that would be incorrect for all other group members.
>
> OK.  So people have to learn how the group mask works anyway, and now
> they have to learn a special exception to that rule.
>
> I don't like having this exception.  Or making the richacl->v4acl
> translation dependent on the owner.
>
> But I admit it's surprising to that an 0700 mask with
> "bfields:rwx::allow" ACL denies access to a bfields-owned file.

I fully understand your point. This kind of acl is one of the the
first things people will try, and nobody is going to accept when
access is denied in this case though.

Things are made worse by the fact that Windows has the concept of
owner@ or group@ entries for inheritable permissions but not for
effective ones; it will always produce and expect "bfields:rwx::allow"
type entries instead of "owner@:rwx::allow" type entries. I'm not sure
if Samba could bridge that gap.

The fact that we cannot handle entries for groups the owner is in in a
similar way is not a big deal; it's not surprising that changing the
group file mode permission bits affects group entries.

Thanks,
Andreas
