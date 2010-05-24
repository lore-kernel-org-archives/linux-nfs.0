From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
 	rpc_cred
Date: Mon, 24 May 2010 21:20:55 +0300
Message-ID: <4BFAC387.6010202@panasas.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>	 <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>	 <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN@mail.gmail.com>	 <AANLkTinvXyrrqR7YpkLOUAJ890oTBdQCgQuNXD9o3gk-@mail.gmail.com>	 <AANLkTikvP2aetI4bF-3ebus1Y91qFV4ahCXfxR_5ZNBN@mail.gmail.com>	 <AANLkTik-l_9nhBGWv-C8FKz9Aq99uP7-AWSi_uB4YDBG@mail.gmail.com> <AANLkTikCKm-ogV0byN2LSxAoYVFWPujpF3iKe7qlOTIY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tao Guo <glorioustao@gmail.com>, bhalevy@panasas.com,
	linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57146 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754343Ab0EXSU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 14:20:59 -0400
In-Reply-To: <AANLkTikCKm-ogV0byN2LSxAoYVFWPujpF3iKe7qlOTIY-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/2010 08:25 PM, William A. (Andy) Adamson wrote:
> On Mon, May 24, 2010 at 12:02 PM, Tao Guo <glorioustao@gmail.com> wrote:
>> On Mon, May 24, 2010 at 9:43 PM, William A. (Andy) Adamson
>> <androsadamson@gmail.com> wrote:
>>> On Mon, May 24, 2010 at 2:37 AM, Tao Guo <glorioustao@gmail.com> wrote:
>>>> I see... But what if sync == 1? At that time, data must have already
>>>> been freed, so you should not use data->cred anymore.
>>>
>>> Agreed.
>>>
>>> Since LAYOUTCOMMIT is not called after close, we can get rid of taking
>>> the reference all together since a reference is taken on OPEN and
>>> dropped on CLOSE.
> 
> I forgot memory mapped files where writes can occur after the close,
> and so layoutcommit can also occur after the close. So, I will keep
> the get_rpccred in pnfs_need_layout commit and resend this patch with
> the put_rpccred in the layoutcommit done routine.
> 

Andy I get hangs on:
       data->is_sync = sync;
        status = pnfs4_proc_layoutcommit(data);
 +       put_rpccred(data->cred);

with sync==1 like Tao Guo said

could you send the updated patch?

Boaz

>>>
>>> -->Andy
>> I agree. However that will change several functions' interface I guess.
>>
>> I still have a question: why some procedures need to set rpc_cred
>> whereas some needn't ? what is the connection between ctx's rpc_cred
>> and nfs4_state_owner's so_cred? Any guidance will be appreciated...
> 
> Here's my take on an answer...
> 
> If an rpc_cred is not specified in the rpc_msg then the fsuid, fsgid,
> and group info toe the  current_cred is used to lookup an rpc_cred.
> RPC's can be sent from several tasks - rpciod vrs the application task
> for example. OPEN, CLOSE, LOCK, UNLOCK, READ, WRITE (and memmapped
> I/O) should all be sent with the credential that opened the file. So,
> in order to ensure this the nfs4_state_owner->so_cred is used for
> these compounds even if the task is rpciod with root fsuid/fsgid. The
> nfs_open_context rpc_cred is the nfs4_state_owner so_cred. The
> nfs_open_context can exist longer than the nfs4_state_owner.
> 
> I think LAYOUTCOMMIT also wants to use the credential that did the I/O
> - not for the file layout driver which doesn't care, but for the
> object and block layout drivers that use the layout as a lock and
> where a permissions check (?) is done on LAYOUTCOMMIT.
> 
> Currently, LAYOUTGET and LAYOUTRETURN don't set the rpc_cred. This is
> because the layout can last past opens and closes. If we ever want to
> support EXCHGID4_FLAG_BIND_PRINC_STATEID we will need to remember the
> cred and set it for these calls.
> 
> -->Andy
> 
> 
> 
>>
>>>>
>>>> --
>>>> tao.
>>>>
>>>
>>
>>
>>
>> --
>> tao.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

