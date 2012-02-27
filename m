Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19318 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876Ab2B0QVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 11:21:20 -0500
Message-ID: <4F4BAD5E.9000600@parallels.com>
Date: Mon, 27 Feb 2012 20:20:46 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: David Laight <David.Laight@ACULAB.COM>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 2/4] NFS: release per-net clients lock before calling
 PipeFS dentries creation
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.02.2012 19:59, David Laight пишет:
>
>>   	spin_lock(&nn->nfs_client_lock);
>> -	list_for_each_entry(clp,&nn->nfs_client_list, cl_share_link) {
>> +	list_for_each_entry_safe(clp, tmp,&nn->nfs_client_list,
> cl_share_link) {
>>   		if (clp->rpc_ops !=&nfs_v4_clientops)
>>   			continue;
>> +		atomic_inc(&clp->cl_count);
>> +		spin_unlock(&nn->nfs_client_lock);
>>   		error = __rpc_pipefs_event(clp, event, sb);
>> +		nfs_put_client(clp);
>>   		if (error)
>>   			break;
>> +		spin_lock(&nn->nfs_client_lock);
>>   	}
>>   	spin_unlock(&nn->nfs_client_lock);
>>   	return error;
>
> The locking doesn't look right if the loop breaks on error.
> (Same applied to patch v2 1/4)
>

Thanks for the catch. I'll fix this.

> Although list_fo_each_entry_safe() allows the current entry
> to be freed, I don't believe it allows the 'next' to be freed.
> I doubt there is protection against that happening.
>

We need to use safe macro, because client can be destroyed on nfs_put_client() call.
About "protection against ... the 'next' to be freed" - I dont' think, that we 
need any protection against it. This will be done under nfs_client_lock, and 
current entry list pointers will be updated properly.

> Do you need to use an atomic_inc() for cl_count.
> I'd guess the nfs_client_lock is usually held?
>

Sorry, I don't understand this question.

-- 
Best regards,
Stanislav Kinsbursky
