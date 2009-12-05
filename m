From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 13:39:01 -0800
Message-ID: <C74012F5.1097A%ricardo.labiaga@netapp.com>
References: <1260047538.29208.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: William Adamson <William.Adamson@netapp.com>,
	<linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755755AbZLEVi4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 16:38:56 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5Ld2db020989
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 13:39:02 -0800 (PST)
In-Reply-To: <1260047538.29208.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/5/09 1:12 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sat, 2009-12-05 at 12:55 -0800, Labiaga, Ricardo wrote:
>> Tried with this patch but it didn't make a difference.
> 
> You are still seeing RPC calls with 0 session ids?
> 

Yes, right after the session is destroyed, and before it's recreated.  The
original RPC that got the BAD_SESSION error keeps on trying.

After the session is recreated, the same RPC is issued (with the same
sequenceID) but with the new sessionID.  This time it fails with
SEQ_MISORDERED.  This repeats indefinitely until the process is manually
interrupted.

>>   I haven't tried applying the second cleanup patch yet since it
>> didn't apply cleanly on top of nfs-for-next.  Is this the branch you
>> used?
> 
> I've pushed out all patches (including the cleanup patch) onto
> nfs-for-next now...
> 

Got it, I was able to apply both patches.  The results above are with both
patches.

- ricardo

