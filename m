From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 13:42:28 -0800
Message-ID: <C74013C4.1097D%ricardo.labiaga@netapp.com>
References: <C74012F5.1097A%ricardo.labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: William Adamson <William.Adamson@netapp.com>,
	<linux-nfs@vger.kernel.org>
To: Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62956 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641AbZLEVmX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 16:42:23 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5LgUGA021625
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 13:42:30 -0800 (PST)
In-Reply-To: <C74012F5.1097A%ricardo.labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/5/09 1:39 PM, "Ricardo Labiaga" <ricardo.labiaga@netapp.com> wrote:

> On 12/5/09 1:12 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Sat, 2009-12-05 at 12:55 -0800, Labiaga, Ricardo wrote:
>>> Tried with this patch but it didn't make a difference.
>> 
>> You are still seeing RPC calls with 0 session ids?
>> 
> 
> Yes, right after the session is destroyed, and before it's recreated.  The
> original RPC that got the BAD_SESSION error keeps on trying.
> 

I should clarify.  It's not a retransmission, the client issues the same
compound with a new XID.

- ricardo

> After the session is recreated, the same RPC is issued (with the same
> sequenceID) but with the new sessionID.  This time it fails with
> SEQ_MISORDERED.  This repeats indefinitely until the process is manually
> interrupted.
> 
>>>   I haven't tried applying the second cleanup patch yet since it
>>> didn't apply cleanly on top of nfs-for-next.  Is this the branch you
>>> used?
>> 
>> I've pushed out all patches (including the cleanup patch) onto
>> nfs-for-next now...
>> 
> 
> Got it, I was able to apply both patches.  The results above are with both
> patches.
> 
> - ricardo
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

