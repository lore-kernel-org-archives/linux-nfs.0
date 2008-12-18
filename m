From: Steve Dickson <SteveD@redhat.com>
Subject: Re: what's the real meaning of fsid?
Date: Thu, 18 Dec 2008 10:21:39 -0500
Message-ID: <494A6A83.9010107@RedHat.com>
References: <200812171336070316863@gmail.com> <200812180916175465416@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: lioupayphone <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47700 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751849AbYLRPXw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 10:23:52 -0500
In-Reply-To: <200812180916175465416@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lioupayphone wrote:
>>
> yes, both the two directories have a same FH.
> when i "cat /proc/fs/nfsd/exports ", it shows :
> # Version 1.1
> # Path Client(Flags) # IPs
> /mnt/dir1       *(rw,root_squash,async,wdelay,no_subtree_check,fsid=2)
> /mnt/dir2       *(rw,root_squash,async,wdelay,no_subtree_check,fsid=2) 
> 
> and i "rpc.mountd -d all", and try do mount on client: 
> 	mount -t nfs -o nolock 10.10.37.147:/mnt/dir1 /mnt/1/; 
> 	mount -t nfs -o nolock 10.10.37.147:/mnt/dir2 /mnt/2/;
> 
> in kernel, /mnt/dir1 and /mnt/dir2 respectively corresponds to   two different svc_export objects. 
> in fh_compose(), they have same fsid_type and fsid, but the fileidtype and fileid should NOT be same.
> i am still in puzzled. :-(

The reason your getting the same file handle for both mounts is 
because the 'fsid=2' is set on both exports. So what is happening 
is the 'mount 10.10.37.147:/mnt/dir2 /mnt/2' is actually mounting 
the /mnt/1 directory on the server which is the reason for the
same file handle.  At least that's what as happening in my testing. 

So you have two options. One, don't set the fsid or don't make the fsids
the same value.

steved.
