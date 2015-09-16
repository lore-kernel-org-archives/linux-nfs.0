Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34854 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbbIPVUF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 17:20:05 -0400
Received: by oiww128 with SMTP id w128so134688024oiw.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 14:20:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <08D9E2B0-B4A8-4DF0-9BB7-B19B2D260E97@oracle.com>
References: <1442429367.24127.6.camel@localhost.localdomain>
	<CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com>
	<08D9E2B0-B4A8-4DF0-9BB7-B19B2D260E97@oracle.com>
Date: Wed, 16 Sep 2015 17:20:04 -0400
Message-ID: <CAHQdGtTJdVf1UU7H=R-VdZPxT=BAKA04bB-WGbPqR38JkUpwMA@mail.gmail.com>
Subject: Re: [PATCH] Use a separate superblock if mount requires a different
 security flavor
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 16, 2015 at 4:55 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Sep 16, 2015, at 4:52 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Wed, Sep 16, 2015 at 2:49 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>>> If a server has two exports from the same filesystem but with different
>>> security flavors allowed, when the client mounts first one and then the
>>> second, the same super block was being used. This resulted in the
>>> security flavor for the first export being applied to access to the
>>> second export.
>>>
>>> The fix is simply to check the security flavor of the nfs_server
>>> temporarily constructed for the second mount within nfs_compare_super.
>>>
>>> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
>>> ---
>>> fs/nfs/super.c | 3 +++
>>> 1 file changed, 3 insertions(+)
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index 084af10..44d60f1 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct super_block
>>> *sb, void *data)
>>>        struct nfs_server *server = sb_mntdata->server, *old =
>>> NFS_SB(sb);
>>>        int mntflags = sb_mntdata->mntflags;
>>>
>>> +       if(old->client->cl_auth->au_flavor
>>> +          != server->client->cl_auth->au_flavor)
>>> +               return 0;
>>
>> Isn't this check already being performed in
>> nfs_compare_mount_options()? As far as I can see, the difference is
>> that you are checking unconditionally, whereas
>> nfs_compare_mount_options only does so if there was a 'sec=' line
>> specified in the mount options.
>
> Right. If the user doesn't provide a sec=, the security flavor
> is autonegotiated. In the case Frank describes, there are two
> directories shared on the server, each from the same FSID but
> using distinct security policies.
>
> So the mount options comparison is inadequate if no sec= is
> specified on the mount command line.

We don't claim to support autonegotiation of multiple security
policies per filesystem, in general. We only claim to support one auth
flavour per super block.

If I understand you correctly, you are knowingly trying to work around
that limitation by performing multiple mounts of the same filesystem
and force it to use multiple super blocks. Why can't you then also
specify the 'sec='?

Cheers
  Trond
