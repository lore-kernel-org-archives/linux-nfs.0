From: Chuck Lever <chuck.lever@oracle.com>
Subject: EACCES in mount.nfs
Date: Tue, 29 Apr 2008 17:42:07 -0400
Message-ID: <183E9EC8-78F5-4352-BB01-84F9CE4F72FE@oracle.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:64832 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbYD2Vmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2008 17:42:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

There is an important case in mount.nfs where EACCES is temporary:   
The kernel's rpcbind client returns EACCES if the remote rpcbind  
server replies that the requested service is not registered.

It would be easy enough for the kernel's mount client to remap that  
error code into something unique for the mount system call.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
