From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/17] SUNRPC: Use "0" as r_owner
Date: Wed, 11 Mar 2009 15:57:06 -0400
Message-ID: <15F6329A-E199-4F22-B169-6C8C99C26E79@oracle.com>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net> <20090303223324.2933.57002.stgit@ingres.1015granger.net> <20090311190647.GG13540@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:62411 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbZCKT5h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 15:57:37 -0400
In-Reply-To: <20090311190647.GG13540@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 11, 2009, at 3:06 PM, J. Bruce Fields wrote:
> On Tue, Mar 03, 2009 at 05:33:25PM -0500, Chuck Lever wrote:
>> It turns out that, despite the spec, rpcbind interprets the string
>
> Should someone be fixing rpcbind too?

Fix it how?  The spec just says r_owner is a string.  It doesn't  
mandate a particular use for it, as far as I recall.  I'm simply  
matching up our current kernel rpcbind client with what we run in user  
space at this point.

>> passed in the r_owner argument for SET and UNSET requests.  It  
>> expects
>> it to be a numeric UID, rather than an arbitrary string.
>>
>> Change the kernel's r_owner string to be "0".
>>
>> This is a documentation change only.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/rpcb_clnt.c |    6 ++++--
>> 1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index 317eb8a..0a3b8f5 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -63,9 +63,11 @@ enum {
>>  * r_owner
>>  *
>>  * The "owner" is allowed to unset a service in the rpcbind database.
>> - * We always use the following (arbitrary) fixed string.
>> + * rpcbind maps this string to a local user name via a passwd lookup
>> + * for AF_LOCAL SET/UNSET requests, but via the network (ie how the
>> + * kernel registers its services) it is pretty much ignored.
>>  */
>> -#define RPCB_OWNER_STRING	"rpcb"
>> +#define RPCB_OWNER_STRING	"0"
>> #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
>>
>> static void			rpcb_getport_done(struct rpc_task *, void *);
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



