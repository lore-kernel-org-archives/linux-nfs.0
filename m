Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f49.google.com ([209.85.216.49]:33322 "EHLO
	mail-vn0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233AbbE2PY7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2015 11:24:59 -0400
Received: by vnbf190 with SMTP id f190so8560211vnb.0
        for <linux-nfs@vger.kernel.org>; Fri, 29 May 2015 08:24:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHpGcML5eG2bQZW1j6mkHLxvAJU=ZBK+cuYEK6dTkoEsT-MVyA@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
	<CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
	<CAHQdGtQCPqC=L1bxVzEQgwE16P6SX79c02Ex4=D02EQ5BgdGRA@mail.gmail.com>
	<CAHpGcML5eG2bQZW1j6mkHLxvAJU=ZBK+cuYEK6dTkoEsT-MVyA@mail.gmail.com>
Date: Fri, 29 May 2015 11:24:58 -0400
Message-ID: <CAHQdGtR-Gjp11U9JHCe6XuNiXQjYa-H7DQNycyt2H6GeQ1txSg@mail.gmail.com>
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding linux-api...

On Fri, May 29, 2015 at 11:00 AM, Andreas Grünbacher
<andreas.gruenbacher@gmail.com> wrote:
> 2015-05-29 15:15 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>> [reply reordered]
>> So having revisited the reasons why I chose the system.nfs4_acl
>> interface when we did NFSv4 ACLs, I'm not sure we should implement
>> system.richacl for the NFS client at all.
>>
>> Your assertion that "when symbolic user@domain and group@domain names
>> are used in the acl, user-space needs to perform ID mapping in the
>> same way as the kernel"  is WRONG. User space needs do no such thing,
>> and that was the whole point of the interface; to allow the user to
>> specify ACLs in a format that is checked only on the _server_, and not
>> on the client.
>
> That's only half true. Right now, user-space applications trying to copy
> permissions between an nfs mount and another file system will fail unless the
> application has explicitly been made nfs aware and supports the
> "system.nfs4_acl"
> attribute (as well as some other acl mechanism if the permissions go beyond the
> file mode).
>
> The same problem exists when trying to make sense of acls.
>
> It seems unreasonable to me to expect applications other than special file
> system maintenance tools to cater to such file system differences; there are
> just too many file systems out there for that to work. Instead, it
> would be better
> to use an interface that can be generalized across file systems.

My point is that system.richacl is not such an interface. It can only
ever work for local filesystems that understand and store local uids
and gids. It has no support for the remote users/groups that are
stored on your NFS/SMB server unless they happen to have a local
mapping into uids and gids, and so the API is inappropriate to replace
the existing NFSv4 acl API on the client.

>> The problem is that you are 100% reliant on an accurate idmapper in
>> order to convert the name@domain to a _correct_ uid/gid. It isn't
>> sufficient to convert to just any valid uid/gid, because if your ACL
>> tool is trying to edit the ACL, you can end up converting all those
>> DENY modes for user 'Johnny_Rotten@blackhats.are.us' into DENY modes
>> for user 'nobody'.
>> ...and yes, libnfsidmap will happily convert all unknown
>> user/groupnames into whatever uid/gid corresponds to 'nobody' without
>> returning an error.
>
> That's indeed a problem, and I can think of two ways of addressing it:
>
> First, acl editors need to be careful about nobody entries; they need to be
> aware that nobody could actually stand for somebody else. (We could map
> unmappable users and groups to something else than nobody, but that
> might just shift the problem without improve anything.)

What is the editor supposed to do about an entry it cannot even
interpret, let alone store back to the server?

> Second, we could add support for passing through unmappable Who values
> as is. But that raises the problem of how to pass thtough and represent
> different kinds of identifiers: NFSv4 users user@domain and group@domain
> strings; smb users SIDs; maybe more.
>

Now you have a mixture of some stuff that is being translated into
local uid/gid format and therefore needs translating back when you're
going to update the ACL, and some stuff that is not. What is the value
of doing the mapping here?

Trond
