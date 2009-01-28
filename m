From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] : Fix compilation warnings in fs/nfsd/nfs4state.c
Date: Wed, 28 Jan 2009 17:05:44 -0500
Message-ID: <8AEAE6B0-5631-4617-AFE7-403460A1A225@oracle.com>
References: <ea11fea30901272238t4d11ba15t8bac4cd702ea7440@mail.gmail.com> <20090128191104.GA6276@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Manish Katiyar <mkatiyar@gmail.com>, kmsmith@umich.edu,
	kandros@umich.edu, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48726 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756160AbZA1WGP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 17:06:15 -0500
In-Reply-To: <20090128191104.GA6276@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 28, 2009, at Jan 28, 2009, 2:11 PM, J. Bruce Fields wrote:
> On Wed, Jan 28, 2009 at 12:08:19PM +0530, Manish Katiyar wrote:
>> Below patch removes the following warning ;-
>> fs/nfsd/nfs4state.c:1657: warning: unused variable 'flp'
>
> I don't believe we want to support a .config with NFS or NFSD turned  
> on
> but CONFIG_FILE_LOCKING off.

In that case, would we want to add a "depends on FILE_LOCKING" to both  
CONFIG_NFS and CONFIG_NFSD?

> --b.
>
>> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
>> ---
>> fs/nfsd/nfs4state.c |    5 ++++-
>> 1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 69e98ca..2903589 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1654,7 +1654,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct
>> nfsd4_open *open, struct nfs4_sta
>> 	struct nfs4_delegation *dp;
>> 	struct nfs4_stateowner *sop = stp->st_stateowner;
>> 	struct nfs4_callback *cb = &sop->so_client->cl_callback;
>> -	struct file_lock fl, *flp = &fl;
>> +	struct file_lock fl;
>> +#ifdef CONFIG_FILE_LOCKING
>> +	struct file_lock *flp = &fl;
>> +#endif
>> 	int status, flag = 0;
>>
>> 	flag = NFS4_OPEN_DELEGATE_NONE;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
