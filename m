Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:55435 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742Ab0FVPcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 11:32:48 -0400
Message-ID: <4C20D779.5040008@oracle.com>
Date: Tue, 22 Jun 2010 11:32:09 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: James Morris <jmorris@namei.org>
CC: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org> <4C1FC553.4030904@oracle.com> <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org>
In-Reply-To: <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/21/2010 07:21 PM, James Morris wrote:
> On Mon, 21 Jun 2010, Chuck Lever wrote:
>>> +#define NFS_XATTR_PROGRAM	391063	/* TODO: find another value */
>>
>> RFC 5531, appendix B proscribes the appropriate method for requesting an RPC
>> program number assignment.
>>
>> Even though the NFSACL protocol doesn't have one, I have to agree with Deniel
>> that we should have the RPCL definition of the on-the-wire protocol first, so
>> we can review it and ensure our user space and kernel XDR functions remain
>> consistent and correct over time.
>
> Indeed, this is something I'm hoping to do soon.
>
>>   Is there an RFC?
>
> No, there have been several implementations, but never an RFC for xattrs.

> I'm using the XFS implementation as a starting point, and following the
> ACL model of implementing a side-protocol.

>> Especially if we expect non-Linux implementations, I would think an
>> IANA-assigned program number and a proper RPCL definition would be apriori
>> requirements.
>
> It's possible the FreeBSD folk may want to interop with this, as they have
> similar name/value xattrs.

This is why apriori documentation (such as an internet RFC or similar 
that describes the wire protocol) is important.  For an example of a 
side band protocol description, you can look at RFC 1094 or RFC 1813 and 
look at the sections that describe the MOUNT and NLM protocols.

Another place to look is at NFSv4.  Some of the operations that can be 
performed on NFSv4 xattrs are probably nearly what you would want for an 
NFSv3 implementation.  I think it is desirable for anything done for 
NFSv3 to be compatible with NFSv4, as that is already a standard.

> (Btw, slides from a presentation I did on this last year at LinuxCon are
> at http://namei.org/presentations/linuxcon09_nfsv3xattrs.pdf)

NFSACL was added to our NFSv3 implementation because there was a desire 
to interoperate with an existing (albeit nonstandard) implementation. 
Here you are building a new side band protocol from scratch.

Before you go too much farther, you should justify the need to enhance a 
closed standard like NFSv3 rather than expanding on NFSv4 for your 
purposes.  Since NFSv4 already has a lot of what is needed, it seems 
like you'd just need a couple of changes in order to support name/value 
pairs.  You would have a shot at actually making this an internet standard.

I think this community would prefer to advance reasons for users to 
adopt NFSv4, rather than tie users even more to NFSv3.

-- 
Chuck Lever
