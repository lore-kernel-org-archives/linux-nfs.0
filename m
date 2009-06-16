From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [pnfs] [RFC 39/39] nfs41: Backchannel: CB_SEQUENCE validation
Date: Mon, 15 Jun 2009 17:42:32 -0700
Message-ID: <C65C3888.7CB1%ricardo.labiaga@netapp.com>
References: <1245112062.7470.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbZFPAmc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 20:42:32 -0400
In-Reply-To: <1245112062.7470.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/15/09 5:27 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2009-05-01 at 02:25 +0300, Benny Halevy wrote:
>> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> 
>> Validates the callback's sessionID, the slot number, and the sequence ID.
>> Increments the slot's sequence.
>> 
>> Detects replays, but simply prints a debug message (if debugging is enabled
>> since we don't yet implement a duplicate request cache for the backchannel.
>> This should not present a problem, since only idempotent callbacks are
>> currently implemented.
>> 
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/callback_proc.c |   75
>> ++++++++++++++++++++++++++++++++++++++++++++----
>>  1 files changed, 69 insertions(+), 6 deletions(-)
>> 
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 6b342e8..c85d66f 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -105,6 +105,57 @@ out:
>>  #if defined(CONFIG_NFS_V4_1)
>>  
>>  /*
>> + * Validate the sequenceID sent by the server.
>> + * Return success if the sequenceID is one more than what we last saw on
>> + * this slot, accounting for wraparound.  Increments the slot's sequence.
>> + *
>> + * We don't yet implement a duplicate request cache, so at this time
>> + * we will log replays, and process them as if we had not seen them before,
>> + * but we don't bump the sequence in the slot.  Not too worried about it,
>> + * since we only currently implement idempotent callbacks anyway.
>> + *
>> + * We have a single slot backchannel at this time, so we don't bother
>> + * checking the used_slots bit array on the table.  The lower layer
>> guarantees
>> + * a single outstanding callback request at a time.
>> + */
>> +static int
>> +validate_seqid(struct nfs4_slot_table *tbl, u32 slotid, u32 seqid)
>> +{
>> + struct nfs4_slot *slot;
>> +
>> + dprintk("%s enter. slotid %d seqid %d\n",
>> +  __func__, slotid, seqid);
>> +
>> + if (slotid > NFS41_BC_MAX_CALLBACKS)
>> +  return NFS4ERR_BADSLOT;
> 
> I thought we agreed to always return error values as _negative_? Why the
> change here?
> 

Will change to negative.

- ricardo

>> +
>> + slot = tbl->slots + slotid;
>> + dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
>> +
>> + /* Normal */
>> + if (likely(seqid == slot->seq_nr + 1)) {
>> +  slot->seq_nr++;
>> +  return NFS4_OK;
>> + }
>> +
>> + /* Replay */
>> + if (seqid == slot->seq_nr) {
>> +  dprintk("%s seqid %d is a replay - no DRC available\n",
>> +   __func__, seqid);
>> +  return NFS4_OK;
>> + }
>> +
>> + /* Wraparound */
>> + if (seqid == 1 && (slot->seq_nr + 1) == 0) {
>> +  slot->seq_nr = 1;
>> +  return NFS4_OK;
>> + }
>> +
>> + /* Misordered request */
>> + return NFS4ERR_SEQ_MISORDERED;
>> +}
>> +
>> +/*
>>   * Returns a pointer to a held 'struct nfs_client' that matches the server's
>>   * address, major version number, and session ID.  It is the caller's
>>   * responsibility to release the returned reference.
>> @@ -140,18 +191,27 @@ out:
>> return NULL;
>>  }
>>  
>> -/* FIXME: validate args->cbs_{sequence,slot}id */
>>  /* FIXME: referring calls should be processed */
>>  unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
>> struct cb_sequenceres *res)
>>  {
>> - int i;
>> - unsigned status = 0;
>> + struct nfs_client *clp;
>> + int i, status;
>>  
>> for (i = 0; i < args->csa_nrclists; i++)
>> kfree(args->csa_rclists[i].rcl_refcalls);
>> kfree(args->csa_rclists);
>>  
>> + status = NFS4ERR_BADSESSION;
>> + clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
>> + if (clp == NULL)
>> +  goto out;
>> +
>> + status = validate_seqid(&clp->cl_session->bc_slot_table,
>> +    args->csa_slotid, args->csa_sequenceid);
>> + if (status)
>> +  goto out_putclient;
>> +
>> memcpy(&res->csr_sessionid, &args->csa_sessionid,
>>       sizeof(res->csr_sessionid));
>> res->csr_sequenceid = args->csa_sequenceid;
>> @@ -159,9 +219,12 @@ unsigned nfs4_callback_sequence(struct cb_sequenceargs
>> *args,
>> res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
>> res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
>>  
>> - dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
>> - res->csr_status = status;
>> - return status;
>> +out_putclient:
>> + nfs_put_client(clp);
>> +out:
>> + dprintk("%s: exit with status = %d\n", __func__, status);
>> + res->csr_status = htonl(status);
>> + return res->csr_status;
>>  }
>>  
>>  #endif /* CONFIG_NFS_V4_1 */

