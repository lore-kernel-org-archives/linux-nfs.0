Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50647 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934263Ab2C3UJI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 16:09:08 -0400
Message-ID: <4F7612D0.3070600@netapp.com>
Date: Fri, 30 Mar 2012 16:08:48 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Fred Isaman <faisaman4@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] NFS: Create a single nfs_fill_super() function
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com> <1333134157-17141-2-git-send-email-bjschuma@netapp.com> <CADnza45POxTkb8zVYK_6UH2q_p5F-Eb2jko=VsjLD++VdD1GrQ@mail.gmail.com>
In-Reply-To: <CADnza45POxTkb8zVYK_6UH2q_p5F-Eb2jko=VsjLD++VdD1GrQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/12 16:06, Fred Isaman wrote:

> On Fri, Mar 30, 2012 at 3:02 PM,  <bjschuma@netapp.com> wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> This can be shared by v2, v3 and v4 in their other common code.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfs/super.c |   26 ++++++--------------------
>>  1 file changed, 6 insertions(+), 20 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 37412f7..c9bc86e 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -2135,16 +2135,18 @@ static void nfs_fill_super(struct super_block *sb,
>>
>>        sb->s_blocksize_bits = 0;
>>        sb->s_blocksize = 0;
>> -       if (data->bsize)
>> +       if (data && data->bsize)
>>                sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
>>
>> -       if (server->nfs_client->rpc_ops->version == 3) {
>> +       if (server->nfs_client->rpc_ops->version != 2) {
>>                /* The VFS shouldn't apply the umask to mode bits. We will do
>>                 * so ourselves when necessary.
>>                 */
>>                sb->s_flags |= MS_POSIXACL;
>>                sb->s_time_gran = 1;
>>        }
>> +       if (server->nfs_client->rpc_ops->version == 4)
>> +               sb->s_xattr = nfs4_xattr_handlers;
>>
>>        sb->s_op = &nfs_sops;
>>        nfs_initialise_sb(sb);
>> @@ -2520,22 +2522,6 @@ static void nfs4_clone_super(struct super_block *sb,
>>        nfs_initialise_sb(sb);
>>  }
>>
>> -/*
>> - * Set up an NFS4 superblock
>> - */
>> -static void nfs4_fill_super(struct super_block *sb)
>> -{
>> -       sb->s_time_gran = 1;
>> -       sb->s_op = &nfs4_sops;
> 
> This seems to discard nfs4_sops (with the accompanying nfs4_evict_inode).


Oops, I'll fix that... thanks for finding it!

- Bryan

> 
> Fred


