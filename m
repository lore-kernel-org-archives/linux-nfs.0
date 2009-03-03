From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] mount.nfs kernel version check override
Date: Mon, 2 Mar 2009 19:02:10 -0500
Message-ID: <DBE23047-6345-45CF-9826-86D6F5CAD79B@oracle.com>
References: <20090302232216.GF3867@opengridcomputing.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	swise@opengridcomputing.com, Jeffrey.C.Becker@nasa.gov
To: Jon Mason <jon@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32786 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759447AbZCCACX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2009 19:02:23 -0500
In-Reply-To: <20090302232216.GF3867@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: corrected.

On Mar 2, 2009, at Mar 2, 2009, 6:22 PM, Jon Mason wrote:
> I am working on backporting NFS-RDMA to older versions of Linux for  
> the
> Open Fabrics Linux kernel stack (OFED).  I have backported NFS-RDMA to
> RHEL5.2 (which has a kernel based on 2.6.18), and others are working  
> on
> backporting to other older kernels.  The issue that I have and they  
> will
> discover is that there is a check in the mount command for kernels
> greater than 2.6.22.  If it is older than this version, it will not  
> pass
> args to the kernel.

That's because those older kernels don't support text-based mount  
options.  That will always be true of those upstream kernels.

> I have come up with a patch to add an additional flag to the mount
> command to allow this kernel version check to be over-ruled.  Please
> consider adding it to the next release of the nfs-utils.

I am not the maintainer of nfs-utils, however:  In general, features  
for backports like this are not considered for upstream.  They are  
usually your responsibility.  In this case, you would maintain your  
own copy of the mount command (or nfs-utils) that alters the kernel  
version check as needed.

Also, there used to be a "-i" switch that forced the mount.nfs command  
to send text-based mount options to the kernel.  The reason it was  
never taken upstream was because no-one issues the mount.nfs command  
directly: it's a subcommand that is executed by the mount command.  So  
there's no way to use it in /etc/fstab, for example.  Not very useful!

Finally, the usual practice is to place a proposed patch in the body  
of an e-mail rather than using an attachment when posting patches.   
Most people find that easier to manage with patch tools, and can use  
normal reply quoting when reviewing and commenting on the patch.

Thanks!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
