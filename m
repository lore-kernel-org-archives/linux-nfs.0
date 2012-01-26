Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab2AZV3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:29:03 -0500
Message-ID: <4F21C58E.5070407@netapp.com>
Date: Thu, 26 Jan 2012 16:28:46 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Clean up the test_stateid function
References: <1327510095-26125-1-git-send-email-bjschuma@netapp.com> <20120126212554.GE700@fieldses.org>
In-Reply-To: <20120126212554.GE700@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu Jan 26 16:25:54 2012, J. Bruce Fields wrote:
> On Wed, Jan 25, 2012 at 11:48:15AM -0500, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> When I initially wrote it, I didn't understand how lists worked so I
>> wrote something that didn't use them.  I think making a list of stateids
>> to test is a more straightforward implementation, especially compared to
>> especially compared to decoding stateids while simultaneously encoding
>> a reply to the client.
>
> Thanks, yes, I'll be much happier with something like this.  The only
> thing I'm worried about:
>
>>  static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>>  {
>>  	/* We want more bytes than seem to be available.
>> @@ -1385,31 +1369,36 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
>>  static __be32
>>  nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_stateid *test_stateid)
>>  {
>> -	unsigned int nbytes;
>> -	stateid_t si;
>>  	int i;
>> -	__be32 *p;
>> -	__be32 status;
>> +	__be32 *p, status;
>> +	struct nfsd4_test_stateid_id *stateid;
>>  
>>  	READ_BUF(4);
>>  	test_stateid->ts_num_ids = ntohl(*p++);
>>  
>> -	nbytes = test_stateid->ts_num_ids * sizeof(stateid_t);
>> -	if (nbytes > (u32)((char *)argp->end - (char *)argp->p))
>> -		goto xdr_error;
>> -
>> -	test_stateid->ts_saved_args = argp;
>> -	save_buf(argp, &test_stateid->ts_savedp);
>> +	INIT_LIST_HEAD(&test_stateid->ts_stateid_list);
>>  
>>  	for (i = 0; i < test_stateid->ts_num_ids; i++) {
>> -		status = nfsd4_decode_stateid(argp, &si);
>> +		stateid = kmalloc(sizeof(struct nfsd4_test_stateid_id), GFP_KERNEL);
>
> Hm, are you sure this will always get freed in all cases?
>
> Off the top of my head: the compound gets decode in one fell swoop.  The
> we process and encode each op one at a time.  So, for example, if we
> fail later in the decoding, or if processing fails on an earlier op than
> this one, then we're not going to hit the free in the encoder:
>
>>  nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
>>  			  struct nfsd4_test_stateid *test_stateid)
>>  {
> ...
>> +	list_for_each_entry_safe(stateid, next, &test_stateid->ts_stateid_list, ts_id_list) {
>> +		*p++ = htonl(stateid->ts_id_status);
>> +		list_del(&stateid->ts_id_list);
>> +		kfree(stateid);
>
> Hence the defer_free/release_compoundargs stuff.  If you grep through
> nfs4xdr.c for defer_free I think you'll see how it works.

I'll take a look, thanks!  I didn't know about the defer_free option, 
but using it makes sense here.  I'll fix up the patches and send a new 
version.

- Bryan

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


