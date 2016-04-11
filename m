Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:38563 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752104AbcDKUe6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:34:58 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net> <20160411201050.20531.53651.stgit@manet.1015granger.net>
In-Reply-To: <20160411201050.20531.53651.stgit@manet.1015granger.net>
Subject: RE: [PATCH v1 05/18] xprtrdma: Avoid using Write list for small NFS READ requests
Date: Mon, 11 Apr 2016 15:35:35 -0500
Message-ID: <033901d19431$b3725d20$1a571760$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Avoid the latency and interrupt overhead of registering a Write
> chunk when handling NFS READ requests of a few hundred bytes or
> less.
> 
> This change does not interoperate with Linux NFS/RDMA servers
> that do not have commit 9d11b51ce7c1 ('svcrdma: Fix send_reply()
> scatter/gather set-up').
> 
> $ git describe 9d11b51ce7c1
> v4.2-rc3-10-g9d11b51
>

Hey Chuck,

Is there any way to avoid breaking interoperability with older servers?

Steve 


