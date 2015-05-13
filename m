Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35068 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbbEMUWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 16:22:21 -0400
MIME-Version: 1.0
In-Reply-To: <0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
Date: Wed, 13 May 2015 22:22:21 +0200
Message-ID: <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-13 20:01 GMT+02:00 Frank Filz <ffilzlnx@mindspring.com>:
> You might want to edit your commit message to use RICHACL_ instead of ACL4_
> constants...

Indeed, thanks.

>> Linux does not have a way of creating files without setting the file permission
>> bits, so all files created inside a directory with ACL4_AUTO_INHERIT set will
>> also have the ACL4_PROTECTED flag set.  This effectively disables Automatic
>> Inheritance.
>>
>> Protocols which support creating files without specifying permissions can
>> explicitly clear the ACL4_PROTECTED flag after creating a file and reset the file
>> masks to "undo" applying the create mode; see
>> richacl_compute_max_masks().
>> This is a workaround; a mechanism that would allow a process to indicate to
>> the kernel to ignore the create mode when there are inherited permissions
>> would fix this problem.
>
> I'm unclear what will actually be supported for inherited ACLs here. Is this
> saying that on a pure-Linux system even with Linux NFS client and Linux NFS
> server, we still would not see inheritance since the mode will always be
> present on create?

What do you mean by "we still would not see inheritance"? Inheritance
at file create time will still happen; a few extra flags will be set
when Automatic Inheritance is "on" in the parent directory as
indicated by the RICHACL_AUTO_INHERIT flag.

Files are inevitably created with defined permissions (the mode
parameter to system calls like creat and mkdir), which means that the
RICHACL_PROTECTED flag needs to be set, though. When someone changes
the permissions of an entire directory tree, that change will not
propagate to or below files with the protected flag set.

That being said, a daemon like Samba can "fake" full Automatic
Inheritance by creating files and then updating the inherited acls
appropriately. This will inevitably be racy, but unless someone
implements a way to create files without a mode, that's the closest
Samba can get.

Creating files atomically with explicitly defined acls is another
operation which NFSv4 does but the Linux kernel does not support.

> My interest here is in how we will tie the Ganesha user space NFS server
> into this feature.

I don't know, what do you currently do when somebody creates a file
without defining the permissions (mode, acl or dacl)? That's the
relevant case. The kernel nfs daemon currently creates a file with
mode 0 --- which doesn't seem right.

Andreas
