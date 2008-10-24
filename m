From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH 2/2] NFS: Cleanup decode_attr_fs_locations function.
Date: Fri, 24 Oct 2008 10:09:39 -0700
Message-ID: <49020153.6060304@gmail.com>
References: <1224283927-4639-1-git-send-email-dhildeb@us.ibm.com> <1224283927-4639-2-git-send-email-dhildeb@us.ibm.com> <48FB0E37.7010702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:21799 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbYJXRJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 13:09:45 -0400
Received: by wf-out-1314.google.com with SMTP id 27so944837wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 10:09:44 -0700 (PDT)
In-Reply-To: <48FB0E37.7010702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Benny Halevy wrote:
> On Oct. 18, 2008, 0:52 +0200, Dean Hildebrand <seattleplus@gmail.com> wrote:
>   
>> a) Use correct data types.
>> b) Use nloc and nserv instead of n and m variable names.
>> c) Try to clean up formatting of debugging statements.
>> d) Move while loops to for loops.
>>
>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>> ---
>>  fs/nfs/nfs4xdr.c |   38 ++++++++++++++++++++------------------
>>  1 files changed, 20 insertions(+), 18 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 0b4c565..b7de923 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -2560,7 +2560,8 @@ out_eio:
>>  
>>  static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
>>  {
>> -	int n;
>> +	u32 nloc;
>> +	unsigned int i;
>>  	__be32 *p;
>>  	int status = -EIO;
>>  
>> @@ -2574,37 +2575,37 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>>  	if (unlikely(status != 0))
>>  		goto out;
>>  	READ_BUF(4);
>> -	READ32(n);
>> -	if (n <= 0)
>> +	READ32(nloc);
>> +	if (nloc <= 0)
>>  		goto out_eio;
>>  
>> -	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
>> -		dprintk("\n%s: Using first %u of %d fs locations\n",
>> -			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
>> -		n = NFS4_FS_LOCATIONS_MAXENTRIES;
>> +	if (nloc > NFS4_FS_LOCATIONS_MAXENTRIES) {
>> +		dprintk("\n%s: Using first %u of %u fs locations\n",
>> +			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, nloc);
>> +		nloc = NFS4_FS_LOCATIONS_MAXENTRIES;
>>  	}
>>  
>>  	res->nlocations = 0;
>> -	while (res->nlocations < n) {
>> -		u32 m;
>> -		unsigned int totalserv, i;
>> -		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
>> +	for (i = 0; i < nloc; i++) {
>>     
>
> you could also keep using res->nlocations as iterator, e.g.
>
> -	res->nlocations = 0;
> -	while (res->nlocations < n) {
> +	for (res->nlocations = 0; res->nlocations < nloc; res->nlocations++) {
>   
Sounds reasonable, although I don't want to hear any flak for exceeding 
80 chars.
Dean
> Since it is incremented every time we go through the loop
> anyway using the auxiliary variable is useless.
> (It could possibly improve performance a bit for long
> arrays if the compiler would've used a register for the local
> variable, but then you should assign its final value
> to res->nlocations, not increment it every iteration.
> However, I don't think it's worth it in this case)
>
>   
>> +		u32 nserv;
>> +		unsigned int totalserv, j;
>> +		struct nfs4_fs_location *loc = &res->locations[i];
>>  
>>  		READ_BUF(4);
>> -		READ32(m);
>> +		READ32(nserv);
>>  
>> -		totalserv = m;
>> -		if (m >  NFS4_FS_LOCATION_MAXSERVERS) {
>> +		totalserv = nserv;
>> +		if (nserv >  NFS4_FS_LOCATION_MAXSERVERS) {
>>  			dprintk("\n%s: Using first %u of %u servers "
>>  				"returned for location %u\n",
>>  				__func__, NFS4_FS_LOCATION_MAXSERVERS,
>> -				m, res->nlocations);
>> -			m = NFS4_FS_LOCATION_MAXSERVERS;
>> +				nserv, i);
>> +			nserv = NFS4_FS_LOCATION_MAXSERVERS;
>>  		}
>>  
>>  		loc->nservers = 0;
>>  		dprintk("%s: servers ", __func__);
>> -		while (loc->nservers < m) {
>> +		for (j = 0; j < nserv; j++) {
>>     
>
> ditto for loc->nservers.
>
> Benny
>
>   
>>  			struct nfs4_string *server = &loc->servers[loc->nservers];
>>  			status = decode_opaque_inline(xdr, &server->len, &server->data);
>>  			if (unlikely(status != 0))
>> @@ -2612,9 +2613,10 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>>  			dprintk("%s ", server->data);
>>  			loc->nservers++;
>>  		}
>> +		dprintk("\n");
>>  
>>  		/* Decode and ignore overflow servers */
>> -		for (i = loc->nservers; i < totalserv; i++) {
>> +		for (j = loc->nservers; j < totalserv; j++) {
>>  			unsigned int len;
>>  			char *data;
>>  			status = decode_opaque_inline(xdr, &len, &data);
>>     
