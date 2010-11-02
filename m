From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2] Regression: fix mounting NFS when NFSv3 support is
 not compiled
Date: Tue, 02 Nov 2010 12:21:28 -0400
Message-ID: <1288714888.2925.63.camel@heimdal.trondhjem.org>
References: <20101031162105.23213.60220.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088Ab0KBQWn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Nov 2010 12:22:43 -0400
In-Reply-To: <20101031162105.23213.60220.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-10-31 at 18:21 +0200, Paulius Zaleckas wrote:
> Trying to mount NFS (root partition in my case) fails if CONFIG_NFS_V3
> is not selected. nfs_validate_mount_data() returns EPROTONOSUPPORT,
> because of this check:
> 
> #ifndef CONFIG_NFS_V3
> 	if (args->version == 3)
> 		goto out_v3_not_compiled;
> #endif /* !CONFIG_NFS_V3 */
> 
> and args->version was always initialized to 3.
> 
> It was working in 2.6.36
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

This one looks good. Applied...

Trond
