From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Wed, 9 Sep 2009 15:23:08 -0400
Message-ID: <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>
References: <4AA68AA4.7090606@moving-picture.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:28572 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbZIITXp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2009 15:23:45 -0400
In-Reply-To: <4AA68AA4.7090606-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 8, 2009, at 12:47 PM, James Pearson wrote:
> I've noticed a difference in the rsize used when mounting a file  
> system  between using text and binary mount options.
>
> The client is running a CentOS5 based distro with a 2.6.32-rc8 kernel
>
> The server has a preferred rsize of 128kb and maximum rsize of 512kb
>
> When I use mount.nfs from CentOS5/RHEL5 nfs-utils (based on v1.0.9)  
> and don't give any rsize option, it mounts the file system with a  
> rsize of 128kb. This uses binary mount options
>
> But, when using mount.nfs from nfs-utils 1.2.0, the file system is  
> mounted with an rsize of 512kb
>
> Looking at the nfs-utils and kernel source, it appears that for  
> binary options, rsize is set to 0 if not given by mount.nfs, and the  
> kernel eventually, in this case, increases this to preferred size.
>
> But for text mount options, if not set by mount.nfs, the default  
> size is  set to NFS_MAX_FILE_IO_SIZE in the kernel, which, in this  
> case, gets reduced to the server maximum size.
>
> Should the kernel be setting rsize (and wsize) to 0 by default?

nfs(5) says:

"If an [rw]size value is not specified, or if the specified [rw]size  
value is larger than the maximum that either client or server can  
support, the client and server negotiate the largest [rw]size value  
that they can both support."

So the text-based behavior is what is documented now.

Does anyone know of a reason to use the server's "preferred" transfer  
size rather than the largest size supported by both client and  
server?  Usually those are the same.

> Thanks
>
> James Pearson
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



