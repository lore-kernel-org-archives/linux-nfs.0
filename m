From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 000/112] What's in the NFS queue for linux-2.6.25
Date: Fri, 25 Jan 2008 13:34:55 -0500
Message-ID: <4A2005C9-DD9B-4F3E-AF89-B24EDBEB2EBF@oracle.com>
References: <1201280354.24283.70.camel@heimdal.trondhjem.org> <20080125173537.GA22782@uio.no> <1201285561.24283.109.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:60547 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366AbYAYSgi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2008 13:36:38 -0500
In-Reply-To: <1201285561.24283.109.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 1:26 PM, Trond Myklebust wrote:
> On Fri, 2008-01-25 at 18:35 +0100, Steinar H. Gunderson wrote:
>> On Fri, Jan 25, 2008 at 11:59:13AM -0500, Trond Myklebust wrote:
>>>       * More IPv6 cleanups from Chuck. NFSv4 support for IPv6  
>>> should now
>>>         almost be complete (IPv6 callback support is still not  
>>> ready).
>>
>> Does this mean we can start beta testing these features out in the
>> distributions now? Is nfs-utils (in particular nfsd/mountd) ready?
>
> No. I'm talking about the kernel client support only. Server  
> support is
> a different matter...
>
> I believe Chuck still has to make a change to the nfs-utils 'mount' in
> order to make it capable of resolving IPv6 DNS lookups.


There are some missing glibc/tirpc pieces required for the mount  
command to support binding IPv6 sockets.  I'm still sorting things  
out, but I expect to have something available for testing Linux NFSv4  
mounting against IPv6-enabled servers (Solaris, at least) soon.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
