Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219AbcGZQao (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2016 12:30:44 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Tue, 26 Jul 2016 12:32:26 -0400
Message-ID: <10749CC8-F76E-4DBD-9C27-9802475CF8A5@redhat.com>
In-Reply-To: <F5EFC301-6372-4993-82BA-C96455F3957E@redhat.com>
References: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
 <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
 <C44AB0DD-8FA3-42F2-B7DE-C694559A68EF@primarydata.com>
 <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
 <20160721082216.GA15247@infradead.org>
 <A540F5A1-37B3-40EB-876D-EC33E891F0C9@redhat.com>
 <B4719B7F-3FC4-4FD7-929E-CC528CA867F4@redhat.com>
 <9E2543EF-0442-491E-AB22-3E1667DABBA4@redhat.com>
 <E33497F6-079C-4903-9CC5-0ABDFA149694@primarydata.com>
 <70375D08-FCA9-4C73-9991-38490C11B171@redhat.com>
 <8B8BB73D-39A6-4291-A10E-736B0F907459@primarydata.com>
 <C7773DBC-C4D9-4DA4-9391-8B7E91D7D5AF@redhat.com>
 <B174B540-8D12-4BD1-8DD0-FE49E2AB216E@primarydata.com>
 <AAB7FE0A-8409-494D-8CCF-BE07442791F3@redhat.com>
 <737F0071-AAD2-49B5-9BD0-02DF98049B76@primarydata.com>
 <F5EFC301-6372-4993-82BA-C96455F3957E@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25 Jul 2016, at 14:41, Benjamin Coddington wrote:

> On 25 Jul 2016, at 14:34, Trond Myklebust wrote:
>
>>> On Jul 25, 2016, at 14:26, Benjamin Coddington <bcodding@redhat.com> 
>>> wrote:
>>>
>>>
>>>
>>> On 25 Jul 2016, at 12:39, Trond Myklebust wrote:
>>>
>>>>> On Jul 25, 2016, at 12:26, Benjamin Coddington 
>>>>> <bcodding@redhat.com> wrote:
>>>>>
>>>>> On 21 Jul 2016, at 9:20, Trond Myklebust wrote:
>>>>>
>>>>>>> On Jul 21, 2016, at 09:05, Benjamin Coddington 
>>>>>>> <bcodding@redhat.com> wrote:
>>>>>>>
>>>>>>> So back to Christoph's point earlier:
>>>>>>>
>>>>>>> On 17 Jul 2016, at 23:48, Christoph Hellwig wrote:
>>>>>>>> This one breaks xfstests generic/207 on block/scsi layout for 
>>>>>>>> me.  The
>>>>>>>> reason for that is that we need a layoutcommit after writing 
>>>>>>>> out all
>>>>>>>> data for the file for the file size to be updated on the 
>>>>>>>> server.
>>>>>>>
>>>>>>> You responded:
>>>>>>>
>>>>>>> On 18 Jul 2016, at 0:32, Trond Myklebust wrote:
>>>>>>>> I’m not understanding this argument. Why do we care if the 
>>>>>>>> file size is up
>>>>>>>> to date on the server if we’re not sending an actual GETATTR 
>>>>>>>> on the wire
>>>>>>>> to retrieve the file size?
>>>>>>>
>>>>>>> I guess the answer might be because we can get it back from the 
>>>>>>> last
>>>>>>> LAYOUTCOMMIT.
>>>>>>>
>>>>>>
>>>>>> The patch that I followed up with should now ensure that we do 
>>>>>> not mark the attribute cache as up to date if there is a 
>>>>>> LAYOUTCOMMIT pending.
>>>>>> IOW: when the pNFS write is done, it is expected to do 2 things:
>>>>>>
>>>>>> 1) mark the inode for LAYOUTCOMMIT
>>>>>> 2) mark the attribute cache as invalid (because we know the 
>>>>>> change attribute, mtime, ctime need to be updates)
>>>>>>
>>>>>> In the case of blocks pNFS write:
>>>>>> The call to pnfs_set_layoutcommit() in pnfs_ld_write_done() 
>>>>>> should take care of (1)
>>>>>> The call to nfs_writeback_update_inode() in nfs4_write_done_cb() 
>>>>>> should take care of (2).
>>>>>>
>>>>>> Provided that these 2 calls are performed in the above order, 
>>>>>> then any call to nfs_getattr() which has not been preceded by a 
>>>>>> call to nfs4_proc_layoutcommit() should trigger the call to 
>>>>>> __nfs_revalidate_inode().
>>>>>
>>>>> I think the problem is that a following nfs_getattr() will fail to 
>>>>> notice
>>>>> the size change in the case of a write_completion and layoutcommit 
>>>>> occuring
>>>>> after nfs_getattr() has done pnfs_sync_inode() but before it has 
>>>>> done
>>>>> nfs_update_inode().
>>>>>
>>>>> In the failing case there are two threads one is doing writes, the 
>>>>> other
>>>>> doing lstat on aio_complete via io_getevents(2).
>>>>>
>>>>> For each write completion the lstat thread tries to verify the 
>>>>> file size.
>>>>>
>>>>> GETATTR Thread                  LAYOUTCOMMIT Thread
>>>>> --------------                  --------------------
>>>>>                               write_completion sets LAYOUTCOMMIT 
>>>>> (4096@0)
>>>>> --> nfs_getattr
>>>>
>>>> filemap_write_and_wait()
>>>>
>>>>> __nfs_revalidate_inode
>>>>> pnfs_sync_inode
>>>>
>>>> NFS_PROTO(inode)->getattr()
>>>>
>>>>> getattr sees 4096
>>>>>                               write_completion sets LAYOUTCOMMIT 
>>>>> (4096@4096)
>>>>>                               sets LAYOUTCOMMITING
>>>>>                               clears LAYOUTCOMMIT
>>>>>                               clears LAYOUTCOMMITTING
>>>>> nfs_refresh_inode
>>>>>  nfs_update_inode size is 4096
>>>>> <-- nfs_getattr
>>>>>
>>>>> At this point the cached attributes are seen as up to date, but
>>>>> aio-dio-extend-stat program expects that second write_completion 
>>>>> to reflect
>>>>> in the file size.
>>>>>
>>>>
>>>> Why isn’t the filemap_write_and_wait() above resolving the race? 
>>>> I’d
>>>> expect that would move your “write completion sets 
>>>> LAYOUTCOMMIT” up to
>>>> before the pnfs_sync_inode().  In fact, in the patch that Christoph 
>>>> sent,
>>>> all he was doing was moving the pnfs_sync_inode() to immediately 
>>>> after
>>>> that filemap_write_and_wait() instead of relying on it in
>>>> _nfs_revalidate_inode.
>>>
>>> This is O_DIRECT, I've failed to mention yet.  The second write 
>>> hasn't made
>>> it out of __nfs_pageio_add_request() at the time 
>>> filemap_write_and_wait() is
>>> called.  It is sleeping in pnfs_update_layout() waiting on a 
>>> LAYOUTGET and it
>>> doesn't resumes until after filemap_write_and_wait().
>>
>> Wait, so you have 1 thread doing an O_DIRECT write() and another 
>> doing a
>> stat() in parallel? Why would there be an expectation that the 
>> filesystem
>> should serialise those system calls?
>
> Not exactly parallel, but synchronized on aio_complete.  A comment in
> generic/207's src/aio-dio-regress/aio-dio-extend-stat.c:
>
>  36 /*
>  37  * This was originally submitted to
>  38  * http://bugzilla.kernel.org/show_bug.cgi?id=6831 by
>  39  * Rafal Wijata <wijata@nec-labs.com>.  It caught a race in dio 
> aio completion
>  40  * that would call aio_complete() before the dio callers would 
> update i_size.
>  41  * A stat after io_getevents() would not see the new file size.
>  42  *
>  43  * The bug was fixed in the fs/direct-io.c completion reworking 
> that appeared
>  44  * in 2.6.20.  This test should fail on 2.6.19.
>  45  */
>
> As far as I can see, this check is the whole point of generic/207..

This would fix it up:

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f108d58101f8..823700f827b6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -661,6 +661,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry
*dentry, struct kstat *stat)

         trace_nfs_getattr_enter(inode);
         /* Flush out writes to the server in order to update c/mtime.  
*/
+       nfs_start_io_read(inode);
         if (S_ISREG(inode->i_mode)) {
                 err = filemap_write_and_wait(inode->i_mapping);
                 if (err)
@@ -694,6 +695,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry
*dentry, struct kstat *stat)
                         stat->blksize = NFS_SERVER(inode)->dtsize;
         }
  out:
+       nfs_end_io_read(inode);
         trace_nfs_getattr_exit(inode, err);
         return err;
  }

Trond, what do you think?  I'll take any additional silence as a sign to 
go
elsewhere.  :P

Ben
