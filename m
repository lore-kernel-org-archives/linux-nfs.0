Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45941 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbbIPUzO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 16:55:14 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] Use a separate superblock if mount requires a different security flavor
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com>
Date: Wed, 16 Sep 2015 16:55:04 -0400
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <08D9E2B0-B4A8-4DF0-9BB7-B19B2D260E97@oracle.com>
References: <1442429367.24127.6.camel@localhost.localdomain> <CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 16, 2015, at 4:52 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Sep 16, 2015 at 2:49 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>> If a server has two exports from the same filesystem but with different
>> security flavors allowed, when the client mounts first one and then the
>> second, the same super block was being used. This resulted in the
>> security flavor for the first export being applied to access to the
>> second export.
>> 
>> The fix is simply to check the security flavor of the nfs_server
>> temporarily constructed for the second mount within nfs_compare_super.
>> 
>> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
>> ---
>> fs/nfs/super.c | 3 +++
>> 1 file changed, 3 insertions(+)
>> 
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 084af10..44d60f1 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct super_block
>> *sb, void *data)
>>        struct nfs_server *server = sb_mntdata->server, *old =
>> NFS_SB(sb);
>>        int mntflags = sb_mntdata->mntflags;
>> 
>> +       if(old->client->cl_auth->au_flavor
>> +          != server->client->cl_auth->au_flavor)
>> +               return 0;
> 
> Isn't this check already being performed in
> nfs_compare_mount_options()? As far as I can see, the difference is
> that you are checking unconditionally, whereas
> nfs_compare_mount_options only does so if there was a 'sec=' line
> specified in the mount options.

Right. If the user doesn't provide a sec=, the security flavor
is autonegotiated. In the case Frank describes, there are two
directories shared on the server, each from the same FSID but
using distinct security policies.

So the mount options comparison is inadequate if no sec= is
specified on the mount command line.

--
Chuck Lever



