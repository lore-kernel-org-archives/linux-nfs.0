Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55880 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab2E1SKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 14:10:03 -0400
Message-ID: <4FC3BF67.7010402@panasas.com>
Date: Mon, 28 May 2012 21:09:43 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com> <4FC3A235.8090908@tonian.com> <4FC3A974.60107@panasas.com> <4FC3BC2B.6060709@tonian.com>
In-Reply-To: <4FC3BC2B.6060709@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 08:55 PM, Benny Halevy wrote:

> On 2012-05-28 19:36, Boaz Harrosh wrote:
>> On 05/28/2012 07:05 PM, Benny Halevy wrote:
>>
>>> Yup, see patchset in reply.
>>>
>>
>>
>> That I wish you wouldn't do. I have a patchset pending that makes
>> major changes to all this and totally conflicts with your code.
> 
> Sorry, I didn't know that.
> 
>>
>> You can carry this for a while but I might revert your core
>> code in my new patchset.
> 
> I hope that at least it will all be for the better.
> 
> Benny
> 


NP. Yes it is all for the better. I think you'll like what I did.

BTW after I finish implementing my stuff. I think it would be easy
to implement that open_state_id thing. All we need is to save the
open_state_id somewhere per-file or somehow identify it's receive,
And then just call nfs4_roc() which will do the proper work.

But please wait for me to finish.

(It is all done and debugged, but will be divided and patched
 on Wednesday) 

Thanks
Boaz
