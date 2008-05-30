From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Fri, 30 May 2008 18:48:31 -0400
Message-ID: <A4F07986-C129-4D87-9C82-61FC797A178F@oracle.com>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com> <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com> <alpine.LFD.1.10.0805301805490.26788@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:34909 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbYE3WzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2008 18:55:17 -0400
In-Reply-To: <alpine.LFD.1.10.0805301805490.26788-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 30, 2008, at 6:14 PM, James Lentini wrote:
> Hi Chuck,
>
> Replies below:
>
> On Fri, 30 May 2008, Chuck Lever wrote:
>> You can simply extract the rebuilt mount.nfs command instead of  
>> installing the
>> whole package with
>>
>> 	$ sudo cp utils/mount/mount.nfs /path/to/your/mount.nfs
>
> For mount.nfs to be picked up automatically by mount, mount.nfs needs
> to be at /sbin/mount.nfs, correct?

I haven't looked at that part of the mount command, but usually  
distributors will cede that detail to the package maintainers to  
reduce the number of patches they have to apply.

Let's assume /sbin is the correct place for mount.nfs, unless someone  
complains loudly.

> In the instructions, I'll recommend
> that the binary be copied as follows:
>
> $ sudo cp utils/mount/mount.nfs /sbin/mount.nfs
>
>> The tcp_wrappers package is needed to build nfs-utils in any case,  
>> so it would
>> be helpful to mention that too.
>
> I'd like to leave that detail to the nfs-utils README. Does that sound
> reasonable?

If you're going to provide a blanket pointer to the nfs-utils README  
for building it, and omit any specific instructions from nfs-rdma.txt  
(aside from copying the mount.nfs executable), that sounds reasonable.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
