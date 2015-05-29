Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f48.google.com ([209.85.216.48]:37429 "EHLO
	mail-vn0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbbE2NPI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2015 09:15:08 -0400
Received: by vnbg190 with SMTP id g190so8109617vnb.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 May 2015 06:15:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
	<CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
Date: Fri, 29 May 2015 09:15:07 -0400
Message-ID: <CAHQdGtQCPqC=L1bxVzEQgwE16P6SX79c02Ex4=D02EQ5BgdGRA@mail.gmail.com>
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2015 at 7:06 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Fri, Apr 24, 2015 at 7:04 AM, Andreas Gruenbacher
> <andreas.gruenbacher@gmail.com> wrote:
>> Changes nfs to support the "system.richacl" xattr instead of "system.nfs4_acl".
>>
>
> NACK.
>
> You may declare a userspace syscall ABI that is more than 10 years old
> to be deprecated, but you are not allowed to remove it.
>

So having revisited the reasons why I chose the system.nfs4_acl
interface when we did NFSv4 ACLs, I'm not sure we should implement
system.richacl for the NFS client at all.

The problem is that you are 100% reliant on an accurate idmapper in
order to convert the name@domain to a _correct_ uid/gid. It isn't
sufficient to convert to just any valid uid/gid, because if your ACL
tool is trying to edit the ACL, you can end up converting all those
DENY modes for user 'Johnny_Rotten@blackhats.are.us' into DENY modes
for user 'nobody'.
...and yes, libnfsidmap will happily convert all unknown
user/groupnames into whatever uid/gid corresponds to 'nobody' without
returning an error.

Your assertion that "when symbolic user@domain and group@domain names
are used in the acl, user-space needs to perform ID mapping in the
same way as the kernel"  is WRONG. User space needs do no such thing,
and that was the whole point of the interface; to allow the user to
specify ACLs in a format that is checked only on the _server_, and not
on the client.

Trond
