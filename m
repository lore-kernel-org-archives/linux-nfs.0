Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbcGUOBQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 10:01:16 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "List Linux" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Thu, 21 Jul 2016 10:02:53 -0400
Message-ID: <782E3BB3-481A-423B-AE32-22A5E30805DB@redhat.com>
In-Reply-To: <8B8BB73D-39A6-4291-A10E-736B0F907459@primarydata.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 Jul 2016, at 9:20, Trond Myklebust wrote:

>> On Jul 21, 2016, at 09:05, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> So back to Christoph's point earlier:
>>
>> On 17 Jul 2016, at 23:48, Christoph Hellwig wrote:
>>> This one breaks xfstests generic/207 on block/scsi layout for me.  
>>> The
>>> reason for that is that we need a layoutcommit after writing out all
>>> data for the file for the file size to be updated on the server.
>>
>> You responded:
>>
>> On 18 Jul 2016, at 0:32, Trond Myklebust wrote:
>>> I’m not understanding this argument. Why do we care if the file 
>>> size is up
>>> to date on the server if we’re not sending an actual GETATTR on 
>>> the wire
>>> to retrieve the file size?
>>
>> I guess the answer might be because we can get it back from the last
>> LAYOUTCOMMIT.
>>
>
> The patch that I followed up with should now ensure that we do not 
> mark the attribute cache as up to date if there is a LAYOUTCOMMIT 
> pending.
> IOW: when the pNFS write is done, it is expected to do 2 things:
>
> 1) mark the inode for LAYOUTCOMMIT
> 2) mark the attribute cache as invalid (because we know the change 
> attribute, mtime, ctime need to be updates)
>
> In the case of blocks pNFS write:
> The call to pnfs_set_layoutcommit() in pnfs_ld_write_done() should 
> take care of (1)
> The call to nfs_writeback_update_inode() in nfs4_write_done_cb() 
> should take care of (2).
>
> Provided that these 2 calls are performed in the above order, then any 
> call to nfs_getattr() which has not been preceded by a call to 
> nfs4_proc_layoutcommit() should trigger the call to 
> __nfs_revalidate_inode().

OK, so maybe things are out of order here..  Thanks - this is helpful.

>> This test has repeated appending 4k and has this pattern on the wire:
>>
>> NFS 334 V4 Call LAYOUTGET
>> NFS 290 V4 Reply (Call In 854) LAYOUTCOMMIT
>> NFS 294 V4 Call GETATTR FH: 0x4f5528b0
>> NFS 442 V4 Reply (Call In 858) GETATTR
>> NFS 374 V4 Call LAYOUTCOMMIT
>> NFS 314 V4 Reply (Call In 856) LAYOUTGET
>> NFS 334 V4 Call LAYOUTGET
>> NFS 290 V4 Reply (Call In 860) LAYOUTCOMMIT
>> NFS 294 V4 Call GETATTR FH: 0x4f5528b0
>> NFS 442 V4 Reply (Call In 864) GETATTR
>> NFS 374 V4 Call LAYOUTCOMMIT
>> NFS 314 V4 Reply (Call In 862) LAYOUTGET
>> NFS 334 V4 Call LAYOUTGET
>> NFS 290 V4 Reply (Call In 866) LAYOUTCOMMIT
>> NFS 294 V4 Call GETATTR FH: 0x4f5528b0
>> NFS 442 V4 Reply (Call In 870) GETATTR
>> NFS 314 V4 Reply (Call In 868) LAYOUTGET
>> NFS 374 V4 Call LAYOUTCOMMIT
>> NFS 290 V4 Reply (Call In 874) LAYOUTCOMMIT
>> NFS 314 V4 Call CLOSE StateID: 0x54d9
>> NFS 294 V4 Reply (Call In 876) CLOSE
>>
>> That last LAYOUTCOMMIT and the CLOSE have the size we want.  The 
>> previous
>> GETATTR is 4k short.
>
> When you say “4k short”, do you mean that it differs from the 
> value returned by the LAYOUTCOMMIT that immediately precedes it? It 
> looks as if there is a LAYOUTGET immediately following it, so 
> presumably the writes have not all completed yet.

I meant it is 4k short of the final size returned in the LAYOUTCOMMIT
immediately following.  It is the same as the LAYOUTCOMMIT immediately
preceding.

FWIW at this point, here's a better look at the network:

tshark -r /tmp/pcap -T fields -e frame.number -e nfs.fh.hash -e 
nfs.opcode -e nfs.fattr4.size 'frame.number > 860'
861     53,22,50
862 0x4f5528b0  53,22,50
863     53,22,49,9  409600
864 0x4f5528b0  53,22,9
865     53,22,9 409600
866 0x4f5528b0  53,22,49,9
867     53,22,50
868 0x4f5528b0  53,22,50
869     53,22,49,9  413696
870 0x4f5528b0  53,22,9
871     53,22,9 413696
872     53,22,50
873
874 0x4f5528b0  53,22,49,9
875     53,22,49,9  417792
876 0x4f5528b0  53,22,4,9
877     53,22,4,9   417792
...
880 0x4f5528b0  53,22,9
881     53,22,9 417792

Now I see there's a GETATTR after the CLOSE that returns the right size 
-- but
I'll really should track down what's happening to that one to see if it 
is the
same call that the test is making.  Unfortunately, I'm getting pulled 
away
again, so I'll dig more later.  Thanks for looking.

Ben

