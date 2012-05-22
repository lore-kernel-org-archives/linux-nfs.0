Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38945 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768Ab2EVOlm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:41:42 -0400
Message-ID: <4FBBA59F.2050001@parallels.com>
Date: Tue, 22 May 2012 18:41:35 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] NFS: put net on idr allocation failure
References: <20120522073709.20602.33027.stgit@localhost.localdomain>  <20120522080307.21303.60025.stgit@localhost.localdomain> <1337697459.4269.7.camel@lade.trondhjem.org>
In-Reply-To: <1337697459.4269.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22.05.2012 18:37, Myklebust, Trond wrote:
> On Tue, 2012-05-22 at 12:03 +0400, Stanislav Kinsbursky wrote:
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>> ---
>>   fs/nfs/client.c |    4 +++-
>>   1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 44cd70f..ae29d4f 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -176,8 +176,10 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>>
>>   #ifdef CONFIG_NFS_V4
>>   	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
>> -	if (err)
>> +	if (err) {
>> +		put_net(clp->net);
>>   		goto error_cleanup;
>> +	}
>>
>>   	spin_lock_init(&clp->cl_lock);
>>   	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
>>
>
> Let's just move the actual get_net() call to the end of the function.
>

Ok. But it will look a bit strange, like this:

clp->net = net;
...
nfs_get_cb_ident_idr
...
get_net(clp->net)

Or I can pass net to nfs_get_cb_ident_idr() as a parameter.
Which solution is more preferable&?

-- 
Best regards,
Stanislav Kinsbursky
