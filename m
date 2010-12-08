Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:51120 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756603Ab0LHVTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 16:19:35 -0500
Date: Wed, 8 Dec 2010 21:19:31 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid
 incorrect
Message-ID: <20101208211930.GI20844@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk>
 <1291835999.3067.13.camel@heimdal.trondhjem.org>
 <20101208202009.GH20844@rd.bbc.co.uk>
 <1291841129.3067.22.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291841129.3067.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> Have you tried running the idmapper with the '-f -v -v' flags so you can
> log the translation upcalls? The default cache timeout is 10 minutes, so
> you shouldn't have to wait too long.

vc-r210-0:/# rpc.idmapd -f -v -v
rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: New client: 0
rpc.idmapd: New client: 1
rpc.idmapd: New client: 10
rpc.idmapd: New client: 11
rpc.idmapd: New client: 12
rpc.idmapd: New client: 13
rpc.idmapd: New client: 14
rpc.idmapd: New client: 15
rpc.idmapd: New client: 2
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt2/idmap
rpc.idmapd: New client: 4
rpc.idmapd: New client: 5
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt5/idmap
rpc.idmapd: New client: 7
rpc.idmapd: New client: 8
rpc.idmapd: New client: 9
rpc.idmapd: New client: a
rpc.idmapd: New client: b
rpc.idmapd: New client: c
rpc.idmapd: New client: d
rpc.idmapd: New client: e
rpc.idmapd: New client: f
rpc.idmapd: Client 2: (user) name "root@rd.bbc.co.uk" -> id "0"
rpc.idmapd: Client 2: (group) name "other@rd.bbc.co.uk" -> id "20"
rpc.idmapd: Client 2: (user) name "davidf@rd.bbc.co.uk" -> id "1179"
rpc.idmapd: Client 2: (group) name "rd@rd.bbc.co.uk" -> id "1000"

These four translations occured at the very start of test, ie,
when bash was executed / ".file" truncated.  There were no further
translations.

> While the open() call may indeed fail to set the uid/gid (because to do
> so would require an upcall right in the middle of an asynchronous RPC
> call), it should normally mark the inode as requiring revalidation if
> this is the case.

Where ought this occur (so we can validate that it is indeed the case)?

> The ensuing stat() should then trigger a GETATTR call on the wire, which
> will correct the uid/gid.

Is this possibly related to:
  http://article.gmane.org/gmane.linux.nfs/37224 ?

Kind regards,

..david
