Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:33475 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756036AbbE2Pyt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2015 11:54:49 -0400
Received: by vnbf190 with SMTP id f190so8663450vnb.0
        for <linux-nfs@vger.kernel.org>; Fri, 29 May 2015 08:54:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHpGcMJVTS2ib9iG+Zq8eZ0iXiER88282vEHQ6g-wsO_aAxxAA@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
	<CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
	<CAHQdGtQCPqC=L1bxVzEQgwE16P6SX79c02Ex4=D02EQ5BgdGRA@mail.gmail.com>
	<CAHpGcML5eG2bQZW1j6mkHLxvAJU=ZBK+cuYEK6dTkoEsT-MVyA@mail.gmail.com>
	<CAHQdGtR-Gjp11U9JHCe6XuNiXQjYa-H7DQNycyt2H6GeQ1txSg@mail.gmail.com>
	<CAHpGcMJVTS2ib9iG+Zq8eZ0iXiER88282vEHQ6g-wsO_aAxxAA@mail.gmail.com>
Date: Fri, 29 May 2015 11:54:48 -0400
Message-ID: <CAHQdGtTiMEJHExwAa0W1dK6WZFth3Gk9nFjsKDADyJbKaXMcfw@mail.gmail.com>
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

On Fri, May 29, 2015 at 11:45 AM, Andreas Grünbacher
<andreas.gruenbacher@gmail.com> wrote:
> 2015-05-29 17:24 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>>> It seems unreasonable to me to expect applications other than special file
>>> system maintenance tools to cater to such file system differences; there are
>>> just too many file systems out there for that to work. Instead, it
>>> would be better
>>> to use an interface that can be generalized across file systems.
>>
>> My point is that system.richacl is not such an interface. It can only
>> ever work for local filesystems that understand and store local uids
>> and gids. It has no support for the remote users/groups that are
>> stored on your NFS/SMB server unless they happen to have a local
>> mapping into uids and gids, and so the API is inappropriate to replace
>> the existing NFSv4 acl API on the client.
>
> That can be changed if we find a reasonable solution.
>
>>>> The problem is that you are 100% reliant on an accurate idmapper in
>>>> order to convert the name@domain to a _correct_ uid/gid. It isn't
>>>> sufficient to convert to just any valid uid/gid, because if your ACL
>>>> tool is trying to edit the ACL, you can end up converting all those
>>>> DENY modes for user 'Johnny_Rotten@blackhats.are.us' into DENY modes
>>>> for user 'nobody'.
>>>> ...and yes, libnfsidmap will happily convert all unknown
>>>> user/groupnames into whatever uid/gid corresponds to 'nobody' without
>>>> returning an error.
>>>
>>> That's indeed a problem, and I can think of two ways of addressing it:
>>>
>>> First, acl editors need to be careful about nobody entries; they need to be
>>> aware that nobody could actually stand for somebody else. (We could map
>>> unmappable users and groups to something else than nobody, but that
>>> might just shift the problem without improve anything.)
>>
>> What is the editor supposed to do about an entry it cannot even
>> interpret, let alone store back to the server?
>
> In the end, it will have to be a user decision what to do about such entries,
> the editor can warn the user and make it harder to make mistakes though.
>
>>> Second, we could add support for passing through unmappable Who values
>>> as is. But that raises the problem of how to pass thtough and represent
>>> different kinds of identifiers: NFSv4 users user@domain and group@domain
>>> strings; smb users SIDs; maybe more.
>>
>> Now you have a mixture of some stuff that is being translated into
>> local uid/gid format and therefore needs translating back when you're
>> going to update the ACL, and some stuff that is not. What is the value
>> of doing the mapping here?
>
> If you don't translate, you cannot copy the permissions to another file
> system. In the ideal case, everything can be translated; where that fails,
> the user probably wants to know.

Why are we more worried about a hypothetical copy of the file to
another filesystem than we are about representing the ACL correctly
for the filesystem that the file is actually on? Your ACL on the
remote SMB server windows.publicserver.com may not be fully
represented when you copy the file to your local filesystem; get over
it... However if you are authorised to edit the ACL on
windows.publicserver.com, and you can't set it to something that can
be enforced correctly by windows.publicserver.com, then you have a
real problem.

Trond
