Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41662 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab2E1QFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:05:18 -0400
Received: by wgbdr13 with SMTP id dr13so3075164wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 09:05:17 -0700 (PDT)
Message-ID: <4FC3A235.8090908@tonian.com>
Date: Mon, 28 May 2012 19:05:09 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com>
In-Reply-To: <4FBE3C4D.7050507@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-24 16:49, Boaz Harrosh wrote:
> On 05/24/2012 03:41 PM, Benny Halevy wrote:
> 
>> On 2012-05-24 03:16, Boaz Harrosh wrote:
>>>
>>> Benny hi
>>>
>>> If I remember/understand correctly, there is a mode in the RFC errata
>>> about the layout forgetful-model and a client sending a layout_get with
>>> an open_state_id after he already had previous state (layouts) on the file.
>>>
>>> As I understood this is an indication to the server that client has
>>> "forgotten" all it's layouts on a file, and Server can assume their
>>> return.
>>>
>>> Is my understanding correct?
>>
>> Yes
>>
>>>
>>> If Yes:
>>> 	Did we implement the internal return of all layouts, if above
>>> 	open_state_id is encountered?
>>> 	I thought we did but I can't find this code.
>>
>> True.  This is not implemented yet.
>>
>>>
>>> Currently, I always set ROC so there is no leak. But theoretically
>>> ROC does not have to be set. I'm doing some heavy lifting of
>>> layout_return, and I want to make sure I have not missed a spot.
>>>
>>> If I'm correct that it is needed, and it's missing:
>>> My suggestion for now is that we always set ROC, disregarding FS so not to
>>> leak layouts and therefor inode-refs, until such time that we implement it.
>>
>> According to the new errata the server will have to simulate layout returns in the ROC
>> case on last CLOSE if the (forgetful) client did not explicitly return the layout.
>> This is not implemented either :-(
>>
> 
> 
> Yes Benny it is implemented. I implemented it and you fix a bug I had. See:
> 	nfs4pnfsd.c::pnfsd_roc(...) 
> and it's call site. It is called on last call and all is working well (except some locking
> bugs I'll send a fix to later). Otherwise both exofs and DF would have crapped out for sure.

Duh, you're right of course.

> 
> With ROC set all work well. This is why I say we should set it for now to make sure we do
> not have the above bug.

Yup, see patchset in reply.

Thanks!

Benny

> 
> Thanks
> Boaz
> 
>> Benny
>>
>>>
>>> Thanks
>>> Boaz
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
