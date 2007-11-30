From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 00/38] RPC Transport Switch
Date: Thu, 29 Nov 2007 19:27:48 -0500
Message-ID: <20071130002748.GA10394@fieldses.org>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56539 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282AbXK3A1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2007 19:27:49 -0500
In-Reply-To: <20071129225510.15275.82660.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2007 at 04:55:10PM -0600, Tom Tucker wrote:
> This patchset implements the RDMA Transport Driver for the 
> SVC Transport Switch. This patchset has been tested with iozone
> and Connectathon over NFS v3.
> 
> This patchset is against 2.6.24-rc3.
> 
> This patchset along with the SVC transport switch and client
> side marshalling fix are also available in this git tree:
> 
> git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git
> 
> -- 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Somehow patch 23 never made it through....

--b.
