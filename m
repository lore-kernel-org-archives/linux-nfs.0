Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54979 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab1BCU3l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 15:29:41 -0500
Subject: Re: [PATCH] Fix size argument to memset call in nfsacl_encode
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1296763614.3015.26.camel@heimdal.trondhjem.org>
Date: Thu, 3 Feb 2011 15:29:03 -0500
Cc: Jesper Juhl <jj@chaosbits.net>, Milton Miller <miltonm@bga.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, bfields@fieldses.org
Message-Id: <67867FEF-6C10-4A35-8952-4EB56EAB79B9@oracle.com>
References: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net> <1296761330.3015.22.camel@heimdal.trondhjem.org> <alpine.LNX.2.00.1102032035280.15101@swampdragon.chaosbits.net> <705C97E5-E273-45AA-9714-2BF409DE1322@oracle.com> <1296763614.3015.26.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 3, 2011, at 3:06 PM, Trond Myklebust wrote:

> On Thu, 2011-02-03 at 15:00 -0500, Chuck Lever wrote: 
>> On Feb 3, 2011, at 2:41 PM, Jesper Juhl wrote:
>> 
>>> On Thu, 3 Feb 2011, Trond Myklebust wrote:
>>> 
>>>> On Thu, 2011-02-03 at 20:15 +0100, Jesper Juhl wrote: 
>>>>> We want to give memset() the sizeof(struct posix_acl), not
>>>>> sizeof(struct posix_acl *).
>>>>> 
>>>>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>>>>> ---
>>>>> nfsacl.c |    2 +-
>>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>> 
>>>>> diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
>>>>> index 84c27d6..bc6d81b 100644
>>>>> --- a/fs/nfs_common/nfsacl.c
>>>>> +++ b/fs/nfs_common/nfsacl.c
>>>>> @@ -117,7 +117,7 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
>>>>> 		 * invoked in contexts where a memory allocation failure is
>>>>> 		 * fatal.  Fortunately this fake ACL is small enough to
>>>>> 		 * construct on the stack. */
>>>>> -		memset(acl2, 0, sizeof(acl2));
>>>>> +		memset(acl2, 0, sizeof(*acl2));
>>>>> 		posix_acl_init(acl2, 4);
>>>>> 
>>>>> 		/* Insert entries in canonical order: other orders seem
>>>> 
>>>> Ccing Milton Miller who also sent in the same patch.
>>>> 
>>>> Neither patch is correct afaics. posix_acl_init() will clobber the above
>>>> memset, and so the correct fix is just to get rid of it...
>>>> 
>>> 
>>> posix_acl_init() sets a_refcount and a_count, but what about a_entries ... 
>>> no problem, nfsacl_encode() itself takes care of that post the 
>>> posix_acl_init() call.. it's all good.
>>> 
>>> So ...
>>> 
>>> 
>>> Remove pointless memset() in nfsacl_encode().
>>> 
>>> Thanks to Trond Myklebust <Trond.Myklebust@netapp.com> for pointing out 
>>> that it is not needed since posix_acl_init() will set everything 
>>> regardless..
>>> 
>>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>>> ---
>>> nfsacl.c |    1 -
>>> 1 file changed, 1 deletion(-)
>>> 
>>> diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
>>> index 84c27d6..ec0f277 100644
>>> --- a/fs/nfs_common/nfsacl.c
>>> +++ b/fs/nfs_common/nfsacl.c
>>> @@ -117,7 +117,6 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
>>> 		 * invoked in contexts where a memory allocation failure is
>>> 		 * fatal.  Fortunately this fake ACL is small enough to
>>> 		 * construct on the stack. */
>>> -		memset(acl2, 0, sizeof(acl2));
>>> 		posix_acl_init(acl2, 4);
>>> 
>>> 		/* Insert entries in canonical order: other orders seem
>> 
>> If there is a guarantee that random data that potentially resides between the fields in that structure will never appear on the wire, then ACK.
>> 
> 
> Yes, that is guaranteed. The posix_acl structure is initialised by
> posix_acl_init above, and the array itself is initialised by us in the
> lines following that...

Sorry, I wasn't clear.  IMO, data that is destined for the network is an important case where we have to be careful about the rule of using either assignments or memset(), not both, when initializing a data structure.

If the compiler doesn't pack the fields in struct posix_acl, there is unused space between them.  Memory for acl2 comes from the stack, which contains arbitrary data when this function is invoked.  The areas between the structure fields are not affected by the variable assignments used here.  If the data in acl2 is then simply memcpy'd to the XDR buffer, that old stack data can possibly appear on the wire.

I agree that the current memset() is incorrect.  My conditional ACK was more about what happens in xdr_encode_array2() rather than how the posix_acl acl2 is initialized.  I think in that regard we are also safe, if the array encoding operates by data type rather than by simply doing a blanket memcpy.  See xdr_nfsace_encode().  It's always possible I misunderstood how ACEs are XDR encoded.

It's a nit at this point, so ACK.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




