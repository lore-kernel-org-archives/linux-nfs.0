Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59862 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637Ab1HSTdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 15:33:01 -0400
Date: Fri, 19 Aug 2011 15:32:59 -0400
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Pavel Emelianov <xemul@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS client virtualization plan
Message-ID: <20110819193259.GC1641@fieldses.org>
References: <4E4A4DB1.2090105@parallels.com>
 <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com>
 <4E4E30E8.2080704@parallels.com>
 <CDCCBEC6-18B3-4ED5-A562-1DC4611F1169@oracle.com>
 <4E4E9B8C.8050000@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4E9B8C.8050000@parallels.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 19, 2011 at 09:21:16PM +0400, Stanislav Kinsbursky wrote:
> Actually, yes, I do. Thanks for notice.
> Kernel NSM monitor routines will be virtualized.
> For idmapd and gssd rpc_pipefs virtualization is required.
> I wasn't going to virtualize rpc_pipefs for now - it was planned to be a part of NFS server virtualization, which is planned to be done after NFS client virtualization.

You'll need rpc_pipefs for gssd and the old idmapd.

Also the new idmapper uses request_key.  I think there's a little
discussion about this in the archives.

--b.
