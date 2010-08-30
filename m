Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:62125 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911Ab0H3RD3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 13:03:29 -0400
Subject: Re: `rpc.nfsd #` gets hung up when loopback iface is down
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201008281646.44883.vapier@gentoo.org>
Date: Mon, 30 Aug 2010 13:03:16 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <4C2340A7-5500-455D-AA22-60ABCC2324DB@oracle.com>
References: <201008281646.44883.vapier@gentoo.org>
To: Mike Frysinger <vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 28, 2010, at 4:46 PM, Mike Frysinger wrote:

> is it expected behavior that `rpc.nfsd #` gets hung up whenever the loopback 
> interface hasnt been configured ?  even `rpc.nfsd 0` which seems a bit odd.
> -mike

NFS doesn't work without lo being configured.  We don't test that scenario, normally, so I wouldn't say specifically that we expect this particular behavior.  However, since rpc.nfsd might require the kernel to use the local portmapper, yes, it probably will hang without "lo".

We had a similar report earlier this year on client side misbehavior when lo was not configured.  It was a root-on-NFS situation where an NFS mount was done before networking was fully configured.

The kernel's portmapper client now uses TCP to contact the local portmapper so that it can detect immediately when there is no local portmapper running.  Normally, if a physical interface is down, operations on a TCP socket will fail.  Apparently this has never been the case for "lo".

Usually our solution to this problem is "Don't try to use NFS without lo".  But please let us know what your use case is.

-- 
chuck[dot]lever[at]oracle[dot]com




