Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44397 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab2BTPrY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 10:47:24 -0500
Received: by daed14 with SMTP id d14so5882061dae.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 07:47:23 -0800 (PST)
Message-ID: <4F426B07.1080804@tonian.com>
Date: Mon, 20 Feb 2012 07:47:19 -0800
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT,
 why_no_deleg
References: <4F3D4F1F.6080502@tonian.com> <1329418637-23925-1-git-send-email-bhalevy@tonian.com> <20120217221411.GA3627@fieldses.org> <4F3F5B30.3000501@tonian.com> <20120218144103.GA7997@fieldses.org>
In-Reply-To: <20120218144103.GA7997@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-18 06:41, J. Bruce Fields wrote:
> On Sat, Feb 18, 2012 at 10:02:56AM +0200, Benny Halevy wrote:
>> On 2012-02-18 00:14, J. Bruce Fields wrote:
>>> On Thu, Feb 16, 2012 at 08:57:17PM +0200, Benny Halevy wrote:
>>>> Respect client request for not getting a delegation in NFSv4.1
>>>> Appropriately return delegation "type" NFS4_OPEN_DELEGATE_NONE_EXT
>>>> and WND4_NOT_WANTED reason.
>>>
>>> These all look fine, just two nits:
>>>
>>>> @@ -2903,11 +2903,32 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
>>>>  	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
>>>>  		STATEID_VAL(&dp->dl_stid.sc_stateid));
>>>>  out:
>>>> -	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
>>>> -			&& flag == NFS4_OPEN_DELEGATE_NONE
>>>> -			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
>>>> -		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
>>>>  	open->op_delegate_type = flag;
>>>> +	if (flag == NFS4_OPEN_DELEGATE_NONE) {
>>>> +		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
>>>> +		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
>>>> +			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
>>>> +
>>>> +		if (open->op_deleg_want) {
>>>> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
>>>> +			if (status == -EAGAIN)
>>>> +				open->op_why_no_deleg = WND4_CONTENTION;
>>>> +			else {
>>>> +				open->op_why_no_deleg = WND4_RESOURCE;
>>>> +				switch (open->op_deleg_want) {
>>>> +				case NFS4_SHARE_WANT_READ_DELEG:
>>>> +				case NFS4_SHARE_WANT_WRITE_DELEG:
>>>> +				case NFS4_SHARE_WANT_ANY_DELEG:
>>>> +					break;
>>>> +				case NFS4_SHARE_WANT_CANCEL:
>>>> +					open->op_why_no_deleg = WND4_CANCELLED;
>>>> +					break;
>>>> +				case NFS4_SHARE_WANT_NO_DELEG:
>>>> +					BUG();	/* not supposed to get here */
>>>> +				}
>>>> +			}
>>>> +		}
>>>> +	}
>>>
>>> This looks like a reasonably well-encapsulated bit of code--could you
>>> move it into a helper function?
>>>
>>>>  out:
>>>> +	/* 4.1 client trying to upgrade/downgrade delegation? */
>>>> +	if (open->op_delegate_type == NFS4_OPEN_DELEGATE_NONE && dp &&
>>>> +	    open->op_deleg_want) {
>>>> +		if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
>>>> +		    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
>>>> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
>>>> +			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
>>>> +		} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
>>>> +			   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
>>>> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
>>>> +			open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
>>>> +		}
>>>> +		/* Otherwise the client must be confused wanting a delegation
>>>> +		 * it already has, therefore we don't return
>>>> +		 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
>>>> +		 */
>>>> +	}
>>>
>>> Ditto for this.
>>>
>>> I'll go ahead and apply the previous two patches pending some regression
>>> tests.
>>
>> Thanks!
>> I'm sending two additional patches that refactor these two helpers and add
>> some documentation to the commit message.
>>
>> I think it might be helpful to keep them separated but let me know otherwise
>> and I'll send a squashed patch instead.
> 
> Either way's fine.  What I've got so far is pushed out to
> 
> 	git://linux-nfs.org/~bfields/linux.git for-3.4

Good. So the missing patches are:
http://marc.info/?l=linux-nfs&m=132941866004294&w=2
http://marc.info/?l=linux-nfs&m=132955306211255&w=2
http://marc.info/?l=linux-nfs&m=132955306211256&w=2

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
