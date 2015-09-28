Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37570 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933063AbbI1RKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 13:10:08 -0400
MIME-Version: 1.0
In-Reply-To: <20150928163543.GF1358@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20150928163543.GF1358@fieldses.org>
Date: Mon, 28 Sep 2015 19:10:06 +0200
Message-ID: <CAHpGcM++=D1yrkVmZsKwdQCQj4yPdwGGNbmF-Bma7Yo_+kpNQQ@mail.gmail.com>
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

2015-09-28 18:35 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
>> here's another update of the richacl patch queue.  At this stage, I would
>> like to ask for final feedback so that the core and ext4 code (patches
>> 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
>> then go through the respective maintainer trees.
>
> I've been over the core richacl and nfsd parts very carefully, and they
> definitely look ready to me.

Thanks a lot for all that work, by the way.

>> Changes since the last posting (https://lwn.net/Articles/656704/):
>>
>> * The MAY_DELETE_SELF permission now also overrides the sticky
>>    directory checks.
>>
>> * Fix the permission check algorithm to apply the owner mask instead
>>   of the group mask to user entries matching the current owner. That way,
>>   the owner will retain the permissions in those entries when creating
>>   objects with create mode 0700 and similar. (A chmod to mode 0700 already
>>   creates an owner@:rwpx::allow ace, which was hiding this bug.)
>>
>> * Fix richacl_apply_masks to properly insert deny aces when raising the
>>   permissions of the other class. The bug could be triggered by
>>   chmod'ing a group@:r::allow acl to mode 0077, for example.
>>
>> * Various cleanups and improvements to comments.
>>
>>
>> The complete patch queue is available here:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
>>           richacl-2015-09-28
>>
>>
>> The richacl user-space utilitites and test suite are available here:
>>
>>   https://github.com/andreas-gruenbacher/richacl/
>>
>>
>> Open issues in nfs:
>>
>> * When a user or group name cannot be mapped, nfs's idmapper always maps it
>>   to nobody. That's good enough for mapping the file owner and owning
>>   group, but not for identifiers in acls. For now, to get the nfs richacl
>>   support somewhat working, I'm explicitly checking if mapping has resulted
>>   in uid/gid 99 in the kernel.
>>
>> * When the nfs server replies with NFS4ERR_BADNAME for any user or group
>>   name lookup, the client will stop sending numeric uids and gids to the
>>   server even when the lookup wasn't numeric.  From then on, the client
>>   will translate uids and gids that have no mapping to the string "nobody",
>>   and the server will reject them.  This problem is not specific to acls.
>
> Do you have fixes in mind for these two issues?

I'm not sure how to best fix the idmapper problem, with backwards
compatibility and all. The second problem shouldn't be too hard to
fix.

Thanks,
Andreas
