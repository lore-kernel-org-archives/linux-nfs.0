Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48830 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbcHKUBE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 16:01:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v4 0/2] Eliminate race between LOCK and FREE_STATEID
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160811195729.GB2114@fieldses.org>
Date: Thu, 11 Aug 2016 16:00:52 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AF8D2AEF-1108-42D9-B97B-5D7B50F169CF@oracle.com>
References: <20160811143205.20488.82396.stgit@klimt.1015granger.net> <20160811195729.GB2114@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 11, 2016, at 3:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Thu, Aug 11, 2016 at 10:37:21AM -0400, Chuck Lever wrote:
>> Hi Bruce-
>> 
>> IMO this series is both safe and effective and thus is ready to merge.
> 
> Thanks for the care taken with this series....
> 
> I'll queue it up for 4.8 and stable, unless there's objections.

Excellent, thanks.

Re: stable: Alexey tells me that: v4.7-rc4 commit feb9dad5
("nfsd: Always lock state  exclusively.") is required for this
series to apply successfully to v4.1-stable.


> --b.
> 
>> 
>> Alexey reports:
>> 
>> @ All 500 nfslock test runs passed, also run other related NFS tests with 
>> @ different configurations, as a result they passed as well. 
>> 
>> 
>> Changes since v3:
>> - Add Tested-by tags
>> 
>> Changes since v2:
>> - Move NFS4_LOCK_STID arm into a helper, for clarity
>> - Add more detail to patch description
>> - Add Jeff's patch to fix similar race in nfsd4_lock
>> 
>> Changes since v1:
>> - Use s->sc_count to preserve stateid while cl_lock is dropped
>> 
>> ---
>> 
>> Chuck Lever (1):
>>      nfsd: Fix race between FREE_STATEID and LOCK
>> 
>> Jeff Layton (1):
>>      nfsd: don't return an unhashed lock stateid after taking mutex
>> 
>> 
>> fs/nfsd/nfs4state.c |   65 ++++++++++++++++++++++++++++++++++++++-------------
>> 1 file changed, 48 insertions(+), 17 deletions(-)
>> 
>> --
>> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



