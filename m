Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48365 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299Ab0LOSvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:51:07 -0500
Message-ID: <4D090E18.4060205@panasas.com>
Date: Wed, 15 Dec 2010 20:51:04 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten layoutreturn
 struct definitions"
References: <4D0908F9.4060208@panasas.com>	 <1292437854-21651-1-git-send-email-bhalevy@panasas.com> <1292437973.3068.15.camel@heimdal.trondhjem.org>
In-Reply-To: <1292437973.3068.15.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-15 20:32, Trond Myklebust wrote:
> On Wed, 2010-12-15 at 20:30 +0200, Benny Halevy wrote:
>> This reverts commit 19e1e5ae1ec0a3f5d997a1a5d924d482e147bea2.
>> ---
>>  include/linux/nfs4.h    |    1 +
>>  include/linux/nfs_xdr.h |   23 +++++++++++++++++++++++
>>  2 files changed, 24 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 8ca7700..55511e8 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -557,6 +557,7 @@ enum {
>>  	NFSPROC4_CLNT_RECLAIM_COMPLETE,
>>  	NFSPROC4_CLNT_LAYOUTGET,
>>  	NFSPROC4_CLNT_LAYOUTCOMMIT,
>> +	NFSPROC4_CLNT_LAYOUTRETURN,
>>  	NFSPROC4_CLNT_GETDEVICEINFO,
>>  	NFSPROC4_CLNT_PNFS_WRITE,
>>  	NFSPROC4_CLNT_PNFS_COMMIT,
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 9d847ac..a651574 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -258,6 +258,29 @@ struct nfs4_layoutcommit_data {
>>  	int status;
>>  };
>>  
>> +struct nfs4_layoutreturn_args {
>> +	__u32   reclaim;
>> +	__u32   layout_type;
>> +	__u32   return_type;
>> +	struct pnfs_layout_range range;
>> +	struct inode *inode;
>> +	struct nfs4_sequence_args seq_args;
>> +};
>> +
>> +struct nfs4_layoutreturn_res {
>> +	struct nfs4_sequence_res seq_res;
>> +	u32 lrs_present;
>> +	nfs4_stateid stateid;
>> +};
>> +
>> +struct nfs4_layoutreturn {
>> +	struct nfs4_layoutreturn_args args;
>> +	struct nfs4_layoutreturn_res res;
>> +	struct rpc_cred *cred;
>> +	struct nfs_client *clp;
>> +	int rpc_status;
>> +};
>> +
>>  struct nfs4_getdeviceinfo_args {
>>  	struct pnfs_device *pdev;
>>  	struct nfs4_sequence_args seq_args;
> 
> Why? We don't need or even want layoutreturn. It adds too much
> serialisation crap.

Define "we" :)

First, the object layout driver relies on layout return for returning I/O error
information.  On the common, successful path, with return_on_close (that Panasas
uses but others may not) I agree that CLOSE with the implicit layoutreturn
semantics we discussed should do a good job too (accompanied with a respective
LAYOUTCOMMIT if needed).

Then, when there's a large number of outstanding layout segments (again
prob. non-files layout presuming server implementations are going to utilize
whole-file layouts) proactive layoutreturn comes handy in capping the
state both the client and server keep - reducing time wasted on walking long
lists of items.

For CB_LAYOUTRECALL response the heart of the debate is around synchronizing
with layouts in-use and in-flight layoutgets.  There, having the server poll
the client, who's retuning NFS4ERR_DELAY should essentially work but may be
inefficient and unreliable in use cases where contention is likely enough.
Eventually, when CB_LAYOUTRECALL is clear to go sending the LAYOUTRETURN
or replying with CB_NOMATCHING_LAYOUT (assuming no I/O error to report
for pnfs-obj) should be equivalent [note: need errata to clarify the
resulting stateid after NOMATCHING_LAYOUT].
Is this the serialization "crap" you're talking about?
What makes checking the conditions for returning NFS4ERR_DELAY to
CB_LAYOUTRECALL so different from implementing a barrier and doing the
returns asynchronously with the CB_LAYOUTRECALL?

Benny

> 
> 
