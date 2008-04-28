From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 28 Apr 2008 11:13:37 -0400
Message-ID: <2AA81EE8-74A9-42A5-8ACF-E01BBB6F2280@oracle.com>
References: <20080423214929.GA24387@uio.no> <48134C77.9090700@kingswood-consulting.co.uk>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:44684 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935505AbYD1POG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 11:14:06 -0400
In-Reply-To: <48134C77.9090700-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 26, 2008, at 11:38 AM, Frank A. Kingswood wrote:
> Steinar H. Gunderson wrote:
>> I've gotten a few bug reports lately that if UDP is blocked at the  
>> server,
>> NFS mounts (even with -o tcp) fail. git bisect shows that the  
>> culprit is
>> the change "Get rid of the "-i" option for mount.nfs[4] and always  
>> use the
>> text-based mount(2) system call for kernel version 2.6.23 and  
>> later." -- in
>> other words, the bug is specific to the text interface. Does anyone  
>> know why
>> this would be the case?
>
> The NFS client code (nfs-utils-1.1.2) tests for
>  if (kernel_version > MAKE_VERSION(2, 6, 22))
>
> yet the kernel patch for NFS did not go un until 2.6.25-rc2
>
>> From: Linus Torvalds <torvalds@...>
>> Subject: Linux 2.6.25-rc2
>> Date: Feb 15, 5:23 pm 2008
>> Ok,
>> this kernel is a winner.
>> [...]
>> Chuck Lever (1):
>>      NFS: Allow text-based mounts via compat_sys_mount
>
> So the test should at least be > MAKE_VERSION(2, 6, 24).

Frank, the patch you refer to fixes a bug with the compat_sys_mount  
interface, which is separate from the sys_mount interface, and used  
only on a handful of hardware platforms (SPARC?).

The original NFS text-based mount support was added in 2.6.23.

I don't have a problem with adjusting MAKE_VERSION in the master nfs- 
utils repo as you describe, since that bug does break text-based  
mounts on those few hardware platforms that use compat_sys_mount  
instead of sys_mount.  It might affect some early adopters of NFS over  
RDMA or FS cache, however.

On distributions that don't support NFS over RDMA or the FS cache  
facility, it should be harmless for now to make the mount command use  
the legacy mount API even on newer kernels.  Simply adjust the  
MAKE_VERSION() macro as needed, or disable it entirely as you did with  
your "string = 0" hack.

New features will be added only to the text-based mount interface,  
however, so eventually everyone will need to use the text-based mount  
interface on new kernels.

Because we have little documented history and only a handful of use  
cases and unit tests for the mount command, it's important for  
everyone to test the new API and report problems here so we can  
address them.  NFS mount is complex and has many subtle and hidden  
historical behaviors.

Even if 70-80% of the common use cases are working properly, there are  
going to be outliers that will experience issues until we can get the  
corner cases fixed.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
