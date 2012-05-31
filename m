Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:60817 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab2EaGfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 02:35:11 -0400
Received: by wgbds11 with SMTP id ds11so3886698wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2012 23:35:10 -0700 (PDT)
Message-ID: <4FC71114.8020402@tonian.com>
Date: Thu, 31 May 2012 09:35:00 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com> <4FC3A235.8090908@tonian.com> <4FC3A974.60107@panasas.com> <4FC3BC2B.6060709@tonian.com> <4FC3BF67.7010402@panasas.com> <4FC3C3F1.8090507@tonian.com> <4FC47724.5070407@panasas.com>
In-Reply-To: <4FC47724.5070407@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-29 10:13, Boaz Harrosh wrote:
> On 05/28/2012 09:29 PM, Benny Halevy wrote:
> 
>> On 2012-05-28 21:09, Boaz Harrosh wrote:
> 
> 
>>> BTW after I finish implementing my stuff. I think it would be easy
>>> to implement that open_state_id thing. All we need is to save the
>>> open_state_id somewhere per-file or somehow identify it's receive,
>>> And then just call nfs4_roc() which will do the proper work.
>>
>> It's any non layout stateid so it should be pretty easy (in theory :).
>> See nfs4_process_layout_stateid()
>> if (stid->sc_type != NFS4_LAYOUT_STID) {}
>>
>> We should be able to locate the layout stateid, if any, on the
>> fp->fi_layout_states list by matching stid->sc_client.
>>
> 
> 
> Does look easy, then. I thought it should be. I will have a shot
> at it and add it to my patchset.

Thanks!

> 
> Do you know if we have a test case for this in pyNFS?

No, not that I know of.

> 
> I need to think if we can cause this with the Linux client?
> Perhaps: not set ROC, access a file and close, clear caches
> at both ends, re access, something like that, I'll try.

Cool.  Thanks a bunch for picking this up!

Benny

> 
> Thanks
> Boaz
> 
> --
