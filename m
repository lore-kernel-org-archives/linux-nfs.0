From: Chuck Lever <chuck.lever@oracle.com>
Subject: nfs_revalidate_file_size
Date: Mon, 28 Apr 2008 16:32:49 -0400
Message-ID: <4C012AB6-670F-41E6-8392-7164E42611AB@oracle.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17290 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765889AbYD1UdY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 16:33:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I'm looking at this logic in nfs_revalidate_file_size:

         if (server->flags & NFS_MOUNT_NOAC)
                 goto force_reval;
         if (filp->f_flags & O_DIRECT)
                 goto force_reval;
         if (nfsi->npages != 0)
                 return 0;
         if (!(nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE) &&
					!nfs_attribute_timeout(inode))
                 return 0;
force_reval:
         return __nfs_revalidate_inode(server, inode);

There are problems with this when there are concurrent writers or  
there happen to be outstanding writes.

If "noac" is set and there are concurrent (O_SYNC) writers, the  
getattr may not see the correct file size on the server if it is done  
while some other process is in the middle of a write.

The logic should be looking at acregmin/max not at the "noac" flag.   
If someone sets "actimeo=0" this logic will continue to use a cached  
file size if there happen to be outstanding dirty pages.

If this is an O_APPEND write, the client will potentially miss file  
size changes on the server if there happen to be outstanding dirty  
pages on this client.

These cases could be improved by using the same technique as  
nfs_getattr: Causing all writers to wait, flushing out the writes  
without a commit, then doing the getattr.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
