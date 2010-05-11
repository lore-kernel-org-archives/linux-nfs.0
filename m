Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32510 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757403Ab0EKIqv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 04:46:51 -0400
Message-ID: <4BE91973.60505@panasas.com>
Date: Tue, 11 May 2010 11:46:43 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver
 private data
References: <4BE3166F.7060800@panasas.com> <1273173832-27786-1-git-send-email-bhalevy@panasas.com> <4BE6E1E0.8020706@panasas.com> <CC482AF1-FEF0-4D01-A307-4CE5751F7689@netapp.com>
In-Reply-To: <CC482AF1-FEF0-4D01-A307-4CE5751F7689@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/10/2010 05:24 PM, Andy Adamson wrote:
> 
> On May 9, 2010, at 12:25 PM, Boaz Harrosh wrote:
> 
>> On 05/06/2010 10:23 PM, Benny Halevy wrote:
>>> Temporary relief until we convert to use generic device cache.
>>>
>>
>> [In short]
>> Rrrr, No! This is a complete crash. The private data is per-server but
>> is called per super-block. In the case of two mounts of same "server",
>> the user of this will:
>> - Leak a device cache on second mount
>> - Crash after close of first super block.
>>
>> [The long story]
>> I'm commenting here for the complete series Andy's and Benny included.
>>
>> What Andy tried to do was move the per super-block device cache to a
>> per "server" device cache. (This is the per server struct at the NFS
>> client side not to be confused with an NFS-server what so ever). This
>> is because as mandated by the Protocol each device id uniqueness is
>> governed by a per-server-per-client-per-layoput_type, so multiple
>> mounts can share the device-cache and save resources. The old code
>> of per-mount-point was correct only not optimal.
>>
>> But he did not finish his job. Because he still calls the device
>> cache initialization at per-mount-point init. - 
>>> initialize_mountpoint is
>> called from set_pnfs_layoutdriver() which is called with a super-block
>> per mount-point. He went to grate length (I hope, I did not check) to
>> make sure only the first mount, allocates the cache, and the last  
>> mount
>> destroys it.
>>
>> But otherwise he noticed (and Benny tried to help) that now
>> initialize_mountpoint is per-server, and not per-sb. Hence the pointer
>> to struct server.
>>
>> So the old code is now a layering violation and hence the mix-up and  
>> the bug
> 
>>
>> - If it is a per-server? name it ->initialize_server() receiving  
>> server
>>  pointer, No?
>>

What about the name ?

>> - If it is a per-server then shift the all set_pnfs_layoutdriver() to
>>  be called once per-server construction (At the server constructor  
>> code)
> 
> set_pnfs_layoutdriver checks to see if nfs_server->pnfs_curr_ld is set.

Yes set_pnfs_layoutdriver does, again a layering violation in my opinion.
However ->uninitialize_mountpoint() is still called for every sb-unmount
how useful is that? (at super.c nfs4_kill_super)

It is very simple really.

- ->initialize_server() is called from nfs_server_set_fsinfo() for every
  mount the check should be there. If you need it that late? Perhaps it could
  be called earlier at nfs_init_server()?

- Call ->uninitialize_server() from nfs_free_server(). And all is well.


- Give me a void* at server to keep my stuff.

> Put the private pointer into struct pnfs_layoutdriver_type and your  
> problem will be solved.
> 

No pnfs_layoutdriver_type is global. I might as well just put it at
the data_segment. I wanted a per mount. Willing to compromise on per server

> -->Andy
> 

OK I finally read the code. and forget everything I said!

So current code is one big bug in regard to filelayout_uninitialize_mountpoint
called for every nfs4_kill_super and the destruction of the cache.

Struct server has nothing to do with it. it is just on the way to receive
the struct *client* pointer. (My god the server/client relationships in 
Linux-nfs-client I still don't understand it).

So everything I said above but exchange the name "server" with *"client"*

And most importantly. YOU DO NOT NEED THE REFERENCE COUNTS. (right, there
are two)

if you stick the device-cache on the lifetime of the client structure
then:
- There will not be any super-blocks alive before/after a particular client
  dies. (right? sb->ref->server->ref->client)
- There will not be any inodes alive after a super-blocks dies, hence any
  IOs nor any layouts.

So a device cache is what you said it is per client structure no more no
less. No?

(I can't find the last version of patches you sent to the mailing list
 I wanted to comment on them (Sorry for the delay was busy). I'll look
 in Benny's git I hope he did not squash them yet. And will comment
 on that)

Boaz

>>  then you don't need to sync in multiple places the initialization/ 
>> destruction
>>  of sb(s) vs. servers vs device-caches. Server struct life-cycle  
>> will govern that.
>>
>> Accommodating future needs:
>> - In objects layout (In code not yet released) I have a per-super- 
>> block: pages-
>>  cache-pool, raid-engine governing struct, and some other raid  
>> related information.
>>  I use per-super-block because this is the most natural In the Linux  
>> VFS API. So
>>  global stuff per super-block directly pointed by every inode for  
>> easy (random)
>>  access at every API level. I could shift this to be per-server in  
>> NFS-client. I surly
>>  don't want it global, (Rrrrr) and per-inode is two small. I will  
>> need to work harder
>>  to optimize for the extra contention (or maybe not).
>>
>>  So the per-server model is fine, I guess, but don't let me slave  
>> over a broken API that
>>  forces me to duplicate lifetime rules of things that are already  
>> taken care of, only
>>  not seen by the layout driver.
>>
>>  If moving to a per-server model then some current structures  
>> referencing and pointing
>>  could change to remove the SB from the picture and directly point  
>> to server.
>>
>> I know this is lots of work and who's going to do it, but I was not  
>> the one who suggested
>> the optimization in the first place. A per-SB is some much easier  
>> because of the Linux
>> environment we live in, but if we do it, it must be done right.
>>
>> Boaz
>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> include/linux/nfs_fs_sb.h |    1 +
>>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>>> index cad56a7..00a4e7e 100644
>>> --- a/include/linux/nfs_fs_sb.h
>>> +++ b/include/linux/nfs_fs_sb.h
>>> @@ -164,6 +164,7 @@ struct nfs_server {
>>>
>>> #ifdef CONFIG_NFS_V4_1
>>> 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout  
>>> driver */
>>> +	void			       *pnfs_ld_data; /* Per-mount data */
>>> 	unsigned int			ds_rsize;  /* Data server read size */
>>> 	unsigned int			ds_wsize;  /* Data server write size */
>>> #endif /* CONFIG_NFS_V4_1 */
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

