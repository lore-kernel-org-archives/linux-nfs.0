From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than a protoname
Date: Thu, 29 Oct 2009 10:13:35 -0400
Message-ID: <F9E982FF-1E22-4859-B515-2CA9B118271B@oracle.com>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com> <20091029042415.GA2283@infradead.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29344 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbZJ2ON7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Oct 2009 10:13:59 -0400
In-Reply-To: <20091029042415.GA2283@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 29, 2009, at 12:24 AM, Christoph Hellwig wrote:
> On Wed, Oct 28, 2009 at 03:40:12PM -0400, Jeff Layton wrote:
>> Solaris uses netids as values for the proto= option, so that when
>> someone specifies "tcp6" they get traffic over TCP + IPv6. Until
>> recently, this has never really been an issue for Linux since it  
>> didn't
>> support NFS over IPv6.  The netid and the protocol name were  
>> generally
>> always the same (modulo any strange configuration in /etc/netconfig).
>>
>> The solaris manpage documents their proto= option as:
>>
>>    proto= _netid_ | rdma
>
> I'm strictly against adding netid braindamage to Linux.  Just because
> Solaris made a mistake we don't have to repeat it.

As it stands, the kernel already has some support for netids, which is  
required for supporting NFS and RPC on IPv6 such that it can  
interoperate with the reference NFS implementation.  We might be able  
to address your concern if we understood specifically what was at issue.

A feature request has been made to provide a mechanism to force the  
use of IPv4 or IPv6 for mounting NFS servers that have both types of  
address.  The use of "proto=netid" is especially preferred for  
mount.nfs since Linux often shares automounter maps with other NFS  
implementations.  And, netids are an internet standard at this point.   
We could choose a different mechanism for the kernel's mount option  
parser, but I haven't seen an alternative proposal that is cleaner  
overall than what we have here.

> Adding a hack to mount.nfs to parse it is fine, but there's not need  
> to
> display it again.

That was our first pass, but as Jeff says, it's just bad user  
interface design for the mount options in /proc/mounts to have  
different semantics than what admins use in user space.  I would  
rather keep mount.nfs and the kernel's mount parser as close together  
as possible.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



