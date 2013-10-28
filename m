Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:35255 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434Ab3J1XAT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 19:00:19 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/5] NFSv4: don't reprocess cached open CLAIM_PREVIOUS
Date: Mon, 28 Oct 2013 23:00:17 +0000
Message-ID: <0407795D-CE37-4DB2-AC80-6B3B978A580E@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
 <1382375414-5854-5-git-send-email-dros@netapp.com>
 <1382994502.3314.9.camel@leira.trondhjem.org>
In-Reply-To: <1382994502.3314.9.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2013, at 5:08 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
>> Cached opens have already been handled by _nfs4_opendata_reclaim_to_nfs4_state
>> and can safely skip being reprocessed, but must still call update_open_stateid
>> to make sure that all active fmodes are recovered.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c | 17 +++++++++++++----
>> 1 file changed, 13 insertions(+), 4 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8ae1589..a3b78df 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1315,12 +1315,15 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> {
>> 	struct inode *inode = data->state->inode;
>> 	struct nfs4_state *state = data->state;
>> +	bool cached_open = false;
>> 	int ret;
>> 
>> -	/* allow cached opens (!rpc_done && !rpc_status) */
>> -	if (!data->rpc_done && data->rpc_status) {
>> -		ret = data->rpc_status;
>> -		goto err;
>> +	if (!data->rpc_done) {
>> +		if (data->rpc_status) {
>> +			ret = data->rpc_status;
>> +			goto err;
>> +		} else
>> +			cached_open = true;
> 
> This too was replaced by a simplified version. Once we get rid of the
> state == NULL check, we can just replace the above with a 'goto update’

Ok - to both updates.  I guess I got a little too fancy.

-dros

> 
>> 	}
>> 
>> 	/* referenced the passed state */
>> @@ -1328,6 +1331,10 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 	if (state == NULL || !atomic_inc_not_zero(&state->count))
>> 		goto err;
>> 
>> +	/* cached opens have already been processed */
>> +	if (cached_open)
>> +		goto update;
>> +
>> 	ret = nfs_refresh_inode(inode, &data->f_attr);
>> 	if (ret)
>> 		goto err_put;
>> @@ -1336,6 +1343,8 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 
>> 	if (data->o_res.delegation_type != 0)
>> 		nfs4_opendata_check_deleg(data, state);
>> +
>> +update:
>> 	update_open_stateid(state, &data->o_res.stateid, NULL,
>> 			    data->o_arg.fmode);
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

