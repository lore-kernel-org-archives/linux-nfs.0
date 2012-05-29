Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:42932 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab2E2HOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 03:14:14 -0400
Message-ID: <4FC47724.5070407@panasas.com>
Date: Tue, 29 May 2012 10:13:40 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com> <4FC3A235.8090908@tonian.com> <4FC3A974.60107@panasas.com> <4FC3BC2B.6060709@tonian.com> <4FC3BF67.7010402@panasas.com> <4FC3C3F1.8090507@tonian.com>
In-Reply-To: <4FC3C3F1.8090507@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 09:29 PM, Benny Halevy wrote:

> On 2012-05-28 21:09, Boaz Harrosh wrote:


>> BTW after I finish implementing my stuff. I think it would be easy
>> to implement that open_state_id thing. All we need is to save the
>> open_state_id somewhere per-file or somehow identify it's receive,
>> And then just call nfs4_roc() which will do the proper work.
> 
> It's any non layout stateid so it should be pretty easy (in theory :).
> See nfs4_process_layout_stateid()
> if (stid->sc_type != NFS4_LAYOUT_STID) {}
> 
> We should be able to locate the layout stateid, if any, on the
> fp->fi_layout_states list by matching stid->sc_client.
> 


Does look easy, then. I thought it should be. I will have a shot
at it and add it to my patchset.

Do you know if we have a test case for this in pyNFS?

I need to think if we can cause this with the Linux client?
Perhaps: not set ROC, access a file and close, clear caches
at both ends, re access, something like that, I'll try.

Thanks
Boaz

