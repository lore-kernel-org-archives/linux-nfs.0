From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: NULL pointer dereference in __put_nfs_open_context()
Date: Tue, 11 Aug 2009 18:16:24 +0100
Message-ID: <1250010984.30628.15.camel@pc1117.cambridge.arm.com>
References: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
	 <1249995530.12218.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:44921 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754662AbZHKRQ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 13:16:27 -0400
In-Reply-To: <1249995530.12218.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-11 at 08:58 -0400, Trond Myklebust wrote:
> How about the following instead? This patch gets rid of those
> nfs_open_context references altogether...

It fixes the kernel oops.

Thanks.

-- 
Catalin

