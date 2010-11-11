From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Simplify rpc_alloc_iostats by removing pointless local variable
Date: Thu, 11 Nov 2010 10:57:47 -0500
Message-ID: <1745E543-5867-4814-9678-5E73AD2C25BA@oracle.com>
References: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net> <alpine.LNX.2.00.1011102229370.625@swampdragon.chaosbits.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:45122 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab0KKP7a convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 10:59:30 -0500
In-Reply-To: <alpine.LNX.2.00.1011102229370.625-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 10, 2010, at 4:32 PM, Jesper Juhl wrote:

> On Sun, 7 Nov 2010, Jesper Juhl wrote:
> 
>> Hi,
>> 
>> We can simplify net/sunrpc/stats.c::rpc_alloc_iostats() a bit by getting 
>> rid of the unneeded local variable 'new'.
>> 
>> 
>> Please CC me on replies.
>> 
>> 
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>> ---
>> stats.c |    4 +---
>> 1 file changed, 1 insertion(+), 3 deletions(-)
>> 
>> diff --git 
>> a/net/sunrpc/stats.c b/net/sunrpc/stats.c
>> index f71a731..80df89d 100644
>> --- a/net/sunrpc/stats.c
>> +++ b/net/sunrpc/stats.c
>> @@ -115,9 +115,7 @@ EXPORT_SYMBOL_GPL(svc_seq_show);
>>  */
>> struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt)
>> {
>> -	struct rpc_iostats *new;
>> -	new = kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
>> -	return new;
>> +	return kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
>> }
>> EXPORT_SYMBOL_GPL(rpc_alloc_iostats);
>> 
>> 
>> 
> 
> Ok, no response to this for a couple of days.
> Is there some problem or did it just get missed?
> Could someone merge this and push it up-stream, please, if there are no 
> problems with it...

The NFS maintainer is traveling.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




