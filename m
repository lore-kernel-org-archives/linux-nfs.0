From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/38] SVC Transport Switch
Date: Thu, 29 Nov 2007 17:18:48 -0600
Message-ID: <1196378328.16169.35.camel@trinity.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:45788 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761184AbXK2XOr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:14:47 -0500
In-Reply-To: <20071129223917.14563.77633.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I finger fumbled Bruce's address in the first set. I sent another one
because I wanted people to be able to reply and get Bruce's correct 
address information in the reply. 

Please forgive me for the clutter I've caused. 
Tom

On Thu, 2007-11-29 at 16:39 -0600, Tom Tucker wrote:
> The following series implements a pluggable transport switch for
> RPC servers. This patchset is a rollup of the original
> plus incremental patches.
> 
> In addition to the incremental change rollup:
> 
> - The address management logic in svc_xprt was cleaned up a
>   based on feedback from Chuck Lever,
> 
> - A race was fixed whereby UDP RPC from different clients in parallel
>   could corrupt each other's addresses.
> 
> - Changes were made to the sysctl implementation to comply 
>   with the new 2.6.24 requirements regarding sysctl ids.
> 
> The following testing was done:
> 
> - Connectathon on V3 and V4 on TCP, UDP and RDMA mounts
> 
> - Kernel build on V3 RDMA mount.
> 
> This patchset is against the 2.6.24-rc3 kernel tree.
> 

