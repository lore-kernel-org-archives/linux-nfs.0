Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752808AbcHZPbP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Aug 2016 11:31:15 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>,
        "Schumaker Anna" <anna.schumaker@netapp.com>,
        "Mayhew Scott" <smayhew@redhat.com>
Subject: Re: [PATCH] Don't invalidate directory mapping until attributes
 expire
Date: Fri, 26 Aug 2016 11:31:12 -0400
Message-ID: <F98C9CB1-B2DF-47B3-846A-FEF0C81581DE@redhat.com>
In-Reply-To: <1D0703D0-AC52-4449-BA13-9E924E5DFAD8@primarydata.com>
References: <67cfa1f7f028229bfd4b1ac2619bc85b9e34ef7f.1472059583.git.bcodding@redhat.com>
 <1D0703D0-AC52-4449-BA13-9E924E5DFAD8@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> On Aug 24, 2016, at 13:27, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> Commit 311324ad1713666a6e803aecf0d4e1a136a5b34a ("NFS: Be more 
>> aggressive
>> in using readdirplus for 'ls -l' situations") removed the 
>> optimization
>> added by commit 07b5ce8ef2d87f1914054804720d6facbaa3f4ce ("NFS: Make 
>> nfs_readdir
>> revalidate less often") to bypass the revalidation of the directory 
>> mapping
>> on subsequent calls into nfs_readdir().  Add that optimization back 
>> here.
>>
>> A directory modified once every second and containing 40k entries 
>> takes my
>> system around 80 seconds to list.  With this patch, that time is 
>> reduced to
>> 7 seconds.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> fs/nfs/dir.c | 13 +------------
>> 1 file changed, 1 insertion(+), 12 deletions(-)
>>
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 19d93d0cd400..9a036dc6caa3 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -872,17 +872,6 @@ int uncached_readdir(nfs_readdir_descriptor_t 
>> *desc)
>> 	goto out;
>> }
>>
>> -static bool nfs_dir_mapping_need_revalidate(struct inode *dir)
>> -{
>> -	struct nfs_inode *nfsi = NFS_I(dir);
>> -
>> -	if (nfs_attribute_cache_expired(dir))
>> -		return true;
>> -	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
>> -		return true;
>> -	return false;
>> -}
>> -
>> /* The file offset position represents the dirent entry number.  A
>>    last cookie cache takes care of the common case of reading the
>>    whole directory.
>> @@ -914,7 +903,7 @@ static int nfs_readdir(struct file *file, struct 
>> dir_context *ctx)
>> 	desc->decode = NFS_PROTO(inode)->decode_dirent;
>> 	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
>>
>> -	if (ctx->pos == 0 || nfs_dir_mapping_need_revalidate(inode))
>> +	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
>> 		res = nfs_revalidate_mapping(inode, file->f_mapping);
>> 	if (res < 0)
>> 		goto out;
>> -- 
>> 2.5.5
>>
>
> NACK.
>
> As already discussed, this patch will break the functionality 
> introduced
> in commit 311324ad1713. You need at least to ensure that we respect
> nfs_force_use_readdirplus().

Hi Trond, I did not correctly understand the case for commit 
311324ad1713,
but re-reading the original posting thread has fixed me up.  I'll send a 
v2
that handles both cases.

Ben
