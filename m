From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: NFS commit: sync or async?
Date: Fri, 23 Jul 2010 08:47:56 +0800
Message-ID: <20100723004756.GB5246@localhost>
References: <20100722073623.GA24462@localhost>
 <1279802335.3621.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11674 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755808Ab0GWAr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 20:47:58 -0400
In-Reply-To: <1279802335.3621.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Hi Fengguang,
> 
> Are you sure this trace is from a recent kernel? In all kernels prior to
> 2.6.34-rc3, COMMIT was a synchronous RPC call, which would explain the
> above trace.

My god. I was running 2.6.34-rc1 and reading 2.6.35-rc4 code ..

Sorry for the noise!

Thanks,
Fengguang

