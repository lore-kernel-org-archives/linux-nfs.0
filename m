From: Chuck Lever <chuck.lever@oracle.com>
Subject: nfs-utils and unfsd
Date: Mon, 4 Aug 2008 15:55:41 -0400
Message-ID: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61678 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbYHDT53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2008 15:57:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a generic RPC server helper in nfs-utils called rpc_init().   
This API will need to be modified to support IPv6 in statd and mountd,  
at least.

However, there is a comment inside support/nfs/rpcmisc.c, where  
rpc_init() resides, that suggests that this interface is also used by  
unfsd.

Is it OK for me to modify nfs-utils' copy of this function, or is  
there any kind of ABI restriction between unfsd and nfs-utils?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
