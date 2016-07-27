Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754160AbcG0QMs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2016 12:12:48 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Wed, 27 Jul 2016 12:14:32 -0400
Message-ID: <CFD74F0F-5375-4C05-8918-516F730FDBA7@redhat.com>
In-Reply-To: <06BBFA63-02D9-4BDE-A61D-14FE9F4E9E5F@primarydata.com>
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
 <10749CC8-F76E-4DBD-9C27-9802475CF8A5@redhat.com>
 <3448E968-3564-43C1-ADBB-A16C9687B0F3@primarydata.com>
 <4CA4361B-2501-48AA-8B2C-715E5A3FD35C@redhat.com>
 <DA6506A7-57F0-4263-BA23-0BB638BC2E36@primarydata.com>
 <7EEB460E-F197-4B68-BBD1-7EEF16B77A71@redhat.com>
 <455341C5-F202-4FA7-8A9B-7AA73CFA21CF@primarydata.com>
 <06BBFA63-02D9-4BDE-A61D-14FE9F4E9E5F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 27 Jul 2016, at 8:31, Trond Myklebust wrote:

>> On Jul 27, 2016, at 08:15, Trond Myklebust <trondmy@primarydata.com> 
>> wrote:
>>
>>
>>> On Jul 27, 2016, at 07:55, Benjamin Coddington <bcodding@redhat.com> 
>>> wrote:
>>>
>>> After adding more debugging, I see that all of that is working 
>>> correctly,
>>> but the first LAYOUTCOMMIT is taking the size back down to 4096 from 
>>> the
>>> last nfs_writeback_done(), and the second LAYOUTCOMMIT never brings 
>>> it back
>>> up again.
>>>
>>
>> Excellent! Thanks for debugging that.
>>
>>> Now I see that we should be marking the block extents as written 
>>> atomically with
>>> setting LAYOUTCOMMIT and nfsi->layout->plh_lwb, otherwise a 
>>> LAYOUTCOMMIT can
>>> collect extents just added from the next bl_write_cleanup().  Then, 
>>> the next
>>> LAYOUTCOMMIT fails, and all we're left with is the size from the 
>>> first
>>> LAYOUTCOMMIT.  Not sure if that particular problem is the whole fix, 
>>> but
>>> that's something to work on.
>>>
>>> I see ways to fix that:
>>>
>>>   - make a new pnfs_set_layoutcommit_locked() that can be used to 
>>> call
>>>     ext_tree_mark_written() inside the i_lock
>>>
>>>   - make another pnfs_layoutdriver_type operation to be used within
>>>     pnfs_set_layoutcommit (mark_layoutcommit? set_layoutcommit?), 
>>> and call
>>>     ext_tree_mark_written() within that..
>>>
>>>   - have .prepare_layoutcommit return a new positive plh_lwb that 
>>> would
>>>     extend the current LAYOUTCOMMIT
>>>
>>>   - make ext_tree_prepare_commit only encode up to plh_lwb
>>
>> I see no reason why ext_tree_prepare_commit() shouldn’t be allowed 
>> to extend the args->lastbytewritten. This is a metadata operation 
>> that is owned by the pNFS layout driver.
>> The only thing I’d note is you should then rewrite the failure case 
>> in pnfs_layoutcommit_inode() so that it doesn’t rely on the saved 
>> “end_pos”, but uses args->lastbytewritten instead (with a comment 
>> to the effect why)…
>
> In fact, given the potential for races here, I think the right thing 
> to do is to have ext_tree_prepare_commit() always set the correct 
> value for args->lastbytewritten.

OK, that has cleared up that common failure case that was getting in the
way, but now it can still fail like this:

nfs_writeback_update_inode sets size 4096 w/ NFS_INO_INVALID_ATTR set, 
and sets NFS_INO_LAYOUTCOMMIT
1st nfs_getattr -> pnfs_layoutcommit_inode starts, clears layoutcommit 
flag sets NFS_INO_LAYOUTCOMMITING
nfs_writeback_update_inode sets size 8192 w/ NFS_INO_INVALID_ATTR set, 
and sets NFS_INO_LAYOUTCOMMIT
1st nfs_getattr -> nfs4_layoutcommit_release sets size 4096, 
NFS_INO_INVALID_ATTR set, clears NFS_INO_LAYOUTCOMMITTING
1st nfs_getattr -> __revalidate_inode sets size 4096, 
NFS_INO_INVALID_ATTR not set.. cache is valid
2nd nfs_getattr immediately returns 4096 even though 
NFS_INO_LAYOUTCOMMIT

Ben
