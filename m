Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078Ab3HFSEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 14:04:22 -0400
Message-ID: <52013A9D.4010905@RedHat.com>
Date: Tue, 06 Aug 2013 14:04:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Julia Lawall <Julia.Lawall@lip6.fr>,
        David Quigley <dpquigl@davequigley.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] fs/nfs/inode.c: adjust code alignment
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>  <1375714059-29567-2-git-send-email-Julia.Lawall@lip6.fr> <1375714793.7337.12.camel@leira.trondhjem.org>
In-Reply-To: <1375714793.7337.12.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 05/08/13 10:59, Myklebust, Trond wrote:
> On Mon, 2013-08-05 at 16:47 +0200, Julia Lawall wrote:
>> From: Julia Lawall <Julia.Lawall@lip6.fr>
>>
>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>>
>> ---
>>
>> This patch adjusts the code so that the alignment matches the current
>> semantics.  I have no idea if it is the intended semantics, though.  Should
>> the call to nfs_setsecurity also be under the else?
>>
> 
>>  fs/nfs/inode.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index af6e806..d8ad685 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -463,7 +463,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh
>> *fh, struct nfs_fattr *fattr, st
>>                 unlock_new_inode(inode);
>>         } else
>>                 nfs_refresh_inode(inode, fattr);
>> -               nfs_setsecurity(inode, fattr, label);
>> +       nfs_setsecurity(inode, fattr, label);
This call to nfs_setsecurity() is not needed. The security only needs
to be set when the i-node is created... 

steved.

>>         dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
>>                 inode->i_sb->s_id,
>>                 (long long)NFS_FILEID(inode),
> 
> Hi Julia,
> 
> Thanks for pointing this out! Given that the 'then' clause of the if
> statement already calls nfs_setsecurity before unlocking the inode, I
> suspect that the above _should_ really be part of the 'else' clause. 
> 
> That said, I can't see that calling nfs_setsecurity twice on the inode
> can cause any unintended side-effects, so I suggest that we rather queue
> the patch up for inclusion in 3.12.
> Steve and Dave, any comments?
> 
