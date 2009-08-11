From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NULL pointer dereference in __put_nfs_open_context()
Date: Tue, 11 Aug 2009 14:09:45 -0400
Message-ID: <1250014185.26580.2.camel@heimdal.trondhjem.org>
References: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
	 <1249995530.12218.3.camel@heimdal.trondhjem.org>
	 <1250010984.30628.15.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34062 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbZHKSJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Aug 2009 14:09:48 -0400
In-Reply-To: <1250010984.30628.15.camel-hhZApKj8DF/YkXV2EHHjLW3o5bpOHsLO@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-11 at 18:16 +0100, Catalin Marinas wrote:
> On Tue, 2009-08-11 at 08:58 -0400, Trond Myklebust wrote:
> > How about the following instead? This patch gets rid of those
> > nfs_open_context references altogether...
> 
> It fixes the kernel oops.
> 
> Thanks.

Can I mark that as a Tested-by? :-)

Cheers
  Trond

