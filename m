Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:33920 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761004Ab2FGPLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 11:11:14 -0400
Message-ID: <4FD0C48E.6090204@oracle.com>
Date: Thu, 07 Jun 2012 11:11:10 -0400
From: Chuck Lever <chuck.lever@oracle.com>
MIME-Version: 1.0
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Fix a commit bug
References: <1338936204-20168-1-git-send-email-Trond.Myklebust@netapp.com> <73EB71C8-FD1B-4508-8474-D87C9B7312EC@netapp.com> <ABEA57CF-6358-4FFE-9CB6-35F9CD2616B8@oracle.com> <83708AA1-F4C9-4D44-B153-50B2EC2CB4B9@netapp.com>
In-Reply-To: <83708AA1-F4C9-4D44-B153-50B2EC2CB4B9@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 11:08 AM, Adamson, Dros wrote:
> On Jun 7, 2012, at 11:05 AM, Chuck Lever wrote:
>
>> This does not appear to fix the problem I'm seeing.
>>
>> With this patch applied, the client is silly renaming the file, deleting it, then writing it again and failing with NFS4ERR_STALE.
> What command(s) are you running?

Connectathon basic test 5.


>
> -dros
>
>> I had to apply the change by hand, so I could have missed something.  I'll go back and check.
>>
>> On Jun 6, 2012, at 9:59 AM, Adamson, Dros wrote:
>>
>>> ACK - This fixes the problem I was seeing!
>>>
>>> For the list, we were seeing duplicate writes sent to unstable servers even though the COMMIT succeeds (with matching verf):
>>>
>>> - mount a server that returns writes with committed = UNSTABLE4
>>> - run "dd if=/dev/zero of=/mnt/foo bs=1024 count=10240"
>>> - umount
>>> - in wireshark, you'll see the COMMIT succeed, but after a short pause there will be a flurry of FILE_SYNC4 writes that are duplicates (same ranges, data) of the writes associated with the COMMIT.
>>>
>>> -dros
>>>
>>> On Jun 5, 2012, at 6:43 PM, Trond Myklebust wrote:
>>>
>>>> The new commit code fails to copy the verifier into the wb_verf field
>>>> of _all_ the nfs_page structures; it only copies it into the first entry.
>>>> The consequence is that most requests end up failing to match in
>>>> nfs_commit_release.
>>>>
>>>> Fix is to copy the verifier into the req->wb_verf field in
>>>> nfs_write_completion.
>>>>
>>>> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
>>>> Cc: Fred Isaman<iisaman@netapp.com>
>>>> ---
>>>> fs/nfs/direct.c         |    4 ++--
>>>> fs/nfs/write.c          |    7 ++++---
>>>> include/linux/nfs_xdr.h |    2 ++
>>>> 3 files changed, 8 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>>> index 23d170b..b5385a7 100644
>>>> --- a/fs/nfs/direct.c
>>>> +++ b/fs/nfs/direct.c
>>>> @@ -710,12 +710,12 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>> 			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
>>>> 				bit = NFS_IOHDR_NEED_RESCHED;
>>>> 			else if (dreq->flags == 0) {
>>>> -				memcpy(&dreq->verf,&req->wb_verf,
>>>> +				memcpy(&dreq->verf, hdr->verf,
>>>> 				       sizeof(dreq->verf));
>>>> 				bit = NFS_IOHDR_NEED_COMMIT;
>>>> 				dreq->flags = NFS_ODIRECT_DO_COMMIT;
>>>> 			} else if (dreq->flags == NFS_ODIRECT_DO_COMMIT) {
>>>> -				if (memcmp(&dreq->verf,&req->wb_verf, sizeof(dreq->verf))) {
>>>> +				if (memcmp(&dreq->verf, hdr->verf, sizeof(dreq->verf))) {
>>>> 					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
>>>> 					bit = NFS_IOHDR_NEED_RESCHED;
>>>> 				} else
>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>> index e6fe3d6..4d6861c 100644
>>>> --- a/fs/nfs/write.c
>>>> +++ b/fs/nfs/write.c
>>>> @@ -80,6 +80,7 @@ struct nfs_write_header *nfs_writehdr_alloc(void)
>>>> 		INIT_LIST_HEAD(&hdr->rpc_list);
>>>> 		spin_lock_init(&hdr->lock);
>>>> 		atomic_set(&hdr->refcnt, 0);
>>>> +		hdr->verf =&p->verf;
>>>> 	}
>>>> 	return p;
>>>> }
>>>> @@ -619,6 +620,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>>>> 			goto next;
>>>> 		}
>>>> 		if (test_bit(NFS_IOHDR_NEED_COMMIT,&hdr->flags)) {
>>>> +			memcpy(&req->wb_verf, hdr->verf, sizeof(req->wb_verf));
>>>> 			nfs_mark_request_commit(req, hdr->lseg,&cinfo);
>>>> 			goto next;
>>>> 		}
>>>> @@ -1255,15 +1257,14 @@ static void nfs_writeback_release_common(void *calldata)
>>>> 	struct nfs_write_data	*data = calldata;
>>>> 	struct nfs_pgio_header *hdr = data->header;
>>>> 	int status = data->task.tk_status;
>>>> -	struct nfs_page *req = hdr->req;
>>>>
>>>> 	if ((status>= 0)&&  nfs_write_need_commit(data)) {
>>>> 		spin_lock(&hdr->lock);
>>>> 		if (test_bit(NFS_IOHDR_NEED_RESCHED,&hdr->flags))
>>>> 			; /* Do nothing */
>>>> 		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT,&hdr->flags))
>>>> -			memcpy(&req->wb_verf,&data->verf, sizeof(req->wb_verf));
>>>> -		else if (memcmp(&req->wb_verf,&data->verf, sizeof(req->wb_verf)))
>>>> +			memcpy(hdr->verf,&data->verf, sizeof(*hdr->verf));
>>>> +		else if (memcmp(hdr->verf,&data->verf, sizeof(*hdr->verf)))
>>>> 			set_bit(NFS_IOHDR_NEED_RESCHED,&hdr->flags);
>>>> 		spin_unlock(&hdr->lock);
>>>> 	}
>>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>>> index 7519bae..8aadd90 100644
>>>> --- a/include/linux/nfs_xdr.h
>>>> +++ b/include/linux/nfs_xdr.h
>>>> @@ -1237,6 +1237,7 @@ struct nfs_pgio_header {
>>>> 	struct list_head	rpc_list;
>>>> 	atomic_t		refcnt;
>>>> 	struct nfs_page		*req;
>>>> +	struct nfs_writeverf	*verf;
>>>> 	struct pnfs_layout_segment *lseg;
>>>> 	loff_t			io_start;
>>>> 	const struct rpc_call_ops *mds_ops;
>>>> @@ -1274,6 +1275,7 @@ struct nfs_write_data {
>>>> struct nfs_write_header {
>>>> 	struct nfs_pgio_header	header;
>>>> 	struct nfs_write_data	rpc_data;
>>>> +	struct nfs_writeverf	verf;
>>>> };
>>>>
>>>> struct nfs_mds_commit_info {
>>>> -- 
>>>> 1.7.10.2
>>>>
>> ---
>> Chuck Lever
>> chuck [dot] lever [at] oracle [dot] com
>>
>>
>>
>>

