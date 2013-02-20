Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:22214 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab3BTQ3L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 11:29:11 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: RDMA, el6, kernel panic
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.DEB.1.00.1302191536430.5816@shell>
Date: Wed, 20 Feb 2013 11:29:04 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <E409C539-688A-414F-A2A8-1F03EA7F2741@oracle.com>
References: <alpine.DEB.1.00.1302191536430.5816@shell>
To: Mark Lehrer <mark@tpsit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 19, 2013, at 6:05 PM, Mark Lehrer <mark@tpsit.com> wrote:

> 
> I have an easily-reproduceable kernel panic with RDMA on el6,
> kernel version 2.6.32-279.19.1.el6.x86_64
> 
> If a client has an NFS filesystem mounted via RDMA, and the Infiniband
> connection goes away on the client without disconnecting from the NFS
> server, the NFS server gives a kernel panic.
> 
> Is this a known problem, or should I email the panic output to this
> list?  If it is an unknown problem, I will try on a more recent kernel
> too.

The usual process for seeking help with Enterprise kernels is to contact your distributor and open a bug.

If you want to reproduce with a current upstream kernel (like 3.7), then we are more likely to be able to help.  However, it's possible your distributor has added IB drivers to their el6 kernel that are not available upstream.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




