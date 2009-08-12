From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: NULL pointer dereference in __put_nfs_open_context()
Date: Wed, 12 Aug 2009 09:34:13 +0100
Message-ID: <1250066053.20332.0.camel@pc1117.cambridge.arm.com>
References: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
	 <1249995530.12218.3.camel@heimdal.trondhjem.org>
	 <1250010984.30628.15.camel@pc1117.cambridge.arm.com>
	 <1250014185.26580.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:61953 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751726AbZHLIeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 04:34:21 -0400
In-Reply-To: <1250014185.26580.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-11 at 14:09 -0400, Trond Myklebust wrote:
> On Tue, 2009-08-11 at 18:16 +0100, Catalin Marinas wrote:
> > On Tue, 2009-08-11 at 08:58 -0400, Trond Myklebust wrote:
> > > How about the following instead? This patch gets rid of those
> > > nfs_open_context references altogether...
> > 
> > It fixes the kernel oops.
> > 
> > Thanks.
> 
> Can I mark that as a Tested-by? :-)

Yes.

-- 
Catalin

