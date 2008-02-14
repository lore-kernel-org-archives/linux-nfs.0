From: Chuck Lever <chuck.lever@oracle.com>
Subject: location of headers under /usr/include/tirpc
Date: Thu, 14 Feb 2008 17:09:09 -0500
Message-ID: <5761C623-763A-4B2C-8536-96B1989C162F@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:49936 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYBNWKH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 17:10:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

I think libtirpc-devel installs the tirpc headers in the wrong  
place.  The #include directives in the headers themselves expect them  
to appear under /usr/include, not under /usr/include/tirpc, so my  
builds fail when trying to include these headers.

For example, /usr/include/tirpc/rpc/rpcb_clnt.h does a "#include <rpc/ 
rpcb_prot.h>" -- and the build chokes because that header is actually  
in /usr/include/tirpc/rpc/rpcb_prot.h.

Now, I can probably fix this temporarily by adding "-I /usr/include/ 
tirpc" to my build.  However:

1.  On Solaris, these all appear under /usr/include, there is no /usr/ 
include/tirpc.

2.  libtirpc-devel installs a bunch of files that already exist, such  
as /usr/include/rpc/auth.h, in /usr/include/tirpc/rpc/auth.h.

It would be cleaner to have one place for nfs-utils to look for these  
headers, so I don't want to permanently add "-I /usr/include/tirpc"  
or autoconf magic to find the right path unless we decide /usr/ 
include/tirpc is the final location for these files.

So I think applications in general will expect to find these under / 
usr/include, not under /usr/include/tirpc.

Comments?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
