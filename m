From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 05/11] nfsd: skip clients marked for renewal
Date: Wed, 16 Dec 2009 23:54:00 +0200
Message-ID: <4B2956F8.8040809@panasas.com>
References: <4B291B4C.3060603@panasas.com> <1260985285-21517-1-git-send-email-bhalevy@panasas.com> <20091216205853.GC28822@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11762 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754281AbZLPVyG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 16:54:06 -0500
In-Reply-To: <20091216205853.GC28822@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec. 16, 2009, 22:58 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Wed, Dec 16, 2009 at 07:41:25PM +0200, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 16ccab3..15f4b63 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2613,6 +2613,9 @@ nfs4_laundromat(void)
>>  				clientid_val = t;
>>  			break;
>>  		}
>> +		/* skip clients marked for renewal */
>> +		if (atomic_read(&clp->cl_state) == CL_STATE_RENEW)
>> +			continue;
> 
> I may just not understand your locking scheme.
> 
> But how are concurrent expiriry and renewal handled?  Couldn't the state
> be marked CL_STATE_RENEW after this check but before CL_STATE_EXPIRED is
> set in the following expire_client()?  What happens then?

You're right.  This should be a cmpxchg form CL_STATE_NORMAL to
CL_STATE_EXPIRED, and then looking at the old val.

Benny

> 
> --b.
> 
>>  		dprintk("NFSD: purging unused client (clientid %08x)\n",
>>  			clp->cl_clientid.cl_id);
>>  		nfsd4_remove_clid_dir(clp);
>> -- 
>> 1.6.5.1
>>
