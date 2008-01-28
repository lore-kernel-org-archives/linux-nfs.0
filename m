From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 034/100] nfsd4: miscellaneous nfs4state.c style fixes
Date: Mon, 28 Jan 2008 15:24:59 -0500
Message-ID: <20080128202459.GH16785@fieldses.org>
References: <1201303040-7779-26-git-send-email-bfields@citi.umich.edu> <1201303040-7779-27-git-send-email-bfields@citi.umich.edu> <1201303040-7779-28-git-send-email-bfields@citi.umich.edu> <1201303040-7779-29-git-send-email-bfields@citi.umich.edu> <1201303040-7779-30-git-send-email-bfields@citi.umich.edu> <1201303040-7779-31-git-send-email-bfields@citi.umich.edu> <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.!umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umi!ch.edu> <1638E91B-31D2-448C-9FF6-4C457BAD7B74@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbYA1UZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 15:25:00 -0500
In-Reply-To: <1638E91B-31D2-448C-9FF6-4C457BAD7B74@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:39:21PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> Fix various minor style violations.
>>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/nfsd/nfs4state.c |   55 +++++++++++++++++++++++ 
>> +--------------------------
>>  1 files changed, 26 insertions(+), 29 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 6efce99..1c72b23 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -339,21 +339,20 @@ STALE_CLIENTID(clientid_t *clid)
>>   * This type of memory management is somewhat inefficient, but we use 
>> it
>>   * anyway since SETCLIENTID is not a common operation.
>>   */
>> -static inline struct nfs4_client *
>> -alloc_client(struct xdr_netobj name)
>> +static inline struct nfs4_client * alloc_client(struct xdr_netobj  
>> name)
>
> Since you are addressing style issues, CodingStyle likes "struct  
> nfs4_client *alloc_client" (no blank after the asterisk).  Also,  
> "inline" is probably not necessary here; the compiler will do it  
> automatically (likewise below).

OK, done.--b.

>
>>  {
>>  	struct nfs4_client *clp;
>>
>> -	if ((clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL))!= NULL) {
>> -		if ((clp->cl_name.data = kmalloc(name.len, GFP_KERNEL)) != NULL) {
>> -			memcpy(clp->cl_name.data, name.data, name.len);
>> -			clp->cl_name.len = name.len;
>> -		}
>> -		else {
>> -			kfree(clp);
>> -			clp = NULL;
>> -		}
>> +	clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL);
>> +	if (clp == NULL)
>> +		return NULL;
>> +	clp->cl_name.data = kmalloc(name.len, GFP_KERNEL);
>> +	if (clp->cl_name.data == NULL) {
>> +		kfree(clp);
>> +		return NULL;
>>  	}
>> +	memcpy(clp->cl_name.data, name.data, name.len);
>> +	clp->cl_name.len = name.len;
>>  	return clp;
>>  }
>>
>> @@ -421,12 +420,13 @@ expire_client(struct nfs4_client *clp)
>>  	put_nfs4_client(clp);
>>  }
>>
>> -static struct nfs4_client *
>> -create_client(struct xdr_netobj name, char *recdir) {
>> +static struct nfs4_client * create_client(struct xdr_netobj name,  
>> char *recdir)
>> +{
>>  	struct nfs4_client *clp;
>>
>> -	if (!(clp = alloc_client(name)))
>> -		goto out;
>> +	clp = alloc_client(name);
>> +	if (clp == NULL)
>> +		return NULL;
>>  	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
>>  	atomic_set(&clp->cl_count, 1);
>>  	atomic_set(&clp->cl_callback.cb_set, 0);
>> @@ -435,32 +435,30 @@ create_client(struct xdr_netobj name, char  
>> *recdir) {
>>  	INIT_LIST_HEAD(&clp->cl_openowners);
>>  	INIT_LIST_HEAD(&clp->cl_delegations);
>>  	INIT_LIST_HEAD(&clp->cl_lru);
>> -out:
>>  	return clp;
>>  }
>>
>> -static void
>> -copy_verf(struct nfs4_client *target, nfs4_verifier *source) {
>> -	memcpy(target->cl_verifier.data, source->data, sizeof(target- 
>> >cl_verifier.data));
>> +static void copy_verf(struct nfs4_client *target, nfs4_verifier  
>> *source)
>> +{
>> +	memcpy(target->cl_verifier.data, source->data,
>> +			sizeof(target->cl_verifier.data));
>>  }
>>
>> -static void
>> -copy_clid(struct nfs4_client *target, struct nfs4_client *source) {
>> +static void copy_clid(struct nfs4_client *target, struct nfs4_client 
>> *source)
>> +{
>>  	target->cl_clientid.cl_boot = source->cl_clientid.cl_boot;
>>  	target->cl_clientid.cl_id = source->cl_clientid.cl_id;
>>  }
>>
>> -static void
>> -copy_cred(struct svc_cred *target, struct svc_cred *source) {
>> -
>> +static void copy_cred(struct svc_cred *target, struct svc_cred  
>> *source)
>> +{
>>  	target->cr_uid = source->cr_uid;
>>  	target->cr_gid = source->cr_gid;
>>  	target->cr_group_info = source->cr_group_info;
>>  	get_group_info(target->cr_group_info);
>>  }
>>
>> -static inline int
>> -same_name(const char *n1, const char *n2)
>> +static inline int same_name(const char *n1, const char *n2)
>>  {
>>  	return 0 == memcmp(n1, n2, HEXDIR_LEN);
>>  }
>> @@ -502,9 +500,8 @@ static void gen_confirm(struct nfs4_client *clp)
>>  	*p++ = i++;
>>  }
>>
>> -static int
>> -check_name(struct xdr_netobj name) {
>> -
>> +static int check_name(struct xdr_netobj name)
>> +{
>>  	if (name.len == 0)
>>  		return 0;
>>  	if (name.len > NFS4_OPAQUE_LIMIT) {
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
