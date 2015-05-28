Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:36019 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170AbbE1X3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:29:39 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
	<CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
Date: Fri, 29 May 2015 01:29:38 +0200
Message-ID: <CAHpGcMLmhK7sy0Z=nLGm1aDr0NZWjiA6SnuRkWh5AU6=6=VCCQ@mail.gmail.com>
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-29 1:06 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> On Fri, Apr 24, 2015 at 7:04 AM, Andreas Gruenbacher
> <andreas.gruenbacher@gmail.com> wrote:
>> Changes nfs to support the "system.richacl" xattr instead of "system.nfs4_acl".
>>
>
> NACK.
>
> You may declare a userspace syscall ABI that is more than 10 years old
> to be deprecated, but you are not allowed to remove it.

Okay, we can have "system.nfs4_acl" as well, it's just extra code.

> Furthermore, your entire premise of using the mode bits and the acl at
> the same time is flawed; you are at best trying to set up a private
> protocol to pass your mask info. According to RFC7530, Section
> 6.4.1.3, if you try to send the mode bits and ACL in the same SETATTR,
> then the result should be to apply the mode first, then override all
> the lower mode bits (i.e. everything except the suid, sgid and ) with
> the ACL...

What do you mean? I'm happy with the behavior described in Section
6.4.1.3 of RFC 7530; I'm not using the mode bits and the acl at the same
time. What makes you think otherwise?

Thanks,
Andreas
