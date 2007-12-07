From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Fri, 07 Dec 2007 17:36:39 -0500
Message-ID: <1197067000.10831.1.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
	 <1196969392.7990.9.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:54467 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630AbXLGWgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 17:36:46 -0500
In-Reply-To: <Pine.LNX.4.64.0712061803240.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2007-12-06 at 18:11 -0500, James Lentini wrote:
> What is your opinion on including the fix in 2.6.24? It addresses an 
> observed problem for certain I/Os over NFS/RDMA. Would you like me to 
> resend the patch with a revised description?

Please do.

Trond

