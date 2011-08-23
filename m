From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Date: Tue, 23 Aug 2011 17:40:58 +0800
Message-ID: <4E5375AA.1050506@cn.fujitsu.com>
References: <4E4F8B5D.6060404@cn.fujitsu.com> <20110822192620.GB16261@fieldses.org> <3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com> <20110822194459.GC16261@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53723 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754577Ab1HWJhI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 05:37:08 -0400
In-Reply-To: <20110822194459.GC16261@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields:
> On Mon, Aug 22, 2011 at 03:32:13PM -0400, Chuck Lever wrote:
>> On Aug 22, 2011, at 3:26 PM, J. Bruce Fields wrote:
>>
>>> On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
>>>> +/* 
>>>> + * Add scope id for LINKLOCAL address
>>>> + */
>>>> +struct in6_addr_scopeid{
>>>> +	struct in6_addr	sin6_addr;
>>>> +	__u32		sin6_scope_id;
>>>> +};
>>>> +
>>>> union svc_addr_u {
>>>> -    struct in_addr	addr;
>>>> -    struct in6_addr	addr6;
>>>> +	struct in_addr		addr;
>>>> +	struct in6_addr_scopeid	addr6;
>>> By the way, is there any reason why nfsd really needs its own address
>>> structure?  Shouldn't we use sockaddr_storage or something?  I feel like
>>> we've got a little too much one-off address handling in nfsd.
>> That would be my only complaint about the patch.
>>
>> I think we chose a smaller struct here to save space, and we could do that because we didn't need a port number or scope ID.  If a scope ID is indeed required, then we should consider something larger like a struct sockaddr_storage, IMO.
> 
> If we care about the size of struct svc_rqst: rq_vec and rq_pages fields
> are 4k and 2k, respectively, and the rest is lost in the noise.
> 
> Mi Jinlong, would you have the time to try this?

  OK, I will do this.

  Thanks for all comment.


-- 
----
thanks
Mi Jinlong

> 
> 	- Replace svc_addr_u by sockaddr_storage
> 	- See of that allows us to delete some lines of code in nfsd by
> 	  using standard helper functions instead of copying things by
> 	  hand.
> 
> You'd do that in one patch, then apply your scope-id fix on top of it as
> a second patch.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

