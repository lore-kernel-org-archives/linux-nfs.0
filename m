Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:57776 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178Ab3IDQUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 12:20:55 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 4 Sep 2013 17:20:54 +0100
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 459276E803F
	for <linux-nfs@vger.kernel.org>; Wed,  4 Sep 2013 12:20:48 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r84GKmgq16122100
	for <linux-nfs@vger.kernel.org>; Wed, 4 Sep 2013 16:20:48 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r84GKlBi019953
	for <linux-nfs@vger.kernel.org>; Wed, 4 Sep 2013 12:20:48 -0400
Date: Wed, 4 Sep 2013 11:20:45 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: jupiter <jupiter.hce@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS 4 error
Message-ID: <20130904162045.GC7433@us.ibm.com>
References: <CAA=hcWR28P=bbJvZAmWRF9sr=0=B8SyBsq3U1x2-kTQ=Rr0U4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA=hcWR28P=bbJvZAmWRF9sr=0=B8SyBsq3U1x2-kTQ=Rr0U4A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

jupiter [jupiter.hce@gmail.com] wrote:
> Hi,
> 
> I am running NFS 4 server on CentOS 6.4 for many months, it works
> well. Recently I found that the dmesg display many following errors
> but it still works. I searched google but could not find result of how
> to fix it. What are those error message means? Are the errors serious
> or not? How to fix it?
> 
> --------
> rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket
> rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket

When the nfsd (NFS server thread) was trying to send something, it got
-32 (EPIPE) error.  I have seen this kind of errors when the socket is
closed by clients.  Clients do close the socket (and recreate one) when
they need to retry due to network failures.

They are NOT serious errors, and if they are still happening, then look
at your network errors/retries etc.

Regards, Malahal.

