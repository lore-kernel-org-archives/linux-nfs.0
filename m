From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 3 Nov 2008 16:40:44 -0500
Message-ID: <2C93A491-1277-42B6-9CED-FC06A85174D5@oracle.com>
References: <1225724721.2247.29.camel@brian-laptop> <1225731544.6958.6.camel@heimdal.trondhjem.org> <20081103172529.GA9008@citi.umich.edu> <1225733834.6958.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jim Rees <rees@umich.edu>,
	"Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19258 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbYKCVlF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 16:41:05 -0500
In-Reply-To: <1225733834.6958.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 3, 2008, at Nov 3, 2008, 12:37 PM, Trond Myklebust wrote:
> On Mon, 2008-11-03 at 12:25 -0500, Jim Rees wrote:
>> Trond Myklebust wrote:
>>
>>  BTW: NFSv4 + soft == BAD BAD BAD!
>>
>> Maybe this combination should be prohibited.  Does it make any  
>> sense given
>> the stateful nature of v4?
>
> It might make sense if we were to fix up the granularity of the  
> recovery
> routines so that we are able to recover all the state associated with
> just a single open owner or lock owner. Currently we'd have to recover
> all the state associated with that server.
>
> IOW: we might be able to fix things up in the future, but right now,
> NFSv4+soft is not a good idea.

Two cents worth:  Until NFSv4+soft works reasonably well, I wouldn't  
have any problem with making "soft" a no-op for nfs4 mounts.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
