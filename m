Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:34165 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab1HVSyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 14:54:15 -0400
Date: Mon, 22 Aug 2011 14:54:14 -0400
From: Jim Rees <rees@umich.edu>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Pavel Emelianov <xemul@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS client virtualization plan
Message-ID: <20110822185414.GB3676@merit.edu>
References: <4E4A4DB1.2090105@parallels.com>
 <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com>
 <4E4E30E8.2080704@parallels.com>
 <CDCCBEC6-18B3-4ED5-A562-1DC4611F1169@oracle.com>
 <4E4E9B8C.8050000@parallels.com>
 <20110819193259.GC1641@fieldses.org>
 <4E529221.6010102@parallels.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E529221.6010102@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Stanislav Kinsbursky пишет:

  19.08.2011 23:32, J. Bruce Fields пишет:
  >On Fri, Aug 19, 2011 at 09:21:16PM +0400, Stanislav Kinsbursky wrote:
  >>Actually, yes, I do. Thanks for notice.
  >>Kernel NSM monitor routines will be virtualized.
  >>For idmapd and gssd rpc_pipefs virtualization is required.
  >>I wasn't going to virtualize rpc_pipefs for now - it was planned to be a part of NFS server virtualization, which is planned to be done after NFS client virtualization.
  >
  >You'll need rpc_pipefs for gssd and the old idmapd.
  >
  >Also the new idmapper uses request_key.  I think there's a little
  >discussion about this in the archives.
  >
  
  Thanks, Bruce.
  Nice to know, that you noticed this discussion.
  I'll rpc_pipefs to the todo list for NFS client.

As of 3.1, rpc_pipefs is also used by the block layout driver and blkmapd.
