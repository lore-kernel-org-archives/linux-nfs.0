From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 02/22] Don't expect blocksize to always be 8 when	calculating
 padding
Date: Wed, 17 Mar 2010 07:55:27 -0400
Message-ID: <4BA0C32F.8020802@RedHat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com> <1268655627-18712-3-git-send-email-steved@redhat.com> <1268668930.2993.91.camel@localhost.localdomain> <20100315233835.GA25710@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859Ab0CQL4P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Mar 2010 07:56:15 -0400
In-Reply-To: <20100315233835.GA25710@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/15/2010 07:38 PM, J. Bruce Fields wrote:
> On Mon, Mar 15, 2010 at 12:02:10PM -0400, Trond Myklebust wrote:
>> On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
>>> From: Kevin Coffman <kwc@citi.umich.edu>
>>>
>>> Allow blocksizes other than 8 when calculating padding
>>>
>>> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
>>>  1 files changed, 1 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>>> index a0660f5..4c14b0a 100644
>>> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
>>> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>>> @@ -13,10 +13,7 @@
>>>  static inline int
>>>  gss_krb5_padding(int blocksize, int length)
>>>  {
>>> -	/* Most of the code is block-size independent but currently we
>>> -	 * use only 8: */
>>> -	BUG_ON(blocksize != 8);
>>> -	return 8 - (length & 7);
>>> +	return blocksize - (length & (blocksize - 1));
>>>  }
>>>  
>>
>> What happens if blocksize is not a power of 2?
> 
> It's extremely unlikely we'll care about any blocksize other than 8 or
> 16 bytes, but may as well make this:
> 
> 	return blocksize - (length % blocksize)
Ok...

steved.

