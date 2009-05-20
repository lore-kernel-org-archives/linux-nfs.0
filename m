From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [RFC 06/11] nfsd41: Backchannel: Add sequence arguments to
 callback RPC arguments
Date: Wed, 20 May 2009 11:05:15 -0700
Message-ID: <C639946B.625D%ricardo.labiaga@netapp.com>
References: <4A13B219.2020101@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <bfields@fieldses.org>, <pnfs@linux-nfs.org>,
	<linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30101 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754955AbZETSFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 14:05:47 -0400
In-Reply-To: <4A13B219.2020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/20/09 12:32 AM, "Benny Halevy" <bhalevy@panasas.com> wrote:

> On May. 20, 2009, 6:00 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> wrote:
>> Follow the model we use in the client. Make the sequence arguments
>> part of the regular RPC arguments.  The results point to them.  Adjust
>> references to the sequence arguments.
>> 
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> [define struct nfsd4_cb_sequence here]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4callback.c     |    9 +++++++++
>>  include/linux/nfsd/state.h |    9 +++++++++
>>  2 files changed, 18 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>> index f75750e..0b5c4a6 100644
>> --- a/fs/nfsd/nfs4callback.c
>> +++ b/fs/nfsd/nfs4callback.c
>> @@ -92,6 +92,15 @@ enum nfs_cb_opnum4 {
>> cb_sequence_dec_sz +            \
>> op_dec_sz)
>>  
>> +struct nfs4_rpc_args {
>> + void    *args_op;
>> + struct nfsd4_cb_sequence args_seq;
>> +};
>> +
>> +struct nfs4_rpc_res {
>> + struct nfsd4_cb_sequence *res_seq;
> 
> Given the size of nfsd4_cb_sequence, why not just embed it here?

nfs4_rpc_res->res_seq will simply point to nfs4_rpc_args.args_seq.  During
decode we only need to verify the return values are the same, as what we
sent, so I don't see the need to have a separate copy.  That's why the args
have the actual structure, but the results only a pointer.

- ricardo

> (Historically, it didn't have the cbs_minorversion member so
> it's presence was the actual indication of the minorversion.
> Now that this has changed, I see no good reason not to embed it.
> 
> Benny
> 
>> +};
>> +
>>  /*
>>  * Generic encode routines from fs/nfs/nfs4xdr.c
>>  */
>> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
>> index 212a75b..931aaa6 100644
>> --- a/include/linux/nfsd/state.h
>> +++ b/include/linux/nfsd/state.h
>> @@ -61,6 +61,12 @@ typedef struct {
>>  #define si_stateownerid   si_opaque.so_stateownerid
>>  #define si_fileid         si_opaque.so_fileid
>>  
>> +struct nfsd4_cb_sequence {
>> + /* args/res */
>> + u32   cbs_minorversion;
>> + struct nfs4_client *cbs_clp;
>> +};
>> +
>>  struct nfs4_delegation {
>> struct list_head dl_perfile;
>> struct list_head dl_perclnt;
>> @@ -188,6 +194,9 @@ struct nfs4_client {
>> struct nfsd4_slot cl_slot; /* create_session slot */
>> u32   cl_exchange_flags;
>> struct nfs4_sessionid cl_sessionid;
>> +
>> + /* for nfs41 callbacks */
>> + struct svc_xprt  *cl_cb_xprt; /* 4.1 callback transport */
>>  };
>>  
>>  /* struct nfs4_client_reset

