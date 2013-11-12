Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27857 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755854Ab3KLQ6q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 11:58:46 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 0/2] sunrpc: more reliable detection of running gssd
Date: Tue, 12 Nov 2013 16:56:25 +0000
Message-ID: <1384275379.4779.8.camel@leira.trondhjem.org>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
	 <A0488E98-0DF9-4ECE-A39D-C8E460E4C546@oracle.com>
	 <20131112110831.72234c64@tlielax.poochiereds.net>
	 <B9D2C1A3-ABD1-4A87-9AFD-BC9C2F1BA55C@oracle.com>
In-Reply-To: <B9D2C1A3-ABD1-4A87-9AFD-BC9C2F1BA55C@oracle.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 11:15 -0500, Chuck Lever wrote:
+AD4- On Nov 12, 2013, at 11:08 AM, Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Tue, 12 Nov 2013 11:02:42 -0500
+AD4- +AD4- Chuck Lever +ADw-chuck.lever+AEA-oracle.com+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4APg- 
+AD4- +AD4APg- On Nov 12, 2013, at 8:00 AM, Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4- wrote:
+AD4- +AD4APg- 
+AD4- +AD4- What's the module loading solution?
+AD4- 
+AD4- Load auth+AF8-rpcgss.ko only when rpc.gssd has been started.  See the +ACIAWw-PATCH+AF0- Adding the nfs4+AF8-secure+AF8-mounts bool+ACI- thread... If auth+AF8-rpcgss.ko is not loaded, the kernel won't ever try to do an upcall.
+AD4- 
+AD4- Then, systemd can be used to restart rpc.gssd if it crashes, maybe?  Just a thought.

You can trivially defeat that by compiling the gss code into the kernel.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
