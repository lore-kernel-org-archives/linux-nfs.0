Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35501 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab2ARV4f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2012 16:56:35 -0500
Message-ID: <4F174005.9080403@panasas.com>
Date: Wed, 18 Jan 2012 23:56:21 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <stable@vger.kernel.org>
CC: Greg KH <greg@kroah.com>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Patch Upstream: [PATCHES 0/2] pnfs-obj: Must return layout on IO
 error
References: <20120111154700.5A847262B@git.kroah.org> <20120112231449.GB20151@kroah.com>
In-Reply-To: <20120112231449.GB20151@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2012 01:14 AM, Greg KH wrote:
> 
> Again, care to send this to stable@vger.kernel.org?
> 
> thanks,
> 
> greg k-h

As reply to this mail I'm sending two versions of this patch:

One for the linux-3.0.y branch (annotated linux-3.0.y)
2nd for the linux-3.1.y branch (annotated linux-3.1.y)

Thanks
