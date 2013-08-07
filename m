Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:45172 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756566Ab3HGCFA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 22:05:00 -0400
Message-ID: <5201A9B7.1010605@davequigley.com>
Date: Tue, 06 Aug 2013 21:58:15 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] fs/nfs/inode.c: adjust code alignment
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>  <1375714059-29567-2-git-send-email-Julia.Lawall@lip6.fr> <1375714793.7337.12.camel@leira.trondhjem.org> <52013A9D.4010905@RedHat.com>
In-Reply-To: <52013A9D.4010905@RedHat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/6/2013 2:04 PM, Steve Dickson wrote:
> Hello,
>
> On 05/08/13 10:59, Myklebust, Trond wrote:
>> On Mon, 2013-08-05 at 16:47 +0200, Julia Lawall wrote:
>>> From: Julia Lawall <Julia.Lawall@lip6.fr>
>>>
>>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>>>
>>> ---
>>>
>>> This patch adjusts the code so that the alignment matches the current
>>> semantics.  I have no idea if it is the intended semantics, though.  Should
>>> the call to nfs_setsecurity also be under the else?
>>>
>>
>>>   fs/nfs/inode.c |    2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index af6e806..d8ad685 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -463,7 +463,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh
>>> *fh, struct nfs_fattr *fattr, st
>>>                  unlock_new_inode(inode);
>>>          } else
>>>                  nfs_refresh_inode(inode, fattr);
>>> -               nfs_setsecurity(inode, fattr, label);
>>> +       nfs_setsecurity(inode, fattr, label);
> This call to nfs_setsecurity() is not needed. The security only needs
> to be set when the i-node is created...
>
> steved.
>
>>>          dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
>>>                  inode->i_sb->s_id,
>>>                  (long long)NFS_FILEID(inode),
>>
>> Hi Julia,
>>
>> Thanks for pointing this out! Given that the 'then' clause of the if
>> statement already calls nfs_setsecurity before unlocking the inode, I
>> suspect that the above _should_ really be part of the 'else' clause.
>>
>> That said, I can't see that calling nfs_setsecurity twice on the inode
>> can cause any unintended side-effects, so I suggest that we rather queue
>> the patch up for inclusion in 3.12.
>> Steve and Dave, any comments?
>>
>

I can't see why it would be needed either. I agree with Steve. We can 
get rid of it.

Dave
