Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f176.google.com ([209.85.215.176]:43527 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3LMJzr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 04:55:47 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so763085eaj.7
        for <linux-nfs@vger.kernel.org>; Fri, 13 Dec 2013 01:55:46 -0800 (PST)
Message-ID: <52AAD99E.40706@primarydata.com>
Date: Fri, 13 Dec 2013 11:55:42 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix printk format string in nfsd4_open
References: <1386608743-23718-1-git-send-email-bhalevy@primarydata.com> <20131212161931.GF11521@fieldses.org>
In-Reply-To: <20131212161931.GF11521@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/12/2013 06:19 PM, J. Bruce Fields wrote:
> On Mon, Dec 09, 2013 at 07:05:43PM +0200, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> Are you sure?  Reminding myself from the sprintf man page.... %*s
> provides padding, %.*s limits the number of characters taken from the
> string.  We need that limit since there's no guarantee of null
> termination here.

Well, the .* format doesn't seem to be supported in the kernel library as
far as I could tell. At least it doesn't work for me. We may need to copy
the string and null terminate it if it's indeed the case.

Benny

> 
> --b.
> 
>> ---
>>  fs/nfsd/nfs4proc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 0a964f1..8624bee 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -361,7 +361,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	struct net *net = SVC_NET(rqstp);
>>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>  
>> -	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
>> +	dprintk("NFSD: nfsd4_open filename %*s op_openowner %p\n",
>>  		(int)open->op_fname.len, open->op_fname.data,
>>  		open->op_openowner);
>>  
>> -- 
>> 1.8.3.1
>>
