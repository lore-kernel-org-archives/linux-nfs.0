Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12559 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab1BBETk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Feb 2011 23:19:40 -0500
Message-ID: <4D48DB59.9010102@panasas.com>
Date: Wed, 02 Feb 2011 06:19:37 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/3] pnfs: avoid incorrect use of layout stateid
References: <1296487633-21057-1-git-send-email-iisaman@netapp.com> <1296487633-21057-2-git-send-email-iisaman@netapp.com> <4D4828DC.9020103@panasas.com> <AF70A3A4-2A06-4BD1-AC69-270658CF6365@netapp.com>
In-Reply-To: <AF70A3A4-2A06-4BD1-AC69-270658CF6365@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-01 18:31, Fred Isaman wrote:
> 
> On Feb 1, 2011, at 10:38 AM, Benny Halevy wrote:
> 
>> On 2011-01-31 17:27, Fred Isaman wrote:
>>> The code could violate the following from RFC5661, section 12.5.3:
>>> "Once a client has no more layouts on a file, the layout stateid is no
>>> longer valid and MUST NOT be used."
>>
>> NACK.
>>
>> Fred, this is your interpretation of the forgetful model and it is taken
>> out of context.
>>
>> Until the spec is changed only the server invalidates the stateid by returning
>> lrs_present=false on LAYOUTRETURN. Merely forgetting the layout state without
>> LAYOUTRETURN does not determine that.
>>
>>
>> Also from 12.5.3:
>>   Once a layout stateid is established, the "other"
>>   field will stay constant unless the stateid is revoked or the client
>>   returns all layouts on the file and the server disposes of the stateid.
>>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>
> 
> 
> OK, so the question is, does sending a LAYOUTGET with openstateid "return all layouts".
> Making the answer to this "yes" is perfectly consistent with the spec, given its complete absence
> of direction here.

I disagree, and so are other server implementations, including linux-pnfs!
(It will return BAD_STATEID if the client forgets the layout
in any case but LAYOUTRETURN or CB_LAYOUTRECALL/NOMATCHING_LAYOUT)

>  The alternative is a forgetful model where the client can forget layouts, but
> not layout stateid.

Right, and this is the direction we should go until the errata is in place.

> 
> The question is, is there any objection to the above interpretation of LAYOUTGET with openstateid?
> Because if not, then we will shortly get an appropriate errata,
> and there is no good reason to delay the patch until the errata is finalized.
> I know previously you had objected on the basis that this prevents parallel use of openstateid with LAYOUTGET.
> But given that you had indicated that such parallel use can not be done for other reasons,
> I have been working on the assumption that the interpretation above will be accepted without controversy at the upcoming IETF.
> 
> On the other hand, if there is objection to the above interpretation, that should be made known.

I simulated this with the layout-sim and given the LAYOUTGET sent with the initial stateid
is always fully serialized with other layout stateid-changing operations, this model works.

I object the timing, before the IETF discussion is over and before the upcoming Connectathon
where other server vendors have no chance to implement this erratum.

Benny

> 
> Fred
> 
> 
>> and
>>
>>   Once the client receives a layout stateid, it MUST use the correct
>>   "seqid" for subsequent LAYOUTGET or LAYOUTRETURN operations.  The
>>   correct "seqid" is defined as the highest "seqid" value from
>>   responses of fully processed LAYOUTGET or LAYOUTRETURN operations or
>>   arguments of a fully processed CB_LAYOUTRECALL operation.
>>
>> and 18.43.3
>>
>>   The loga_stateid field specifies a valid stateid.  If a layout is not
>>   currently held by the client, the loga_stateid field represents a
>>   stateid reflecting the correspondingly valid open, byte-range lock,
>>   or delegation stateid.  Once a layout is held on the file by the
>>   client, the loga_stateid field MUST be a stateid as returned from a
>>   previous LAYOUTGET or LAYOUTRETURN operation or provided by a
>>   CB_LAYOUTRECALL operation (see Section 12.5.3).
>>
>> Only when we agree that the client can throw away the layout state and
>> send a singular future LAYOUTGET with a non-layout stateid - something it MUST not
>> do at the moment - only then we can do what this patch suggests.
>>
>> Benny
>>
>>>
>>> This can occur when a layout already has a lseg, starts another
>>> non-everlapping LAYOUTGET, and a CB_LAYOUTRECALL for the existing lseg
>>> is processed before we hit pnfs_layout_process().
>>>
>>> Solve by setting, each time the client has no more lsegs for a file, a
>>> flag which blocks further use of the layout and triggers its removal.
>>>
>>> This also fixes a second bug which occurs in the same instance as
>>> above.  If we actually use pnfs_layout_process, we add the new lseg to
>>> the layout, but the layout has been removed from the nfs_client list
>>> by the intervening CB_LAYOUTRECALL and will not be added back.  Thus
>>> the newly acquired lseg will not be properly returned in the event of
>>> a subsequent CB_LAYOUTRECALL.
>>>
>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>> ---
>>> fs/nfs/pnfs.c |   12 +++++++++---
>>> 1 files changed, 9 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 1b1bc1a..dcd5d54 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -255,6 +255,9 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
>>> 			list_del_init(&lseg->pls_layout->plh_layouts);
>>> 			spin_unlock(&clp->cl_lock);
>>> 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->pls_layout->plh_flags);
>>> +			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
>>> +			/* Matched by initial refcount set in alloc_init_layout_hdr */
>>> +			put_layout_hdr_locked(lseg->pls_layout);
>>> 		}
>>> 		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
>>> 		list_add(&lseg->pls_list, tmp_list);
>>> @@ -299,6 +302,11 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>>>
>>> 	dprintk("%s:Begin lo %p\n", __func__, lo);
>>>
>>> +	if (list_empty(&lo->plh_segs)) {
>>> +		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
>>> +			put_layout_hdr_locked(lo);
>>> +		return 0;
>>> +	}
>>> 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
>>> 		if (should_free_lseg(lseg->pls_range.iomode, iomode)) {
>>> 			dprintk("%s: freeing lseg %p iomode %d "
>>> @@ -332,10 +340,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
>>> 	spin_lock(&nfsi->vfs_inode.i_lock);
>>> 	lo = nfsi->layout;
>>> 	if (lo) {
>>> -		set_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags);
>>> 		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
>>> -		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
>>> -		put_layout_hdr_locked(lo);
>>> 	}
>>> 	spin_unlock(&nfsi->vfs_inode.i_lock);
>>> 	pnfs_free_lseg_list(&tmp_list);
>>> @@ -403,6 +408,7 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
>>> 	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
>>> 		return true;
>>> 	return lo->plh_block_lgets ||
>>> +		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
>>> 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
>>> 		(list_empty(&lo->plh_segs) &&
>>> 		 (atomic_read(&lo->plh_outstanding) > lget));
> 
