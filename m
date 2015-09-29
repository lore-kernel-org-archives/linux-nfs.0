Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35251 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbbI2Oyj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 10:54:39 -0400
MIME-Version: 1.0
In-Reply-To: <20150928174648.GA3190@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20150928163543.GF1358@fieldses.org>
	<CAHpGcM++=D1yrkVmZsKwdQCQj4yPdwGGNbmF-Bma7Yo_+kpNQQ@mail.gmail.com>
	<20150928174648.GA3190@fieldses.org>
Date: Tue, 29 Sep 2015 16:54:37 +0200
Message-ID: <CAHpGcMKfNewTJOL0ono8kCDoU8YZvxGfuLe3XP6VCGKuZL3mnA@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-28 19:46 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Sep 28, 2015 at 07:10:06PM +0200, Andreas Grünbacher wrote:
>> 2015-09-28 18:35 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> > On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
>> >> Open issues in nfs:
>> >>
>> >> * When a user or group name cannot be mapped, nfs's idmapper always maps it
>> >>   to nobody. That's good enough for mapping the file owner and owning
>> >>   group, but not for identifiers in acls. For now, to get the nfs richacl
>> >>   support somewhat working, I'm explicitly checking if mapping has resulted
>> >>   in uid/gid 99 in the kernel.
>> >>
>> >> * When the nfs server replies with NFS4ERR_BADNAME for any user or group
>> >>   name lookup, the client will stop sending numeric uids and gids to the
>> >>   server even when the lookup wasn't numeric.  From then on, the client
>> >>   will translate uids and gids that have no mapping to the string "nobody",
>> >>   and the server will reject them.  This problem is not specific to acls.
>> >
>> > Do you have fixes in mind for these two issues?
>>
>> I'm not sure how to best fix the idmapper problem, with backwards
>> compatibility and all.
>
> I haven't looked at the current nfsidmap interface....  So it's
> completely lacking any way to communicate failure?

Yes, when a user doesn't exist, idmapper maps that to the nobody
uid/gid. That's the failure mode of stat. In the acl case, we do want
to map user and group names to their respective ids where possible (so
that the acl makes sense in the local system context), but we do want
to preserve the original user and group names when there is no such
mapping instead of mapping to the nobody uid/gid.

>> The second problem shouldn't be too hard to fix.
>
> Is it enough to turn off the failover in the case there's no possibility
> it could have been caused by a numeric id?

Yes, I believe that would be enough.

> If any user can set ACLs with arbitrary strings as names, then we'd be
> giving any user unprivileged user the ability to turn off numeric
> idmapping, so I think we need to fix that.

The bug can be triggered by unprivileged users with nfs4_setfacl.

Thanks,
Andreas
