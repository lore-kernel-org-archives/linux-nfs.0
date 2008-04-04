From: Chuck Lever <chuck.lever@oracle.com>
Subject: RPC service registration timeout
Date: Fri, 4 Apr 2008 12:38:56 -0400
Message-ID: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:38518 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbYDDQlD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2008 12:41:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Registering a local RPC service has a long timeout.

When starting the NFSD service, for example, the RPC server wants to  
unregister at least 6 different RPC services (three versions of NFS  
and three versions of lockd) before it even tries to register the  
services it's bringing up.

Usually this isnt' a problem.  However, if a portmapper or rpcbind  
daemon isn't running, each one of these registrations causes a long  
wait (up to a minute each, I think) while the RPC server attempts to  
contact the rpcbind daemon at localhost.

I don't think this wait is interruptible, either.

I'm wondering if this long timeout is really necessary.  Can we get  
by with a second or so, and a couple of retries?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
