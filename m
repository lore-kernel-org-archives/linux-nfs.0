Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33596 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbJPSMk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 14:12:40 -0400
Received: by lffv3 with SMTP id v3so83754497lff.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 11:12:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHpGcMKfNewTJOL0ono8kCDoU8YZvxGfuLe3XP6VCGKuZL3mnA@mail.gmail.com>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20150928163543.GF1358@fieldses.org>
	<CAHpGcM++=D1yrkVmZsKwdQCQj4yPdwGGNbmF-Bma7Yo_+kpNQQ@mail.gmail.com>
	<20150928174648.GA3190@fieldses.org>
	<CAHpGcMKfNewTJOL0ono8kCDoU8YZvxGfuLe3XP6VCGKuZL3mnA@mail.gmail.com>
Date: Fri, 16 Oct 2015 20:12:38 +0200
Message-ID: <CAHc6FU4rE0Tf9Lfr3wD-+y3GCaiExtZn1onz0E56zDumjXw+3Q@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 29, 2015 at 4:54 PM, Andreas Grünbacher
<andreas.gruenbacher@gmail.com> wrote:
> 2015-09-28 19:46 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> On Mon, Sep 28, 2015 at 07:10:06PM +0200, Andreas Grünbacher wrote:
>>> 2015-09-28 18:35 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>>> > On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
>>> >> Open issues in nfs:
>>> >>
>>> >> * When a user or group name cannot be mapped, nfs's idmapper always maps it
>>> >>   to nobody. That's good enough for mapping the file owner and owning
>>> >>   group, but not for identifiers in acls. For now, to get the nfs richacl
>>> >>   support somewhat working, I'm explicitly checking if mapping has resulted
>>> >>   in uid/gid 99 in the kernel.
>>> >>
>>> >> * When the nfs server replies with NFS4ERR_BADNAME for any user or group
>>> >>   name lookup, the client will stop sending numeric uids and gids to the
>>> >>   server even when the lookup wasn't numeric.  From then on, the client
>>> >>   will translate uids and gids that have no mapping to the string "nobody",
>>> >>   and the server will reject them.  This problem is not specific to acls.
>>> >
>>> > Do you have fixes in mind for these two issues?
>>>
>>> I'm not sure how to best fix the idmapper problem, with backwards
>>> compatibility and all.
>>
>> I haven't looked at the current nfsidmap interface....  So it's
>> completely lacking any way to communicate failure?
>
> Yes, when a user doesn't exist, idmapper maps that to the nobody
> uid/gid. That's the failure mode of stat. In the acl case, we do want
> to map user and group names to their respective ids where possible (so
> that the acl makes sense in the local system context), but we do want
> to preserve the original user and group names when there is no such
> mapping instead of mapping to the nobody uid/gid.

So that's fixed now in nfs-utils and the latest richacl snapshot.

>>> The second problem shouldn't be too hard to fix.
>>
>> Is it enough to turn off the failover in the case there's no possibility
>> it could have been caused by a numeric id?
>
> Yes, I believe that would be enough.
>
>> If any user can set ACLs with arbitrary strings as names, then we'd be
>> giving any user unprivileged user the ability to turn off numeric
>> idmapping, so I think we need to fix that.
>
> The bug can be triggered by unprivileged users with nfs4_setfacl.

It turns out that when setting an ACL, the ACL can contain UID/GID
numbers as well as user@domain strings which the server cannot map.
The status code is NFS4ERR_BADNAME both when the server doesn't
support UID/GID numbers and when it cannot map a name, so in that
case, we cannot tell the difference.

Luckily, when a UID/GID cannot be mapped to a name, nfs falls back to
sending the server a UID/GID number instead even when
NFS_CAP_UIDGID_NOMAP has been cleared. So unprivileged users can turn
on the idmapper, but at least that doesn't break unmapped UIDs/GIDs.
(I got that wrong in my initial analysis.)

Thanks,
Andreas
