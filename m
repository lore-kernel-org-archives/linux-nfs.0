From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 4/8] nfsd4: extend the client_lock to cover cl_lru
Date: Sun, 09 May 2010 09:18:28 +0300
Message-ID: <4BE653B4.3020601@panasas.com>
References: <4BE0A1AE.4040905@panasas.com> <1273013057-32460-1-git-send-email-bhalevy@panasas.com> <20100507222926.GN19142@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65221 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab0EIGSe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 May 2010 02:18:34 -0400
Received: by bwz19 with SMTP id 19so1211062bwz.21
        for <linux-nfs@vger.kernel.org>; Sat, 08 May 2010 23:18:32 -0700 (PDT)
In-Reply-To: <20100507222926.GN19142@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 08, 2010, 1:29 +0300, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Wed, May 05, 2010 at 01:44:17AM +0300, Benny Halevy wrote:
>> @@ -2557,6 +2562,7 @@ nfs4_laundromat(void)
>>  	dprintk("NFSD: laundromat service - starting\n");
>>  	if (locks_in_grace())
>>  		nfsd4_end_grace();
>> +	spin_lock(&client_lock);
>>  	list_for_each_safe(pos, next, &client_lru) {
>>  		clp = list_entry(pos, struct nfs4_client, cl_lru);
>>  		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
>> @@ -2565,11 +2571,15 @@ nfs4_laundromat(void)
>>  				clientid_val = t;
>>  			break;
>>  		}
>> +		list_del_init(&clp->cl_lru);
>> +		spin_unlock(&client_lock);
>>  		dprintk("NFSD: purging unused client (clientid %08x)\n",
>>  			clp->cl_clientid.cl_id);
>>  		nfsd4_remove_clid_dir(clp);
>>  		expire_client(clp);
>> +		spin_lock(&client_lock);
>>  	}
>> +	spin_unlock(&client_lock);
>>  	INIT_LIST_HEAD(&reaplist);
>>  	spin_lock(&recall_lock);
>>  	list_for_each_safe(pos, next, &del_recall_lru) {
> 
> Careful--the list_for_each_safe() isn't enough to handle the results of
> concurrent modifications that might occur while the client_lock is
> dropped.
> 
> Maybe just use the trick of moving everything to a temporary list, then
> doing the real work on that list after dropping the lock?

Yeah, that should be better.
Will do.

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

